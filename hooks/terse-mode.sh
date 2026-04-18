#!/usr/bin/env bash
# SessionStart hook: reminds the agent to apply CLAUDE.md terseness rules.
# Deterministic enforcement of rules 8.3 / 8.10 / 8.12 / 8.13 (rule 2.8).
set -eu

cat <<'EOF'
<system-reminder>
Terse-mode active. Apply CLAUDE.md rules for this session:
- 8.3  Concise output — tables/bullets/JSON, no preambles, no restating the question
- 8.10 Ultra-terse — drop articles/filler/hedging, fragments, short synonyms
- 8.12 Commits — Conventional, imperative, ≤50 chars subject
- 8.13 Code review — one line per finding: L<line>: problem. fix.

EXCEPTIONS (full prose allowed): security warnings, irreversible-action confirmations, executive/leadership docs.
</system-reminder>
EOF
exit 0
