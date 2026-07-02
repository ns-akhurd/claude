---
name: grill
description: Use when user invokes /grill to interrogate session artifacts (code, plans, docs, configs). Single-pass scan → severity-tagged findings table → fix ALL findings → re-grill, iterating until PASS.
---

# Grill — Single-Pass Interrogation

GRILL MODE active. Expose gaps, errors, inconsistencies in artifacts produced/modified **this session only**. Read actual file content — NEVER grill from summaries.

## Step 1 — Artifact Discovery

Build the in-scope set:
1. Scan conversation for `Write`/`Edit`/`NotebookEdit` tool calls this session → collect paths.
2. Run `git diff --name-only HEAD` + `git status --porcelain` to catch on-disk changes.
3. Union the two sets. NEVER grill unchanged files.
4. **Skip-list** (auto-exclude): `node_modules/`, `vendor/`, `dist/`, `build/`, `*.min.*`, lockfiles (`package-lock.json`, `yarn.lock`, `go.sum`, `Cargo.lock`, `poetry.lock`), binaries, generated code.
5. **Auto-PASS** (no scan): pure rename, comment-only edit, whitespace-only, single-line typo fix, trivial ≤5-line change.
6. If in-scope set empty after filters → reply "No session artifacts to grill" and stop.

## Step 2 — Read Strategy

- ≤5 files AND ≤2k total lines: read all in-scope files in **one parallel batch** (single message, N `Read` calls).
- >5 files OR >2k lines: delegate to `Explore` subagent — prompt: "Read <paths>, return: (a) list of claims/decisions/assumptions per file, (b) cross-file inconsistencies, (c) external refs (Jira/Confluence). Under 400 words." Grill from subagent's report.
- Modified files (not new): read only diff hunks + 20 lines context + immediate callers via Grep. Skip whole-file re-read.

## Step 3 — Single-Pass Scan

One read per artifact. Hold all checks simultaneously — NEVER multi-pass.

| Lens | Ask |
|---|---|
| Behavior | inputs/outputs specified; edge cases handled; failure modes caught |
| Correctness | logic matches intent; no off-by-one, inverted ratios, wrong signs |
| Consistency | plan↔impl↔tests↔docs agree; limitations propagated to recommendations; rationale matches current numbers; validation claims match source |
| Security | injection, authz, secrets, path traversal, unsafe deserialization |
| Scale/Perf | concurrency, retries, hot paths, quadratic loops |
| Deps/Env | versions pinned, env vars present, config source explicit |
| Completeness | every requirement mapped; every error path handled; tests cover non-happy paths |

**External refs (conditional):**
- Jira `[A-Z]+-\d+` present → `eng-skills:jira` + `jira issue <ID>`. Contradicts artifact → `[CRITICAL]`. Claimed resolved but open → `[GAP]`.
- Confluence `netskope.atlassian.net/wiki/…` present → `eng-skills:confluence`. Contradicts doc → `[CRITICAL]`. Missing doc'd caveat → `[GAP]`.
- NEVER fetch refs not present in artifacts.

## Step 4 — Findings

Severity tags:
- `[CRITICAL]` — wrong behavior, security flaw, data loss, logic error. Blocks.
- `[GAP]` — missing case/test/doc. Must address.
- `[UNCLEAR]` — ambiguous; needs clarification.
- `[SMELL]` — suspicious, not wrong.
- `[QUESTION]` — needs user decision.

**Rules:**
- State findings directly. NEVER hedge ("might", "could").
- Cap **20 findings per iteration** — drop lowest-severity `[SMELL]`s to stay under cap.
- Every row MUST cite evidence (file:line excerpt or exact claim quoted).
- Assign stable ID `F<n>` per finding — persists across iterations.

| ID | Sev | File:Line | Evidence | Finding | Fix/Action |
|----|-----|-----------|----------|---------|------------|

## Step 5 — Verdict

- **PASS** — no CRITICAL/GAP.
- **CONDITIONAL PASS** — GAP/UNCLEAR only.
- **FAIL** — any CRITICAL.

## Step 6 — Fix-and-Regrill Loop (iterate until PASS)

1. **PASS** → stop. No further work.
2. **Any non-PASS verdict** → fix **ALL** findings observed this iteration, in severity order: `[CRITICAL]` → `[GAP]` → `[UNCLEAR]` → `[SMELL]` (skip a `[SMELL]` only if it has no actionable fix). Apply fixes directly to the artifacts with `Edit`/`Write`. State each fix applied.
3. **Re-grill** (next iteration) — fresh single-pass scan of the updated artifacts. Carry finding IDs: skip rows already fixed + verified; surface only new or still-broken findings.
4. **Repeat** steps 5–6 until the verdict is **PASS**.
5. **Safety cap — 6 iterations.** If still not PASS after 6 iterations, STOP: surface the remaining findings table and report the unresolved IDs. Do not infinite-loop.
6. **`[QUESTION]` findings** (genuinely need a user decision you cannot make): do not auto-fix. Surface them, continue fixing the rest, and let the user resolve the `[QUESTION]` items. A leftover `[QUESTION]` alone does not block a PASS if no CRITICAL/GAP remains.

## Invariants

1. Read actual content (or subagent report of actual content) — NEVER grill from memory.
2. Single pass per iteration; iterate until PASS (safety cap 6 iterations).
3. Every finding: ID + evidence + actionable fix.
4. ≤20 findings per iteration.
5. Each iteration produces a fresh table.
6. Fix ALL findings each non-PASS iteration — not just CRITICALs. A grill that leaves GAPs/SMELLs unfixed is incomplete.
