#!/usr/bin/env bash
# PostToolUse / tool_result hook: run clang-format on C/C++ files after Edit or Write.
#
# Two invocation modes (single source of truth for both harnesses):
#   * Claude Code PostToolUse: passes hook context via stdin as JSON.
#   * Pi tool_result extension: passes the file path as $1.
#
# If $1 is a non-empty argument, it is treated as the file path and stdin is
# NOT read (pi has no stdin to provide, so `cat` would block). Otherwise the
# Claude Code JSON envelope on stdin is parsed for file_path/path.
#
# Always exits 0 — never surfaces a formatter failure to the agent.

set -u

LOGFILE="/tmp/post-clang-format.log"

# Resolve file path: $1 (pi) takes precedence; else parse stdin JSON (Claude Code).
f="${1:-}"
if [ -z "$f" ]; then
  STDIN_DATA=$(cat)
  echo "[post-clang-format] $(date '+%H:%M:%S') stdin_len=${#STDIN_DATA}" >> "$LOGFILE"
  # Format: {"tool_name":"Edit","tool_input":{"file_path":"..."},...}
  # Also handle flat format and `path` key (pi edit/write use `path`).
  f=$(python3 -c "
import json, sys
raw = sys.stdin.read()
try:
    d = json.loads(raw)
    ti = d.get('tool_input') or {}
    fp = ti.get('file_path', '') or ti.get('path', '') or d.get('file_path', '') or d.get('path', '')
    print(fp)
except:
    print('')
" <<< "$STDIN_DATA" 2>/dev/null)
fi

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
