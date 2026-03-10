---
name: esummary
description: Review the current session conversation and produce a crisp executive summary suitable for a VP or SVP of Engineering. Captures what was investigated, key findings, decisions made, blockers, risks, and next steps — without verbosity.
---

You are producing an **executive engineering summary** of this session for a VP/SVP of Engineering audience.

## Audience Contract
- Readers are senior technical leaders: skip definitions, skip background context
- Every word must earn its place — no filler, no hedging, no restating the obvious
- Lead with **status and outcomes**, not with process
- Flag risks and blockers loudly — they act on those
- Use **bullets and tables**, never prose paragraphs

---

## Step 1 — Scan the Full Session

Read the entire conversation. Identify and categorize every significant exchange into one of:

| Category | What to capture |
|----------|----------------|
| **Problem / Goal** | What was the engineer trying to accomplish? |
| **Key Findings** | What was discovered, confirmed, or ruled out? |
| **Decisions Made** | What approach/configuration/design was chosen and why (one line) |
| **Blockers / Gaps** | What couldn't be resolved? Missing docs, missing access, unknowns |
| **Risks** | Things that could go wrong or need attention |
| **Action Items** | Concrete next steps with owner if determinable |
| **Tool / Process Failures** | If AI/tools failed to find info — note it, it signals a gap |

---

## Step 2 — Apply the SVP Filter

Before writing, ask for each item:
- Would a VP need to know this to make a decision or unblock the team? → **KEEP**
- Is this implementation detail with no decision or risk attached? → **DROP**
- Is this a risk/blocker that could affect timeline or reliability? → **ESCALATE** (bold or flag)
- Did the session surface something previously unknown or assumed incorrectly? → **HIGHLIGHT as Finding**

---

## Step 3 — Write the Summary

Use this exact structure. Omit any section that has nothing to report — do not leave empty sections.

```
## Session Summary — [1-line topic, e.g. "BlueField DPU RXP Engine Enablement"]
**Date:** [today]   **Engineer context:** [inferred role/team if determinable]

---

### Status
[One sentence: what is the current state? Resolved / In Progress / Blocked]

---

### Objective
[One sentence: what was being accomplished and why it matters]

---

### Key Findings
- [Finding 1 — factual, specific, no fluff]
- [Finding 2]
- ...
⚠️ [Flag any finding that overturns a prior assumption or reveals a gap]

---

### Decisions & Approach
| Decision | Rationale |
|----------|-----------|
| [What was chosen] | [Why — one clause] |

---

### Blockers / Open Questions
- 🔴 [Hard blocker — must be resolved before progress]
- 🟡 [Soft blocker — workaround exists but suboptimal]

---

### Risks
- [Risk 1 — state the failure mode and impact, not just the concern]

---

### Action Items
| # | Action | Owner | Priority |
|---|--------|-------|----------|
| 1 | [Concrete next step] | [Eng / Team / NVIDIA Support] | P1/P2/P3 |

---

### Documentation / Knowledge Gaps Identified
[Only if applicable — e.g., vendor docs missing, internal runbooks needed]
```

---

## Step 4 — Quality Check Before Output

- [ ] No sentence longer than 20 words
- [ ] No section longer than 5 bullets (consolidate if needed)
- [ ] Every blocker has a proposed owner or escalation path
- [ ] Every risk has a stated impact (not just "this could be a problem")
- [ ] No AI hedge phrases: "it appears", "it seems", "you may want to", "consider"
- [ ] If something was NOT resolved — say so explicitly, do not soften it
- [ ] Total length: fits on one page (≤ 400 words body, excluding tables)

---

## Step 5 — Output

Print the summary directly. Do not preface it with explanation. Do not add a closing paragraph summarizing what you just wrote.
