#!/usr/bin/env bash
# UserPromptSubmit hook: enforce CLAUDE.md rule 11.4.
# Emits a system-reminder if the user prompt contains a memory-write trigger phrase.
# Exit 0 = pass through. Non-zero only on unexpected errors.
set -eu

INPUT="$(cat)"
PROMPT="$(printf '%s' "$INPUT" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin)
    print(d.get("prompt","") or d.get("user_prompt","") or "")
except Exception:
    pass' 2>/dev/null || true)"

# Lowercase for matching
LC="$(printf '%s' "$PROMPT" | tr "[:upper:]" "[:lower:]")"

# Trigger phrases — whole-word / phrase matches to cut false positives.
# "never mind" excluded; require "never" followed by a verb-ish word.
match() {
  case " $LC " in
    *" always "*|*" from now on "*|*" remember this "*|*" remember that "*|\
    *" don't ever "*|*" dont ever "*|*" never do "*|*" never use "*|\
    *" never run "*|*" never call "*|*" never read "*|*" never write "*|\
    *" always use "*|*" always run "*|*" always call "*) return 0 ;;
  esac
  return 1
}

if match; then
  # stdout on UserPromptSubmit is injected as additional context
  cat <<'EOF'
<system-reminder>
Rule 11.4 trigger detected in user prompt.

You MUST update memory this turn BEFORE answering:
- New rule/preference → update or create a topic file in ~/.claude/projects/-/memory/
- Build/test/config trick → create or update a project or reference file
- Add a one-line entry to MEMORY.md index if a new file is created
- Backlink related topics per rule 11.3.8

Do this as part of the same response. Do not defer to "later".
</system-reminder>
EOF
fi

exit 0
