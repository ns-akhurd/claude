#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract model display name
model=$(echo "$input" | jq -r '.model.display_name')
model_id=$(echo "$input" | jq -r '.model.id')

# Extract current working directory (shorten home to ~)
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
home_dir="$HOME"
if [ -n "$cwd" ]; then
    cwd="${cwd/#$home_dir/~}"
fi

# Extract context usage percentage and session id
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')

# Pricing per million tokens (input / output / cache_read / cache_write)
if echo "$model_id" | grep -qi "opus-4-6\|opus-4-5"; then
    price_in="5.00";  price_out="25.00"; price_cr="0.50";  price_cw="6.25"
elif echo "$model_id" | grep -qi "opus-4"; then
    price_in="15.00"; price_out="75.00"; price_cr="1.50";  price_cw="18.75"
elif echo "$model_id" | grep -qi "sonnet-4"; then
    price_in="3.00";  price_out="15.00"; price_cr="0.30";  price_cw="3.75"
elif echo "$model_id" | grep -qi "haiku-4-5\|haiku-4.5"; then
    price_in="1.00";  price_out="5.00";  price_cr="0.10";  price_cw="1.25"
elif echo "$model_id" | grep -qi "haiku"; then
    price_in="0.80";  price_out="4.00";  price_cr="0.08";  price_cw="1.00"
else
    price_in="3.00";  price_out="15.00"; price_cr="0.30";  price_cw="3.75"
fi

# Calculate cost + per-component breakdown + session duration from session JSONL
# Output: "<total> <inp_tok> <out_tok> <cr_tok> <cw_tok> <duration_secs>"
breakdown=""
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
if [ -n "$session_id" ]; then
    breakdown=$(python3 - "$session_id" "$price_in" "$price_out" "$price_cr" "$price_cw" "$transcript_path" 2>/dev/null <<'PYEOF'
import json, glob, os, sys, time
sid, pi, po, pcr, pcw = sys.argv[1], float(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4]), float(sys.argv[5])
transcript_path = sys.argv[6] if len(sys.argv) > 6 else ''
inp=out=cr=cw=0
first_ts=None
for f in ([transcript_path] if transcript_path and os.path.exists(transcript_path)
          else glob.glob(os.path.expanduser('~/.claude/projects/*/' + sid + '.jsonl'))):
    with open(f) as fh:
        for line in fh:
            try:
                obj = json.loads(line.strip())
                ts = obj.get('timestamp')
                if ts:
                    from datetime import datetime, timezone
                    try:
                        dt = datetime.fromisoformat(ts.replace('Z','+00:00'))
                        epoch = dt.timestamp()
                        if first_ts is None or epoch < first_ts:
                            first_ts = epoch
                    except: pass
                if obj.get('type') == 'assistant':
                    u = obj.get('message', {}).get('usage', {})
                    inp += u.get('input_tokens', 0)
                    out += u.get('output_tokens', 0)
                    cr  += u.get('cache_read_input_tokens', 0)
                    cw  += u.get('cache_creation_input_tokens', 0)
            except: pass
total = inp/1e6*pi + out/1e6*po + cr/1e6*pcr + cw/1e6*pcw
duration = int(time.time() - first_ts) if first_ts else 0
print(f'{total:.4f} {inp} {out} {cr} {cw} {duration}')
PYEOF
)
fi

# Parse breakdown fields
if [ -n "$breakdown" ]; then
    cost=$(echo "$breakdown"     | awk '{print $1}')
    tok_inp=$(echo "$breakdown"  | awk '{print $2}')
    tok_out=$(echo "$breakdown"  | awk '{print $3}')
    tok_cr=$(echo "$breakdown"   | awk '{print $4}')
    tok_cw=$(echo "$breakdown"   | awk '{print $5}')
    dur_secs=$(echo "$breakdown" | awk '{print $6}')
else
    # Fallback: context window totals only (no cache data)
    total_input=$(echo "$input"  | jq -r '.context_window.total_input_tokens // 0')
    total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
    cost=$(awk -v ti="$total_input" -v to="$total_output" -v pi="$price_in" -v po="$price_out" \
        'BEGIN { printf "%.4f", (ti*pi + to*po) / 1000000 }')
    tok_inp="$total_input"; tok_out="$total_output"; tok_cr=0; tok_cw=0
    dur_secs=0
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

# Total cost display
cost_display=$(awk -v c="$cost" 'BEGIN {
    if      (c < 0.0001) printf "$0.00"
    else if (c < 0.01)   printf "$%.4f", c
    else                 printf "$%.2f", c
}')

# If context data is available, create a progress bar
if [ -n "$used_pct" ]; then
    # Round to nearest integer
    used_int=$(printf "%.0f" "$used_pct")

    # Calculate bar width (20 characters total)
    bar_width=20
    filled=$(( used_int * bar_width / 100 ))
    empty=$(( bar_width - filled ))

    # Build progress bar (filled=, empty=·)
    bar="["
    for ((i=0; i<filled; i++)); do bar+="="; done
    for ((i=0; i<empty; i++)); do bar+="·"; done
    bar+="]"

    # Color code based on usage: green <50%, yellow 50-80%, red >80%
    if [ "$used_int" -lt 50 ]; then
        color="\033[32m"  # green
    elif [ "$used_int" -lt 80 ]; then
        color="\033[33m"  # yellow
    else
        color="\033[31m"  # red
    fi

    sep=" \033[2m│\033[0m "
    # Model │ [bar·] 7% │ i:X o:X r:X w:X $cost │ ~/cwd │ HH:MM · duration
    printf "\033[1;36m%s\033[0m${sep}%b%s %d%%\033[0m${sep}\033[2mi:%s o:%s r:%s w:%s\033[0m \033[1;33m%s\033[0m${sep}\033[1;34m%s\033[0m${sep}\033[0;37m%s\033[0m \033[2m·\033[0m \033[0;35m%s\033[0m" \
        "$model" \
        "$color" "$bar" "$used_int" \
        "$itok" "$otok" "$crtok" "$cwtok" "$cost_display" \
        "$cwd" \
        "$(date +%H:%M)" "$duration_display"
else
    sep=" \033[2m│\033[0m "
    # No context data yet
    printf "\033[1;36m%s\033[0m${sep}\033[1;33m%s\033[0m${sep}\033[1;34m%s\033[0m${sep}\033[0;37m%s\033[0m \033[2m·\033[0m \033[0;35m%s\033[0m" \
        "$model" "$cost_display" "$cwd" "$(date +%H:%M)" "$duration_display"
fi
