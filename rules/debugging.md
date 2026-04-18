**7.1 Run Binary Over Re-Tracing** — Analysis says X, tests say Y, re-reading unresolved: MUST run binary with minimal inputs. NEVER re-trace code 3rd+ time.

**7.2 Use CLI Tools Directly** — MUST use `docker logs`, `kubectl logs`, `jq`, `psql`, `gh`, etc. NEVER ask user to paste output Claude can read.

**7.3 Verify Process Freshness** — Before analyzing logs from recently-changed service: MUST verify instance started AFTER latest changes. Stale → restart first. NEVER assume running process reflects latest code.

**7.4 Autonomous Bug Fixing** — Bug report: MUST fix. MUST point at logs/errors/failing tests then resolve without prompting. NEVER say "I found the issue, would you like me to fix it?"

**7.5 Two-Attempt Limit** — Same fix/strategy/grep fails twice: MUST STOP — NEVER attempt 3rd retry same approach. MUST `AskUserQuestion` with: (1) tried, (2) failed, (3) alternatives.

**7.6 Multi-Channel Input Debugging** — Debugging hook/callback/subprocess/plugin where expected input empty:
1. MUST dump ALL input channels simultaneously FIRST attempt: stdin (`STDIN_DATA=$(cat)`), env vars (`env | grep -i <prefix>`), positional args (`"$@"`), file-based channels
2. NEVER test one channel at a time
3. MUST read source of analogous working component to verify expected channel BEFORE hypothesizing; NEVER assume channel by analogy across event types
