---
name: grill
description: Use when user invokes /grill to interrogate session artifacts (code, plans, docs, configs). Single-pass scan → severity-tagged findings table → PASS/CONDITIONAL/FAIL verdict.
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

## Step 6 — Post-Verdict Loop (max 2 iterations)

1. **PASS** → stop.
2. **FAIL** → fix all `[CRITICAL]` first; re-verify those specifically; then fix `[GAP]`s.
3. **CONDITIONAL PASS** → fix `[GAP]`s.
4. Re-grill **once** (iteration 2). Carry finding IDs — skip rows already fixed+verified; only surface new or still-broken.
5. Still failing after iteration 2 → surface remaining findings + `AskUserQuestion` batching all `[QUESTION]` items + proceed/abort choice. NEVER infinite-loop.

## Invariants

1. Read actual content (or subagent report of actual content) — NEVER grill from memory.
2. Single pass per iteration; max 2 iterations.
3. Every finding: ID + evidence + actionable fix.
4. ≤20 findings per iteration.
5. Each iteration produces a fresh table.
