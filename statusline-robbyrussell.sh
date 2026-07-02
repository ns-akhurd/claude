#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract model display name
model=$(echo "$input" | jq -r '.model.display_name')
effort=$(echo "$input" | jq -r '.effort_level // .effortLevel // empty')
[ -n "$effort" ] && model_display="$model [$effort]" || model_display="$model"

# Extract current working directory (shorten home to ~)
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
home_dir="$HOME"
if [ -n "$cwd" ]; then
    cwd="${cwd/#$home_dir/~}"
fi

# Extract context usage percentage and session id
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')

# Session-wide stats reported directly by the harness
sess_lines_add=$(echo "$input" | jq -r '.cost.total_lines_added   // 0')
sess_lines_del=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
fast_mode=$(echo "$input"      | jq -r '.fast_mode // false')
dur_total_ms=$(echo "$input"   | jq -r '.cost.total_duration_ms     // 0')
dur_api_ms=$(echo "$input"     | jq -r '.cost.total_api_duration_ms // 0')

# Calculate per-model cost from session JSONL (same source as /cost command).
# Python reads message.model + message.usage per assistant turn, applies per-model
# pricing, and outputs:
#   line 1: duration_secs
#   line 2+: short_name cost_float inp out cr cw
breakdown=""
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
if [ -n "$session_id" ]; then
    breakdown=$(python3 - "$session_id" "$transcript_path" 2>/dev/null <<'PYEOF'
import json, glob, os, sys, time
from datetime import datetime

sid = sys.argv[1]
transcript_path = sys.argv[2] if len(sys.argv) > 2 else ''

# Pricing per million tokens: (input, output, cache_read, cache_write)
PRICING = {
    'opus-4.8':  ( 5.00, 25.00, 0.50,   6.25),
    'opus-4.7':  ( 5.00, 25.00, 0.50,   6.25),
    'opus-4.6':  ( 5.00, 25.00, 0.50,   6.25),
    'opus-4':    (15.00, 75.00, 1.50,  18.75),
    'sonnet-4.6':( 3.00, 15.00, 0.30,   3.75),
    'sonnet-4.5':( 3.00, 15.00, 0.30,   3.75),
    'sonnet-4':  ( 3.00, 15.00, 0.30,   3.75),
    'haiku-4.5': ( 1.00,  5.00, 0.10,   1.25),
    'haiku-4':   ( 0.80,  4.00, 0.08,   1.00),
}

def short_name(model_id):
    m = model_id.lower().replace('.', '-')
    if 'opus-4-8'  in m: return 'opus-4.8'
    if 'opus-4-7'  in m: return 'opus-4.7'
    if 'opus-4-6'  in m or 'opus-4-5' in m: return 'opus-4.6'
    if 'opus-4'    in m: return 'opus-4'
    if 'sonnet-4-6' in m: return 'sonnet-4.6'
    if 'sonnet-4-5' in m: return 'sonnet-4.5'
    if 'sonnet-4'  in m: return 'sonnet-4'
    if 'haiku-4-5' in m: return 'haiku-4.5'
    if 'haiku-4'   in m: return 'haiku-4'
    return model_id.split('/')[-1][:12]

def get_price(sname):
    for key in ('opus-4.8','opus-4.7','opus-4.6','opus-4',
                'sonnet-4.6','sonnet-4.5','sonnet-4',
                'haiku-4.5','haiku-4'):
        if sname.startswith(key) or key in sname:
            return PRICING[key]
    return PRICING['sonnet-4']

model_tokens = {}  # short_name -> [inp, out, cr, cw]
tool_calls = {}    # tool_name -> count
first_ts = None

for f in ([transcript_path] if transcript_path and os.path.exists(transcript_path)
          else glob.glob(os.path.expanduser('~/.claude/projects/*/' + sid + '.jsonl'))):
    with open(f) as fh:
        for line in fh:
            try:
                obj = json.loads(line.strip())
                ts = obj.get('timestamp')
                if ts:
                    try:
                        dt = datetime.fromisoformat(ts.replace('Z', '+00:00'))
                        epoch = dt.timestamp()
                        if first_ts is None or epoch < first_ts:
                            first_ts = epoch
                    except: pass
                if obj.get('type') == 'assistant':
                    msg = obj.get('message', {})
                    mid = msg.get('model', '')
                    u   = msg.get('usage', {})
                    sn  = short_name(mid) if mid else 'unknown'
                    if sn not in model_tokens:
                        model_tokens[sn] = [0, 0, 0, 0]
                    model_tokens[sn][0] += u.get('input_tokens', 0)
                    model_tokens[sn][1] += u.get('output_tokens', 0)
                    model_tokens[sn][2] += u.get('cache_read_input_tokens', 0)
                    model_tokens[sn][3] += u.get('cache_creation_input_tokens', 0)
                    # Tally tool calls by name (where the model spends its actions)
                    for b in msg.get('content', []) or []:
                        if isinstance(b, dict) and b.get('type') == 'tool_use':
                            nm = b.get('name', '?')
                            tool_calls[nm] = tool_calls.get(nm, 0) + 1
            except: pass

duration = int(time.time() - first_ts) if first_ts else 0
print(duration)
# Stats line: total_tool_calls  top_tool:count  (where actions go)
_total_tools = sum(tool_calls.values())
_top = max(tool_calls.items(), key=lambda x: x[1]) if tool_calls else ('', 0)
print(f'STATS {_total_tools} {_top[0] or "-"} {_top[1]}')
for sn, (inp, out, cr, cw) in model_tokens.items():
    pi, po, pcr, pcw = get_price(sn)
    cost = inp/1e6*pi + out/1e6*po + cr/1e6*pcr + cw/1e6*pcw
    print(f'{sn} {cost:.4f} {inp} {out} {cr} {cw}')
PYEOF
)
fi

# Parse per-model breakdown
tok_inp=0; tok_out=0; tok_cr=0; tok_cw=0; dur_secs=0; cost_display=""
total_cost=0
tool_total=0; tool_top=""; tool_top_n=0

fmt_cost() {
    awk -v c="$1" 'BEGIN {
        if      (c < 0.0001) printf "$0.00"
        else if (c < 0.01)   printf "$%.4f", c
        else                 printf "$%.2f", c
    }'
}

if [ -n "$breakdown" ]; then
    dur_secs=$(echo "$breakdown" | head -1)
    # STATS line: "STATS <total> <topname> <topcount>"
    stats_line=$(echo "$breakdown" | grep '^STATS ' | head -1)
    if [ -n "$stats_line" ]; then
        read -r _ tool_total tool_top tool_top_n <<<"$stats_line"
    fi
    while IFS=' ' read -r mdl cost inp out cr cw; do
        [ "$mdl" = "STATS" ] && continue
        cfmt=$(fmt_cost "$cost")
        [ -n "$cost_display" ] && cost_display="$cost_display · "
        cost_display="${cost_display}${mdl}:${cfmt}"
        tok_inp=$((tok_inp + inp))
        tok_out=$((tok_out + out))
        tok_cr=$((tok_cr  + cr))
        tok_cw=$((tok_cw  + cw))
        total_cost=$(awk -v a="$total_cost" -v b="$cost" 'BEGIN { printf "%.6f", a + b }')
    done < <(echo "$breakdown" | tail -n +2)
fi

# Fallback: context window totals (no per-model data)
if [ -z "$cost_display" ]; then
    total_input=$(echo "$input"  | jq -r '.context_window.total_input_tokens // 0')
    total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
    cost_display=$(awk -v ti="$total_input" -v to="$total_output" \
        'BEGIN { printf "$%.2f", (ti*3.00 + to*15.00) / 1000000 }')
    tok_inp="$total_input"; tok_out="$total_output"
fi

# Format session duration: 0 → "", 45 → "45s", 125 → "2m5s", 3661 → "1h1m"
duration_display=$(awk -v s="$dur_secs" 'BEGIN {
    s = int(s)
    if (s <= 0) { print ""; exit }
    h = int(s / 3600); m = int((s % 3600) / 60); sec = s % 60
    if      (h > 0) printf "%dh%dm",  h, m
    else if (m > 0) printf "%dm%ds",  m, sec
    else            printf "%ds",     sec
}')

# Format a token count as compact string: 1234 → 1.2k, 1234567 → 1.2M
fmt_tok() {
    awk -v n="$1" 'BEGIN {
        if      (n >= 1000000) printf "%.1fM", n/1000000
        else if (n >= 1000)    printf "%.0fk", n/1000
        else                   printf "%d",    n
    }'
}
itok=$(fmt_tok "$tok_inp")
otok=$(fmt_tok "$tok_out")
crtok=$(fmt_tok "$tok_cr")
cwtok=$(fmt_tok "$tok_cw")

# Cache-hit rate: cache reads / (cache reads + uncached input). High = good.
cache_pct=""
cache_denom=$((tok_cr + tok_inp))
if [ "$cache_denom" -gt 0 ]; then
    cache_pct=$(awk -v r="$tok_cr" -v d="$cache_denom" 'BEGIN { printf "%.0f", r*100/d }')
fi

# Burn rate: $/hour over the session so far.
burn_display=""
if [ "$dur_secs" -gt 30 ]; then
    burn_display=$(awk -v c="$total_cost" -v s="$dur_secs" 'BEGIN {
        rate = c / (s/3600.0)
        if (rate <= 0) { print ""; exit }
        printf "$%.2f/h", rate
    }')
fi

# Where tokens go: share of total input that is cache-write vs cache-read vs fresh.
# (cache-write = new context the model had to ingest; the real "spend" driver.)
tok_total_in=$((tok_inp + tok_cr + tok_cw))
pct_write=0; pct_read=0; pct_fresh=0
if [ "$tok_total_in" -gt 0 ]; then
    pct_write=$(awk -v a="$tok_cw"  -v t="$tok_total_in" 'BEGIN{printf "%.0f",a*100/t}')
    pct_read=$(awk  -v a="$tok_cr"  -v t="$tok_total_in" 'BEGIN{printf "%.0f",a*100/t}')
    pct_fresh=$(awk -v a="$tok_inp" -v t="$tok_total_in" 'BEGIN{printf "%.0f",a*100/t}')
fi

# Where time goes: API (waiting on model) vs local (tools/thinking on our side).
# total_duration_ms is wall-clock; total_api_duration_ms is time in model calls.
api_pct=""
if [ "${dur_total_ms:-0}" -gt 0 ] && [ "${dur_api_ms:-0}" -gt 0 ]; then
    api_pct=$(awk -v a="$dur_api_ms" -v t="$dur_total_ms" 'BEGIN{
        p=a*100/t; if(p>100)p=100; printf "%.0f", p }')
fi
fmt_ms() {  # ms → compact h/m/s
    awk -v ms="$1" 'BEGIN{ s=int(ms/1000)
        if(s<=0){print "0s";exit}
        h=int(s/3600); m=int((s%3600)/60); x=s%60
        if(h>0)printf "%dh%dm",h,m; else if(m>0)printf "%dm%ds",m,x; else printf "%ds",x }'
}

# 256-color palette (foreground) — ALL real ESC bytes (ANSI-C $'...') so width
# measurement strips them consistently.
c() { printf "\033[38;5;%sm" "$1"; }
RST=$'\033[0m'; DIM=$'\033[2m'; BLD=$'\033[1m'
ICE=$(c 51); GOLD=$(c 220); GREEN=$(c 42); YEL=$(c 178); RED=$(c 203)
BLUE=$(c 75); PURP=$(c 141); GREY=$(c 244); ORNG=$(c 215); PINK=$(c 211)
SEPC=$(c 39)   # vivid steel-blue separator accent
sep=" ${BLD}${SEPC}┃${RST} "
# Nerd-font glyphs (defined via printf so the bytes are unambiguous)
GBR=$(printf '\xee\x82\xa0')   #  git branch
GMDL=$(printf '\xf3\xb0\x9a\xa9') # 󰚩 robot/model

# Git: branch + working-tree state (counts), ahead/behind, lines ±
git_seg=""
if [ -n "$cwd" ]; then
    raw_cwd="${cwd/#\~/$HOME}"
    gb=$(git -C "$raw_cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
        || git -C "$raw_cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    if [ -n "$gb" ]; then
        # Leading branch glyph (no bare space) keeps line 2 flush with line 1.
        git_seg="${PURP}${GBR} ${gb}${RST}"

        # In-progress operation badge (rebase/merge/cherry-pick/bisect/revert).
        # Most important git signal — never commit blind into a half-finished op.
        gitdir=$(git -C "$raw_cwd" --no-optional-locks rev-parse --git-dir 2>/dev/null)
        op=""
        if [ -n "$gitdir" ]; then
            [ -d "$gitdir/rebase-merge" ] || [ -d "$gitdir/rebase-apply" ] && op="REBASE"
            [ -f "$gitdir/MERGE_HEAD" ]       && op="MERGE"
            [ -f "$gitdir/CHERRY_PICK_HEAD" ] && op="CHERRY-PICK"
            [ -f "$gitdir/BISECT_LOG" ]       && op="BISECT"
            [ -f "$gitdir/REVERT_HEAD" ]      && op="REVERT"
        fi
        [ -n "$op" ] && git_seg="${git_seg} ${BLD}${RED}⚠ ${op}${RST}"

        # Working-tree status counts
        porc=$(git -C "$raw_cwd" --no-optional-locks status --porcelain 2>/dev/null)
        if [ -n "$porc" ]; then
            staged=$(grep -c '^[MARCD]' <<<"$porc")
            dirty=$(grep -c '^.[MD]'   <<<"$porc")
            untrk=$(grep -c '^??'      <<<"$porc")
            [ "$staged" -gt 0 ] && git_seg="${git_seg} ${GREEN}+${staged}${RST}"
            [ "$dirty"  -gt 0 ] && git_seg="${git_seg} ${YEL}~${dirty}${RST}"
            [ "$untrk"  -gt 0 ] && git_seg="${git_seg} ${RED}?${untrk}${RST}"
        else
            git_seg="${git_seg} ${GREEN}${RST}"
        fi
        # Ahead/behind upstream
        ab=$(git -C "$raw_cwd" --no-optional-locks rev-list --left-right --count @{u}...HEAD 2>/dev/null)
        if [ -n "$ab" ]; then
            behind=$(awk '{print $1}' <<<"$ab"); ahead=$(awk '{print $2}' <<<"$ab")
            [ "${ahead:-0}"  -gt 0 ] && git_seg="${git_seg} ${BLUE}${ahead}${RST}"
            [ "${behind:-0}" -gt 0 ] && git_seg="${git_seg} ${BLUE}${behind}${RST}"
        fi
        # Stashes — easy to forget shelved work
        nstash=$(git -C "$raw_cwd" --no-optional-locks stash list 2>/dev/null | wc -l)
        [ "$nstash" -gt 0 ] && git_seg="${git_seg} ${ORNG}≡${nstash}${RST}"

        # Last-commit age (staleness) — compact: 13h, 2d, 45m
        last_age=$(git -C "$raw_cwd" --no-optional-locks log -1 --format=%ct 2>/dev/null)
        if [ -n "$last_age" ]; then
            commit_age=$(awk -v t="$last_age" 'BEGIN{
                d=systime()-t; if(d<0)d=0
                if(d<3600)      printf "%dm", int(d/60)
                else if(d<86400)printf "%dh", int(d/3600)
                else            printf "%dd", int(d/86400) }')
        fi
    fi
fi

# Visible terminal width of a string (strip ANSI; UTF-8 locale).
# awk length() counts codepoints, but emoji ⚡/⚠ render as TWO cells — add +1
# each so column padding matches what the terminal actually draws.
# Always emits a number — END guards the empty-input case.
vislen() { printf '%s' "$1" | sed 's/\x1b\[[0-9;]*m//g' \
    | awk '{ n=length; n+=gsub(/⚡/,"&"); n+=gsub(/⚠/,"&") } END{ print n+0 }'; }

# ── Build each line as an array of segments (column cells) ──
# Segments are joined by the separator; columns are width-aligned across lines.

# Line 1 — model | context gauge | token flow | cost
seg1_model="${BLD}${ICE}${GMDL} ${model_display}${RST}"
[ "$fast_mode" = "true" ] && seg1_model="${seg1_model} ${BLD}${GOLD}⚡${RST}"

seg1_ctx=""
if [ -n "$used_pct" ]; then
    used_int=$(printf "%.0f" "$used_pct")
    bar_width=14
    filled=$(( used_int * bar_width / 100 ))
    [ "$filled" -gt "$bar_width" ] && filled=$bar_width
    empty=$(( bar_width - filled ))
    if   [ "$used_int" -lt 50 ]; then gc="$GREEN"
    elif [ "$used_int" -lt 80 ]; then gc="$YEL"
    else gc="$RED"; fi
    bar=""
    for ((i=0; i<filled; i++)); do bar+="▰"; done
    for ((i=0; i<empty;  i++)); do bar+="▱"; done
    seg1_ctx="${GREY}${RST} ${gc}${bar} ${used_int}%${RST}"
fi

seg1_tok="${DIM}${GREY}${RST}${DIM} ${itok}↓ ${otok}↑ ${crtok}⚡ ${cwtok}✎${RST}"
if [ -n "$cache_pct" ]; then
    if   [ "$cache_pct" -ge 80 ]; then hc="$GREEN"
    elif [ "$cache_pct" -ge 50 ]; then hc="$YEL"
    else hc="$ORNG"; fi
    seg1_tok="${seg1_tok} ${DIM}cache${RST}${hc}${cache_pct}%${RST}"
fi

seg1_cost="${BLD}${GOLD} ${cost_display}${RST}"
[ -n "$burn_display" ] && seg1_cost="${seg1_cost} ${DIM}${ORNG}${burn_display}${RST}"

# Line 2 — git | session churn | path | clock·duration
seg2_git="$git_seg"
seg2_churn=""
if [ "${sess_lines_add:-0}" -gt 0 ] || [ "${sess_lines_del:-0}" -gt 0 ]; then
    seg2_churn="${GREEN}+${sess_lines_add}${RST}${DIM}/${RST}${RED}-${sess_lines_del}${RST}"
fi
seg2_path="${BLUE} ${cwd}${RST}"
seg2_clock="${DIM}${PINK} $(date +%H:%M)${RST} ${DIM}${GREY}·${RST} ${DIM}${PURP}${duration_display}${RST}"
# Last-commit age (commit-staleness): green <4h, yellow <24h, red older
if [ -n "$commit_age" ]; then
    case "$commit_age" in
        *m) ac="$GREEN" ;;
        *h) [ "${commit_age%h}" -lt 4 ] && ac="$GREEN" || ac="$YEL" ;;
        *)  ac="$RED" ;;
    esac
    seg2_clock="${seg2_clock} ${DIM}${GREY}·${RST} ${DIM}${ac}${commit_age} ago${RST}"
fi

# Line 3 — tools | token spend | time split
seg3_tools="${ORNG}󰛢 ${tool_total:-0} tools${RST}"
if [ -n "$tool_top" ] && [ "$tool_top" != "-" ] && [ "${tool_top_n:-0}" -gt 0 ]; then
    seg3_tools="${seg3_tools} ${DIM}(top ${ORNG}${tool_top}${RST}${DIM} ×${tool_top_n})${RST}"
fi
seg3_spend=""
[ "$tok_total_in" -gt 0 ] && \
    seg3_spend="${DIM}tokens${RST} ${YEL}${pct_write}%✎${RST}${DIM}/${RST}${GREEN}${pct_read}%⚡${RST}${DIM}/${RST}${BLUE}${pct_fresh}%↓${RST}"
seg3_time=""
if [ -n "$api_pct" ]; then
    other_pct=$((100 - api_pct))
    seg3_time="${DIM}time${RST} ${PURP}${api_pct}%api${RST}${DIM}/${RST}${GREY}${other_pct}%idle${RST} ${DIM}($(fmt_ms "$dur_total_ms"))${RST}"
fi

# ── Per-column max width across the three lines ──
# Column N = the Nth segment on each line. Align by padding to the column max.
col_w() { local m=0 w; for s in "$@"; do w=$(vislen "$s"); [ "$w" -gt "$m" ] && m=$w; done; echo "$m"; }
w0=$(col_w "$seg1_model" "$seg2_git"   "$seg3_tools")
w1=$(col_w "$seg1_ctx"   "$seg2_churn" "$seg3_spend")
w2=$(col_w "$seg1_tok"   "$seg2_path"  "$seg3_time")
# (column 3 — last cell on each line — needs no padding)

# Emit one line as an aligned grid row.
# Args alternate: w0 seg0 w1 seg1 ... wN segN  (final seg has no trailing column).
# Empty MIDDLE cells are padded to keep columns aligned; empty TRAILING cells are
# dropped entirely (no separator, no padding) so there's no dangling "┃" or spaces.
emit_line() {
    local -a ws=() segs=()
    while [ "$#" -gt 0 ]; do ws+=("$1"); segs+=("$2"); shift 2 2>/dev/null || shift; done
    local n=${#segs[@]} last=-1 i
    # index of last non-empty segment
    for ((i=0; i<n; i++)); do [ -n "${segs[i]}" ] && last=$i; done
    [ "$last" -lt 0 ] && return
    local out=""
    for ((i=0; i<=last; i++)); do
        local s="${segs[i]}" w="${ws[i]:-0}" pad cell
        if [ "$i" -lt "$last" ]; then
            pad=$(( w - $(vislen "$s") )); [ "$pad" -lt 0 ] && pad=0
            printf -v cell '%s%*s' "$s" "$pad" ''
        else
            cell="$s"   # last visible cell: no padding
        fi
        [ "$i" -eq 0 ] && out="$cell" || out="${out}${sep}${cell}"
    done
    printf '%b' "$out"
}

emit_line "$w0" "$seg1_model" "$w1" "$seg1_ctx"   "$w2" "$seg1_tok"  0 "$seg1_cost"
printf "\n"
emit_line "$w0" "$seg2_git"   "$w1" "$seg2_churn" "$w2" "$seg2_path" 0 "$seg2_clock"
printf "\n"
emit_line "$w0" "$seg3_tools" "$w1" "$seg3_spend" "$w2" "$seg3_time" 0 ""
