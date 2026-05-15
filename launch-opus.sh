#!/bin/bash
# Launch Claude Code with Opus 4.6

export CLAUDE_CODE_MODEL="us.anthropic.claude-opus-4-6-v1:0"
export ANTHROPIC_DEFAULT_OPUS_MODEL="us.anthropic.claude-opus-4-6-v1:0"

exec claude "$@"
