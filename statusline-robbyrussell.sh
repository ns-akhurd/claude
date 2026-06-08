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
    'opus-4.8':  (15.00, 75.00, 1.50,  18.75),
    'opus-4.7':  (15.00, 75.00, 1.50,  18.75),
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
            except: pass

duration = int(time.time() - first_ts) if first_ts else 0
print(duration)
for sn, (inp, out, cr, cw) in model_tokens.items():
    pi, po, pcr, pcw = get_price(sn)
    cost = inp/1e6*pi + out/1e6*po + cr/1e6*pcr + cw/1e6*pcw
    print(f'{sn} {cost:.4f} {inp} {out} {cr} {cw}')
PYEOF
)
fi

# Parse per-model breakdown
tok_inp=0; tok_out=0; tok_cr=0; tok_cw=0; dur_secs=0; cost_display=""

fmt_cost() {
    awk -v c="$1" 'BEGIN {
        if      (c < 0.0001) printf "$0.00"
        else if (c < 0.01)   printf "$%.4f", c
        else                 printf "$%.2f", c
    }'
}

if [ -n "$breakdown" ]; then
    dur_secs=$(echo "$breakdown" | head -1)
    while IFS=' ' read -r mdl cost inp out cr cw; do
        cfmt=$(fmt_cost "$cost")
        [ -n "$cost_display" ] && cost_display="$cost_display · "
        cost_display="${cost_display}${mdl}:${cfmt}"
        tok_inp=$((tok_inp + inp))
        tok_out=$((tok_out + out))
        tok_cr=$((tok_cr  + cr))
        tok_cw=$((tok_cw  + cw))
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

# Git branch (from cwd, skip optional locks)
git_branch=""
if [ -n "$cwd" ]; then
    raw_cwd="${cwd/#\~/$HOME}"
    git_branch=$(git -C "$raw_cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
        || git -C "$raw_cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

sep=" \033[2m│\033[0m "

# Line 1 (static): model │ context bar + % │ token breakdown + cost
if [ -n "$used_pct" ]; then
    used_int=$(printf "%.0f" "$used_pct")
    bar_width=20
    filled=$(( used_int * bar_width / 100 ))
    empty=$(( bar_width - filled ))
    bar="["
    for ((i=0; i<filled; i++)); do bar+="="; done
    for ((i=0; i<empty; i++)); do bar+="·"; done
    bar+="]"
    if [ "$used_int" -lt 50 ]; then
        color="\033[32m"
    elif [ "$used_int" -lt 80 ]; then
        color="\033[33m"
    else
        color="\033[31m"
    fi
    printf "\033[1;36m%s\033[0m${sep}%b%s %d%%\033[0m${sep}\033[2mi:%s o:%s r:%s w:%s\033[0m \033[1;33m%s\033[0m" \
        "$model_display" \
        "$color" "$bar" "$used_int" \
        "$itok" "$otok" "$crtok" "$cwtok" "$cost_display"
else
    printf "\033[1;36m%s\033[0m${sep}\033[1;33m%s\033[0m" \
        "$model_display" "$cost_display"
fi

# Line 2 (dynamic): git branch │ ~/cwd │ HH:MM · duration
printf "\n"
if [ -n "$git_branch" ]; then
    printf "\033[1;35m %s\033[0m${sep}" "$git_branch"
fi
printf "\033[1;34m%s\033[0m${sep}\033[0;37m%s\033[0m \033[2m·\033[0m \033[0;35m%s\033[0m" \
    "$cwd" "$(date +%H:%M)" "$duration_display"
