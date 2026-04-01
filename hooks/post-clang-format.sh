#!/usr/bin/env bash
# PostToolUse hook: run clang-format on C/C++ files after Edit or Write.
# Claude Code passes hook context via stdin as JSON (not env vars).

LOGFILE="/tmp/post-clang-format.log"

# Read stdin (Claude Code sends JSON context here)
STDIN_DATA=$(cat)

echo "[post-clang-format] $(date '+%H:%M:%S') stdin_len=${#STDIN_DATA}" >> "$LOGFILE"

# Extract file_path from stdin JSON.
# Format: {"tool_name":"Edit","tool_input":{"file_path":"..."},...}
# Also handle flat format: {"file_path":"..."}
f=$(python3 -c "
import json, sys
raw = sys.stdin.read()
try:
    d = json.loads(raw)
    fp = (d.get('tool_input') or {}).get('file_path', '') or d.get('file_path', '')
    print(fp)
except:
    print('')
" <<< "$STDIN_DATA" 2>/dev/null)

echo "[post-clang-format] $(date '+%H:%M:%S') file='${f}'" >> "$LOGFILE"

[ -z "$f" ] && exit 0

case "$f" in
    *.cpp|*.hpp|*.h|*.c|*.cc|*.cxx) ;;
    *) exit 0 ;;
esac

if [ ! -f "$f" ]; then
    echo "[post-clang-format] SKIP: file not found: $f" >> "$LOGFILE"
    exit 0
fi

CLANG_FORMAT="/opt/llvm-21/bin/clang-format"
if [ ! -x "$CLANG_FORMAT" ]; then
    echo "[post-clang-format] ERROR: clang-format not found at $CLANG_FORMAT" >> "$LOGFILE"
    exit 0
fi

"$CLANG_FORMAT" -i "$f"
echo "[post-clang-format] formatted: $f (exit $?)" >> "$LOGFILE"
exit 0
