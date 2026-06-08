#!/usr/bin/env bash
# PreToolUse: emit advisory when low effort + expensive tool combo detected.
# CLAUDE_EFFORT injected by Claude Code v2.1.133+ for PreToolUse hooks.
set -eu

EFFORT="${CLAUDE_EFFORT:-}"
TOOL="${CLAUDE_TOOL_NAME:-}"

[[ "$EFFORT" == "low" ]] || exit 0

case "$TOOL" in
  Agent|Workflow)
    echo '{"type":"system","content":"[effort-gate] effort=low: prefer inline work over spawning agents — only spawn if task is genuinely parallel."}'
    ;;
  WebFetch|WebSearch)
    echo '{"type":"system","content":"[effort-gate] effort=low: skip web lookups unless explicitly requested — use training knowledge."}'
    ;;
esac

exit 0
