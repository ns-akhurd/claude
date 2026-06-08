---
name: verify-re
description: Use when implementing a rule engine feature end-to-end: plan → design → implement → grill → test (C++ gtests + Python compare_matrix + verify_rule_engine) → fix all issues → commit + push.
---

# verify-re — Rule Engine Feature Implementation Workflow

Full end-to-end implementation discipline for Gen3 rule engine features.
Follow every phase in order. NEVER skip or re-order phases.

---

## Phase 0 — Task Intake

1. Read task description. Extract:
   - What rule operator / behaviour is being added or fixed
   - Which files are likely affected (C++ sources, test files, scripts, docs)
   - Any linked Jira/doc references → fetch them

2. Create `tasks/todo.md` listing every item BEFORE reading any file.
   Format per item: `[ ] <file>:<component> — what to do`

3. Read `libs/dlp/rule_engine/docs/testing.md` to understand current test coverage and run commands.

---

## Phase 1 — Plan

1. Invoke **`EnterPlanMode`** and write `<feature>_plan.md` in CWD.
   Required sections: Goal, Scope, Approach, Steps, Risks, Open Questions.

2. For each component to touch:
   - Use LSP `goToDefinition` / `documentSymbol` (NEVER grep first for C++ symbols).
   - Trace call paths from entry point to affected logic.
   - State verdict: CORRECT / WRONG / INCOMPLETE — with evidence.

3. Get explicit user sign-off before exiting plan mode (`ExitPlanMode`).

---

## Phase 2 — Design (C++ API + Data Structures)

1. Define the exact C++ API change:
   - New/modified structs or methods with full signatures
   - Invariants that must hold
   - Thread-safety / lifetime requirements

2. Define postfix expression JSON changes (if any):
   - New operator token(s) in `postfix_expression` array
   - Confirm `validate_tsv_expectations.py` evaluator covers new operator

3. Write design notes into the `_plan.md` created in Phase 1.

4. Do NOT write any code yet — get user approval on design if non-trivial.

---

## Phase 3 — Implement

Follow CLAUDE.md rules strictly (12.1 simplicity, 12.3 minimal impact, 5.7 sibling symmetry).

1. Edit C++ sources. After every file edit:
   - Run LSP diagnostics; fix all type errors same turn.

2. Update `dlp_profiles.json` (tenant 1) if new rule types need test profiles.

3. Add/update `test-data/dlpsvc/rule_engine/cases/` data files if new test cases needed.

---

## Phase 4 — C++ Unit Tests (gtests)

1. Identify the relevant test suite in `libs/dlp/rule_engine/` test directory.

2. Add tests covering:
   - Happy path (rule fires as expected)
   - Miss path (rule does not fire)
   - Edge cases: empty window, null expr, out-of-range bitpos
   - Regression: any scenario from the bug report / Jira ticket

3. Build and run:
   ```bash
   make -C obj -j8 dlp_rule_engine_test
   make -C obj check-TESTS TESTS="dlp_rule_engine_test"
   ```

4. All tests MUST pass (0 failures) before proceeding.

5. Update test count in `libs/dlp/rule_engine/docs/testing.md` Coverage Summary table.

---

## Phase 5 — Python Integration Tests

### 5a. compare_matrix.py (operator matrix, 174 cases)

```bash
# Single-instance mode:
python3 libs/dlp/rule_engine/scripts/compare_matrix.py --single-instance --tenant 1

# Or two-instance mode if both ports available:
python3 libs/dlp/rule_engine/scripts/compare_matrix.py \
    --accum-port 9001 --engine-port 9002 --tenant 1
```

Expected: **174 passed, 0 failed**.

If failures: engine result must match `expect_hit` for every case.
Accumulator divergence is expected (Gen3 drains rules Gen2 misses).

### 5b. verify_rule_engine.py (Gen3 hit-count, 236 cases)

```bash
python3 libs/dlp/rule_engine/scripts/verify_rule_engine.py \
    --input libs/dlp/rule_engine/scripts/verify_cases.tsv \
    --interface asp --port 9001 --tenant 1
```

Expected: **236 passed, 0 failed**.

If the feature adds new test cases:
1. Add rows to `verify_cases.tsv` (or regenerate — see testing.md).
2. Run `validate_tsv_expectations.py` offline first to confirm expectations correct.
3. Re-run `verify_rule_engine.py` to confirm live counts match.

### 5c. validate_tsv_expectations.py (offline check)

```bash
python3 libs/dlp/rule_engine/scripts/validate_tsv_expectations.py
```

Expected: **0 fail** (annotated known-behaviour cases are OK).

---

## Phase 6 — Grill

Invoke the `grill` skill (via Skill tool) scoping to all files modified this session.

The grill skill will:
1. Read actual file content (not summaries).
2. Produce a severity-tagged findings table.
3. Render PASS / CONDITIONAL PASS / FAIL verdict.

**Rules for this phase:**
- Fix ALL `[CRITICAL]` findings before moving on.
- Fix ALL `[GAP]` findings.
- `[SMELL]` / `[QUESTION]` — address or document why deferred.
- After fixes, re-run affected tests to confirm still green.
- NEVER declare done until grill yields PASS or CONDITIONAL PASS with all GAPs resolved.

---

## Phase 7 — Final Test Run

Run all three test suites back-to-back and confirm green:

```bash
# 1. C++ unit tests
make -C obj check-TESTS TESTS="dlp_rule_engine_test"

# 2. Gen3 hit-count
python3 libs/dlp/rule_engine/scripts/verify_rule_engine.py \
    --input libs/dlp/rule_engine/scripts/verify_cases.tsv \
    --interface asp --port 9001 --tenant 1

# 3. Operator matrix
python3 libs/dlp/rule_engine/scripts/compare_matrix.py --single-instance --tenant 1
```

Report actual output. NEVER say "should work" — show the output.

---

## Phase 8 — Update Docs

1. `libs/dlp/rule_engine/docs/testing.md`:
   - Update Coverage Summary table (test counts).
   - Add Last Updated line at bottom.

2. `_plan.md` created in Phase 1:
   - Finalize with actual outcomes, resolved open questions.

---

## Phase 9 — Commit + Push

1. Stage only relevant files (NEVER `git add .` or `git add -A`).
2. Commit with Conventional Commits subject ≤50 chars:
   ```
   feat(rule_engine): <imperative summary>
   ```
   Body only if "why" is non-obvious or breaking change.
3. Push to current branch:
   ```bash
   git push origin <branch>
   ```
4. Report commit hash + pushed branch.

---

## Invariants

- NEVER skip Phase 6 (grill) — it catches integration bugs tests miss.
- NEVER commit with failing tests.
- NEVER push before grill yields PASS/CONDITIONAL PASS.
- NEVER re-read a file already read this session unless it was modified.
- Read-once discipline: use `tasks/todo.md` to drive file reads.
- All test output MUST be shown verbatim (last 10 lines minimum).
