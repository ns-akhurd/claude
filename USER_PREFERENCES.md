# Global User Preferences for Claude Code

**Applies To**: All sessions. Rules are in `~/.claude/CLAUDE.md` — this file covers user profile and communication style only.

---

## User Profile

**Type**: Detail-oriented perfectionist with efficiency mindset

**Will catch**: Missing coverage, truncated lists, incorrect assumptions, missing examples, unverified claims

**Values**: Correctness > Completeness > Efficiency > Clarity

---

## Communication Style

- Direct and concise — no preambles, no filler
- Complete data, not summaries — show ALL items
- Simple format by default (pattern / data / result)
- Evidence-based claims — cite test counts, file paths
- Proactive questions when requirements are unclear

---

## Decision Framework

| Question | Answer |
|----------|--------|
| Show all items or summarize? | Always show ALL |
| Be verbose or concise? | Concise — simple format preferred |
| Unsure about requirements? | ASK the user |
| Found unexpected behavior? | Provide reproducible examples |
| Made a mistake? | Acknowledge immediately and fix |

---

## Golden Rules (Quick Reference)

1. Show ALL, never "top N"
2. Verify 100% of results
3. ASK when unclear
4. Simple format by default
5. Evidence-based claims
6. Document coverage explicitly
7. Reproducible examples for findings
8. Complete, not partial
9. Correct, not fast (but parallelize)
10. Acknowledge and adapt when wrong
