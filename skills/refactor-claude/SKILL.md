---
name: refactor-claude
description: Audit and refactor ~/.claude/CLAUDE.md to eliminate redundancy and ensure every instruction is imperative (MUST/NEVER/ALWAYS). Preserves all intent — zero functionality removed. Use when CLAUDE.md feels bloated, contradictory, or contains passive/vague language.
---

You are refactoring `~/.claude/CLAUDE.md` to be leaner and strictly imperative. **Zero functionality MUST be lost.** Every existing behavioural directive MUST be preserved — only the expression changes.

## Step 1 — Read the full file

Read `~/.claude/CLAUDE.md` in its entirety before touching anything.

## Step 2 — Audit: flag every defect

Scan every rule and line. Tag each finding:

| Tag | Meaning |
|---|---|
| `[PASSIVE]` | Passive voice, suggestions, or hedging ("consider", "try to", "it may be good to", "should", "recommend") |
| `[VAGUE]` | Unmeasurable or aspirational — agent can't test compliance |
| `[DUPLICATE]` | Same behavioural directive stated in 2+ places (even different wording) |
| `[CONTRADICTION]` | Two rules that conflict or undermine each other |
| `[BLOAT]` | Prose justification, motivation, or explanation that adds no directive content |

Build a numbered defect list before editing anything.

## Step 3 — Resolve each defect

For every flagged item, apply the minimal fix:

- `[PASSIVE]` → rewrite in imperative mood: "MUST do X", "NEVER do Y", "ALWAYS do Z"
- `[VAGUE]` → add a concrete, testable condition, OR delete if no imperative form exists
- `[DUPLICATE]` → keep the stronger/more specific statement; delete the weaker one; update any cross-references
- `[CONTRADICTION]` → flag to user with both rule numbers and proposed resolution; DO NOT silently pick one
- `[BLOAT]` → strip all prose that is not a directive; keep only imperatives and the minimum context needed to apply them

Rules for what MUST NOT change:
1. NEVER remove a rule whose intent cannot be expressed imperatively — instead, rewrite it
2. NEVER merge two rules that cover distinct triggers into one rule
3. NEVER reorder sections or renumber rules gratuitously — only renumber if a deletion creates a gap
4. NEVER change rule semantics — only expression

## Step 4 — Verify no functionality was lost

Before writing the final file:
1. Count rules before and after — every deletion MUST correspond to a `[DUPLICATE]` or confirmed-zero-intent `[VAGUE]`
2. For every deleted rule: confirm its intent is expressed by a surviving rule — write that mapping explicitly
3. For every rewritten rule: confirm the imperative form covers all cases the original covered

## Step 5 — Write the refactored file

Use `Write` to replace `~/.claude/CLAUDE.md` with the cleaned version.

MUST preserve:
- All section headers (##) and sub-headers (**N.X ...**)
- All tables with their columns intact
- The Rule Authoring Standard (Section 0) verbatim — it is self-referential and MUST be exact

## Step 6 — Report to user

Output:
```
## /refactor-claude Results

Defects found: N
  - PASSIVE: N  (rewrote to imperative)
  - VAGUE:   N  (sharpened or deleted)
  - DUPLICATE: N  (consolidated)
  - CONTRADICTION: N  (flagged below — needs your input)
  - BLOAT:   N  (stripped)

Rules before: N  |  Rules after: N  |  Functionality preserved: 100%

Contradictions requiring your input:
  - §X.Y vs §A.B: <description of conflict> → proposed resolution: <text>

See ~/.claude/CLAUDE.md for the updated file.
```

NEVER claim "100% functionality preserved" without completing Step 4.
