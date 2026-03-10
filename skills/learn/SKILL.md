---
name: learn
description: Review the current session conversation, extract generic behavioral learnings from user corrections, and persist them to the global ~/.claude/CLAUDE.md. Use when the user wants to capture what was learned from this session.
---

You are reviewing the **entire conversation history of this session** to extract behavioral learnings and persist them as agent directives.

## Step 1 — Scan for Explicit Signals

Read through the full session. Flag every instance where:

1. **User corrected behavior** — "no, do it differently", "that's wrong", "don't do X"
2. **User expressed a preference** — "I want X", "always do Y", "never do Z"
3. **User rejected an approach** — and explained or implied a better one
4. **User caught a mistake** — and fixed it or pointed it out
5. **A better method emerged** — through back-and-forth not in Claude's initial approach

## Step 2 — Scan for Implicit Signals

IMPORTANT: These are EQUALLY important as explicit signals. Re-read the session looking for:

| # | Signal | What it means | Diagnostic question |
|---|--------|--------------|---------------------|
| 6 | **Same request repeated N>1 times** | First attempt was insufficient | Why wasn't pass 1 good enough? What class of issue was missed? |
| 7 | **Diminishing but non-zero gap counts** (e.g., 13→9→6) | Each pass used a different review lens instead of all lenses | What dimensions were missed on pass 1? |
| 8 | **Fix created a new problem** caught later | Ripple effects weren't checked | What downstream refs should have been grepped immediately? |
| 9 | **Work redone differently** | Upfront analysis was missing | What investigation would have led to the right approach first? |
| 10 | **Simple task ballooned** into many steps | Wrong assumptions went unchecked | What should have been verified before starting? |
| 11 | **Silent failure** caught late or by user | Verification step was missing | What check would have caught this earlier? |
| 12 | **Context loss across session boundary** | Should have been persisted to memory | What should have been written to memory files? |

**Key rule:** IF Claude did the same task N times and N > 1, there is ALWAYS a learning. The fact that N > 1 IS the signal. NEVER dismiss this as "no learnings found."

## Step 3 — Check Existing Rules for Effectiveness

Read `~/.claude/CLAUDE.md`. For each issue found in Steps 1-2, check:

- Does an existing rule already cover this? IF YES → was it actually effective at preventing the issue?
- IF the existing rule FAILED to prevent the issue → the rule is too vague and MUST be supplemented with a concrete method/checklist
- NEVER dismiss a finding as "already covered" if the existing rule didn't actually work

## Step 4 — Filter and Deduplicate

KEEP only learnings that are:
- Generic and transferable (applies beyond this session's specific code/project)
- Behavioral (about HOW Claude should work, not domain-specific facts)
- Actionable (can be stated as an IF/THEN directive with MUST/NEVER)

DISCARD:
- Project-specific facts (file paths, API names, domain knowledge)
- One-off task completions
- Things that worked correctly

## Step 5 — Write Rules in Agent Directive Format

IMPORTANT: Rules MUST be written in imperative agent-directive format. NEVER use narrative essay style. Follow this exact template:

```markdown
### RULE X.Y — [Short Descriptive Title]

IF [precise, testable trigger condition]:

[numbered steps using MUST / NEVER / ALWAYS]

DO NOT [specific anti-pattern to avoid].
```

Requirements for each rule:
- Trigger MUST be a concrete, testable condition (not "any task involving..." but "IF reviewing a document against a reference")
- Actions MUST use MUST/NEVER/ALWAYS — no "should", "consider", "try to"
- NO "Why" sections — the agent does not need motivation, only instructions
- NO session-specific examples with file names — use generic examples only
- KEEP examples to 1-2 lines maximum; omit if the rule is unambiguous without one

## Step 6 — Update ~/.claude/CLAUDE.md

Read the current file structure. New rules MUST be:
1. Placed in the correct thematic section (Review, Task Execution, Communication, etc.)
2. Numbered sequentially within that section (e.g., if section 2 has rules 2.1-2.4, add as 2.5)
3. Consistent in format with existing rules

IF a new rule supplements/strengthens an existing rule → update the existing rule in-place rather than adding a duplicate.

IF a new rule covers a new topic → add it to the most relevant section, or create a new section if none fits.

NEVER append a dated "Session Learnings" section — the file is organized by TOPIC, not by DATE.

## Step 7 — Report to User

Tell the user:
1. How many learnings were found (explicit + implicit)
2. One-line summary of each
3. Which section of CLAUDE.md each was added to (or which existing rule was updated)
4. Ask if any should be removed or refined

IF zero qualifying learnings were found, say so clearly. NEVER invent learnings to fill the file.
