---
name: writing-tests
description: Use when writing, reviewing, or fixing any test, or when asked to "just make CI green" under time pressure — symptoms include tests named after input shapes instead of scenarios, tests that only chase line/branch coverage, a failing test being patched without knowing why, or code changed to match a test's expected value.
---

# Writing Tests

## Overview

Tests must catch real defects, not turn a coverage bar green. High line coverage doesn't imply correctness (Fowler's "assertion-free testing" trap; Google Testing Blog: coverage is a diagnostic signal, not a quality guarantee). Design from **behavior/requirements outward**, not code control-flow inward.

## When to Use

- Writing tests for implemented logic
- Reviewing a test suite for gaps
- A test fails and you're deciding what to change
- Told to "just get CI green" fast — exactly when standards slip

## Core Standards

**1. Functional over code coverage.** Derive cases from spec/requirements first; use code coverage only as a gap-finder after. 100% line coverage with no behavioral assertions is worthless. Per function: list its business rules, test each rule plus its boundaries — not one test per `if` branch.

**2. Real-world cases, not abstract ones.** Name tests after the scenario, not the input shape. Use production-like data, not `"foo"`/`42`/`{}`. If you can't describe the test in one sentence a product owner would recognize, it's testing the code, not the feature.

```python
# Abstract
def test_case_1():
    assert calculate_discount(100, "gold", 11) == 80.0

# Real-world
def test_gold_customer_over_10_orders_gets_20_percent_off():
    assert calculate_discount(price=100, customer_tier="gold", order_count=11) == 80.0
```

**3. Never fabricate a result.** Never report a test passing without running it and showing output. Never write a trivially-true assertion (`assert True`) to force green. Never weaken, delete, or comment out a failing assertion, or silently patch production code to match a test's expected value, without first identifying which side is wrong. A red test is information — making it green without understanding why is the fabrication.

**4. Root cause before touching either side.** On failure, determine whether the test's expectation or the code's behavior is wrong before editing anything (see `superpowers:systematic-debugging`). State the root cause with evidence ("spec says 10% off, test asserts 40, correct value is 45"). Genuinely ambiguous, or touches a business/pricing/security rule you can't verify — ask the user (`AskUserQuestion`). No user channel: don't guess — lock in current behavior and flag the ambiguity in your report. Unambiguous (typo, arithmetic error, stale fixture): fix it and say so.

**5. Grill before declaring done.** After writing or fixing tests, invoke `/grill` on the test file(s). Fix every `[CRITICAL]`/`[GAP]` it surfaces before reporting complete.

## Test Smells to Reject

| Smell | Looks like | Fix |
|---|---|---|
| Assertion Roulette | 5+ unlabeled asserts in one test | One behavior per test |
| Mystery Guest | Depends on hidden external file/DB state | Inline the fixture |
| Redundant assertion | `assert 1 == 1`, asserting a mock's own return | Assert real behavior |
| The Mockery | Everything mocked; verifies the mock, not the code | Mock only true boundaries |
| Eager/Lazy Test | Tests unrelated behaviors, or many tests share one assert | Match scope to one rule |
| Flaky | `sleep()`, real clock/network, race conditions | Control time/IO explicitly |

## Common Mistakes

- Tests written after seeing the code just restate it instead of the requirement
- Skipping boundary values (`>` vs `>=`) — where real bugs live
- Treating "tests pass" as "feature works" without checking assertions encode the requirement
- Fixing a test to match a bug instead of asking if the bug is real

## Related

- **REQUIRED BACKGROUND for failures:** `superpowers:systematic-debugging`
- `superpowers:test-driven-development` — writing tests before the implementation exists
- `testpilot` — end-to-end workflow (generate → spec `testing.md` → sync); this skill governs what makes each test good
