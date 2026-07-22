#!/usr/bin/env bash
# pre-clang-format-commit.sh
#
# PreToolUse / tool_call hook: right before `git commit`, auto-apply the
# repo's OWN clang-format (scripts/git-hooks/apply-format) to staged C/C++
# files so the repo's interactive pre-commit hook finds nothing left to fix
# and passes silently — without a TTY prompt that agents cannot answer.
#
# This mirrors the pre-commit hook's "[a] Apply the fix" path exactly, using
# the same formatter + style, so it is consistent by construction (unlike a
# whole-file pass with a different clang-format version).
#
# Single source of truth — both harnesses call THIS script:
#   * Claude Code PreToolUse:  stdin is the hook JSON; extract tool_input.command.
#   * Pi tool_call extension:  passes the bash command string as $1.
#
# Always exits 0 (never blocks the commit). On any error it logs and steps
# aside so the real pre-commit hook can still run or reject.

set -u

LOGFILE="${PRE_CLANG_FORMAT_LOG:-/tmp/pre-clang-format-commit.log}"
log() { echo "[pre-cf-commit] $(date '+%H:%M:%S') $*" >> "$LOGFILE"; }

# --- Resolve the command string ---------------------------------------------
cmd="${1:-}"
if [ -z "$cmd" ]; then
  stdin_data=$(cat)
  cmd=$(python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print((d.get("tool_input") or {}).get("command", "") or d.get("command", ""))
except Exception:
    print("")
' <<< "$stdin_data" 2>/dev/null)
fi

# Only act on `git commit` (not commit-tree, log, rebase, etc.).
[[ "$cmd" =~ git[[:space:]]+commit([[:space:]]|$) ]] || exit 0

# --- Locate the repo's apply-format -----------------------------------------
repo=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -n "$repo" ] || exit 0
apply_format="$repo/scripts/git-hooks/apply-format"
[ -x "$apply_format" ] || exit 0   # repo has no clang-format hook; nothing to do

cd "$repo" || exit 0
export GIT_DIR="$(git rev-parse --git-dir)"
export GIT_INDEX_FILE="$(git rev-parse --git-path index)"
style=$(git config hooks.clangFormatDiffStyle || echo file)

patch_file=$(mktemp)
trap 'rm -f "$patch_file"' EXIT

# apply-format emits a unified diff (patch -p0 layout) of formatting fixes
# against the staged content. Empty output == already clean.
"$apply_format" --style="$style" --cached > "$patch_file" 2>>"$LOGFILE" || {
  log "apply-format failed (rc=$?); stepping aside"
  exit 0
}
[ -s "$patch_file" ] || { log "clean: no clang-format changes for $(basename "$repo")"; exit 0; }

# Apply the formatting to both the working tree and the index — the same
# "apply" path the pre-commit hook's [a] option takes.
patch -p0 < "$patch_file" >>"$LOGFILE" 2>&1 || { log "patch (worktree) failed; stepping aside"; exit 0; }
git apply -p0 --cached < "$patch_file" >>"$LOGFILE" 2>&1 || { log "git apply --cached failed; stepping aside"; exit 0; }

log "applied clang-format patch ($(wc -l < "$patch_file") lines) to $(basename "$repo")"
exit 0
