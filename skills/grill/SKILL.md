---
name: grill
description: Use when user invokes /grill to ruthlessly interrogate all output produced in the current session (code, plans, documents, configs). Applies six-lens interrogation with severity tagging and produces a structured findings table with PASS/CONDITIONAL PASS/FAIL verdict.
---

# Grill — Session Output Interrogation

When `/grill` is invoked, follow the rules in `~/.claude/rules/grill.md` exactly.

Key steps:
1. **Phase 0**: Grep all artifacts for Jira ticket IDs and Confluence URLs — fetch each via `eng-skills:jira` / `eng-skills:confluence`
2. **Read EVERY file** created or modified in the session before grilling — never from memory
3. **Apply all six lenses** (WHAT, WHY, HOW, WHERE, WHEN, WHICH) to every artifact
4. **Tag every finding**: `[CRITICAL]`, `[GAP]`, `[UNCLEAR]`, `[SMELL]`, or `[QUESTION]`
5. **Output**: numbered findings table (`#`, `Severity`, `File/Section`, `Finding`, `Action Required`)
6. **Verdict**: PASS / CONDITIONAL PASS / FAIL — any `[CRITICAL]` → FAIL, no exceptions
7. **Surface** all `[QUESTION]` items directly to the user — never assume answers

Full rules: `@~/.claude/rules/grill.md`
