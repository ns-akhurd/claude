---
name: grill
description: Use when user invokes /skill:grill (or the /grill prompt template) to interrogate session artifacts (code, plans, docs, configs). Single-pass scan → severity-tagged findings table → fix ALL findings → re-grill, iterating until PASS.
---

# Grill — Single-Pass Interrogation

Expose gaps, errors, inconsistencies in artifacts. Scope = **this session only** by default (files edited/written this session). IF the user names a PR/branch/diff (e.g. "grill the PR", "grill the changes in the PR") → scope = all files in the PR diff vs the base branch, not just session edits. Read actual file content — NEVER grill from summaries or memory.

## Step 1 — Artifact Discovery

1. Determine scope: session-only (default) → scan conversation for `Edit`/`Write` tool calls; PR-scoped (user named a PR/branch) → `git diff --name-only <base>...HEAD`.
2. Run `git diff --name-only HEAD` + `git status --porcelain` to catch on-disk changes.
3. Union the scope set + on-disk changes. NEVER grill unchanged files.
4. **Skip-list**: `node_modules/`, `vendor/`, `dist/`, `build/`, `*.min.*`, lockfiles, binaries, generated code.
5. **Auto-PASS** (no scan): rename, comment-only, whitespace, typo, or trivial ≤5-line change.
6. Empty after filters → "No artifacts to grill" and stop.

## Step 2 — Read Strategy

- **ALWAYS read source files directly, line-by-line.** Correctness bugs (null-deref, type-width mismatch, encoding disagreement, off-by-one recursion) live in details a summary drops. NEVER delegate correctness-critical files (untrusted-input parsing, pointer derefs, type conversions, hot paths) to a summary helper.
- ≤5 files AND ≤2k lines: read all in one parallel batch.
- \>5 files OR \>2k lines: read highest-risk files directly; grep-scan low-risk (build config, test-only, docs).
- **Data-encoding / type-width / struct-layout changes**: `Grep` ALL consumers of the changed field and read each — producer and consumer MUST agree on the encoding.
- Modified files (not new): changed regions + 20 lines context + immediate callers via `Grep`.

## Step 3 — Single-Pass Scan

"Single pass" = read each in-scope file **once**, holding all lens checks simultaneously. NEVER re-read the same file multiple times in one iteration (the re-grill in Step 6.3 is a new iteration, not a multi-pass). For ">5 files" where some are grep-scanned: that is still one pass — each file touched once.

IF a finding is suspected but unconfirmed (needs runtime to verify — e.g. "this pointer might be null but only at runtime"): write a minimal test or build+run to confirm BEFORE reporting it as `[CRITICAL]`/`[GAP]`. If you cannot confirm it this pass: mark `[UNCLEAR]` with the evidence + the verification needed. NEVER report a speculative finding as confirmed.

| Lens | W5H | Ask |
|---|---|---|
| Behavior | What | inputs/outputs specified; edge cases handled; failure modes caught |
| Correctness | What/How | logic matches intent; no off-by-one, inverted ratios, wrong signs |
| Memory-safety | What/Where | null-deref on untrusted input; use-after-free; buffer overflow/underflow; dangling pointers from moved/evicted objects; null children in recursive structures — does the builder propagate null up (reject whole structure) or create a partial structure that silently misbehaves? |
| Input-boundary | Where/Who | untrusted input validated at entry boundary with LOG+skip (NEVER abort/CHECK); guards at boundary, not scattered redundantly inside; every nullable external field checked before deref; asymmetric guards (one sibling guarded, other not) are a red flag |
| Type/encoding | How | type-width changes verified against ALL consumers — producer and consumer agree on bit layout; truncation guards on narrowing casts; bitmask-vs-index confusion |
| Callers/owners | Who | who calls this function / who provides the input / who owns the lifecycle; are ALL callers updated when a signature/return/contract changes; does an untracked caller exist outside the changed files; is ownership clear (who allocates, who frees) |
| Path-conditions | When | under what conditions does this code path fire; when is a pointer null vs guaranteed-non-null; when does eviction/expiry/reset happen; when is a guard redundant (boundary already guarantees it) vs needed (test bypasses boundary); state the precondition for each deref |
| Rationale | Why | why was this change made — is the reason documented in commit/PR/comment; why this approach over alternatives; why is this guard/check/field present (not just absent); does the rationale still hold given the current code; a change without a stated why is a `[GAP]` |
| Consistency | What | plan↔impl↔tests↔docs agree; rationale matches current numbers; validation claims match source |
| Security | What | injection, authz, secrets, path traversal, unsafe deserialization |
| Scale/Perf | How | concurrency, retries, hot paths, quadratic loops |
| Completeness | What | every requirement mapped; every error path handled; tests cover non-happy paths; null-input tests for every external-data entry point |

**External refs (conditional):** Jira `[A-Z]+-\d+` or Confluence `netskope.atlassian.net/wiki/…` present → fetch via `jira`/`confluence` skill or CLI. Contradicts artifact → `[CRITICAL]`. Claimed resolved but open / missing doc'd caveat → `[GAP]`. NEVER fetch refs not present in artifacts.

## Step 4 — Findings

- `[CRITICAL]` — wrong behavior, security flaw, data loss, logic error. Blocks.
- `[GAP]` — missing case/test/doc. Must address.
- `[UNCLEAR]` — ambiguous; needs clarification.
- `[SMELL]` — suspicious, not wrong.
- `[QUESTION]` — needs user decision.

State directly, NEVER hedge. Cap 20 findings/iteration — when over cap, drop lowest-severity `[SMELL]`s first; NEVER drop a `[CRITICAL]` or `[GAP]` to stay under the cap. Every row cites evidence (file:line). Stable ID `F<n>` per finding — persists across iterations.

| ID | Sev | File:Line | Evidence | Finding | Fix/Action |
|----|-----|-----------|----------|---------|------------|

## Step 5 — Verdict

- **PASS** — no CRITICAL/GAP.
- **CONDITIONAL PASS** — GAP/UNCLEAR only.
- **FAIL** — any CRITICAL.

## Step 6 — Fix-and-Regrill Loop (iterate until PASS)

1. **PASS** → stop.
2. **Non-PASS** → fix **ALL** findings in severity order (`CRITICAL`→`GAP`→`UNCLEAR`→`SMELL`; skip unactionable `[SMELL]`). Apply with `Edit`/`Write`. State each fix.
   - **Verify before re-grill**: MUST build + run tests/linters (the project's actual verification). NEVER declare fixed from code-reading alone — a fix is not done until tests pass. Build/test failure = fix introduced a bug → fix NOW (same iteration); a fix that breaks the build is itself `[CRITICAL]`.
   - **Same-pass ripple check**: after each fix, `Grep` callers/consumers of the changed code — confirm the fix doesn't break them (null-return where callers didn't expect null, return-type change, field widen/narrow). Do NOT defer to next iteration.
3. **Re-grill** — COMPLETELY FRESH full scan, NOT a delta of the last pass:
   - Re-run Step 1 (in-scope set may grow with newly-modified files).
   - Re-read ALL in-scope files' actual content — NEVER from memory or last pass's output.
   - Run every lens on every in-scope file as if first time — do NOT skip previously-fixed areas; re-confirm fixes hold and introduced no new defect.
   - Reconcile prior `F<n>`: FIXED / STILL-BROKEN / superseded. Assign NEW `F<n>` to newly-found findings (including fix-induced defects in areas not flagged before).
   - Output table = fresh scan result, not a delta.
4. **Repeat** 5–6 until **PASS**.
5. **Safety cap — 6 iterations.** Not PASS after 6 → STOP, surface remaining findings + unresolved IDs.
6. **`[QUESTION]` findings**: do not auto-fix; surface them, fix the rest, let user resolve. Leftover `[QUESTION]` alone does not block PASS if no CRITICAL/GAP remains.

## Invariants

1. Read actual content — NEVER from memory or a prior pass's output.
2. Every finding: ID + evidence + actionable fix. ≤20/iteration.
3. Fix ALL findings each non-PASS iteration — not just CRITICALs.
4. Build + test after every fix iteration — never declare fixed from code-reading alone.
5. Correctness-critical files read line-by-line — NEVER delegated to a summary helper.
