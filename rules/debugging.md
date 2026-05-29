**7.1 Run Binary Over Re-Tracing** — Analysis says X, tests say Y, re-reading unresolved: MUST run binary with minimal inputs. NEVER re-trace code 3rd+ time.

**7.2 Use CLI Tools Directly** — MUST use `docker logs`, `kubectl logs`, `jq`, `psql`, `gh`, etc. NEVER ask user to paste output Claude can read.

**7.3 Verify Process Freshness** — Before analyzing logs from recently-changed service: MUST verify instance started AFTER latest changes. Stale → restart first. NEVER assume running process reflects latest code.

**7.4 Autonomous Bug Fixing** — Bug report: MUST fix. MUST point at logs/errors/failing tests then resolve without prompting. NEVER say "I found the issue, would you like me to fix it?"

**7.5 Two-Attempt Limit** — Same fix/strategy/grep fails twice: MUST STOP — NEVER attempt 3rd retry same approach. MUST `AskUserQuestion` with: (1) tried, (2) failed, (3) alternatives.

**7.6 Multi-Channel Input Debugging** — Debugging hook/callback/subprocess/plugin where expected input empty:
1. MUST dump ALL input channels simultaneously FIRST attempt: stdin (`STDIN_DATA=$(cat)`), env vars (`env | grep -i <prefix>`), positional args (`"$@"`), file-based channels
2. NEVER test one channel at a time
3. MUST read source of analogous working component to verify expected channel BEFORE hypothesizing; NEVER assume channel by analogy across event types

**1.5 Log/Output First-Read** — When debug logs available, MUST read+analyze BEFORE adding new instrumentation. NEVER add LOG statements to investigate if existing logs/init messages already hold relevant diagnostics. Init log lines (e.g., `segment_size=N`, `max_segments=N`) MUST be checked before assuming code is the problem.

**12.8 Config Before Code** — IF bug manifests as wrong counts/limits/sizes explainable by a config parameter (segment size, window depth, queue limit, threshold): MUST read runtime config file and log actual param values FIRST. NEVER refactor code to fix what a config change solves. Check config → verify behavior → only touch code if config correct.

**2.16 Regression Test Validation** — IF adding tests for a bug fix:
1. MUST trace each test against BOTH pre-fix and post-fix logic BEFORE declaring valid
2. Each bug-coverage test MUST distinguish: pre-fix code FAILS, post-fix PASSES
3. NEVER write a test, observe it passes against current (post-fix) code, then declare it validates the fix — proves nothing
4. MUST retrieve pre-fix logic via `git show <ref>:<path>` or `git log -p` — NEVER revert working code to "see if test fails"
5. Test can't distinguish pre/post-fix → MUST label `regression-guard` (not bug-coverage) OR rewrite
6. Report MUST include per-test pre-fix vs post-fix outcome table when claiming tests validate a fix

DO NOT conflate "test passes" with "test would have caught the bug."

**2.17 Establish Baseline Before Fixing** — Before ANY code/config change to fix a test failure:
1. MUST run full failing suite on unmodified code, record exact failure set
2. NEVER assume prior-session results current — run fresh
3. NEVER declare from cached run — verify cache bypassed (`--skip_cache`, fresh server restart)
4. Baseline is the reference; NEVER modify code without knowing exact starting failure count
