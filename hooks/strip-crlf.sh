#!/usr/bin/env bash
# PostToolUse hook: strip CRLF from .sh files written under /mnt/c/
# Enforces CLAUDE.md rule 9.1 deterministically.
set -eu
INPUT="$(cat)"
FILE_PATH="$(printf '%s' "$INPUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)"
case "$FILE_PATH" in
  /mnt/c/*.sh)
    sed -i 's/\r$//' "$FILE_PATH"
    bash -n "$FILE_PATH" || { echo "strip-crlf: syntax error in $FILE_PATH" >&2; exit 2; }
    ;;
esac
exit 0
