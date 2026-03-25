---
name: healthcheck
description: Use when invoked as /healthcheck to diagnose Claude Code environment health. Validates settings.json allow patterns, MCP server connectivity, hook script existence, PATH tool availability, and CLAUDE.md line counts. Auto-fixes what it can; outputs manual fix instructions for the rest. Ends with a color-coded health summary.
---

# Healthcheck

## Overview

Diagnose the Claude Code environment and report issues with actionable fixes. Always run at session start if environment feels broken. Ends with GREEN / YELLOW / RED verdict.

## Procedure

Work through each check in order. Collect all findings before printing the summary.

---

### 1. Settings — Allow Pattern Validation

Read **both** settings files (skip gracefully if absent):
- `~/.claude/settings.json` (global)
- `.claude/settings.json` (project, if CWD has one)

For each file, check `permissions.allow`:

| Pattern to verify | Expected |
|---|---|
| `Edit` or `Edit(/root/.claude/**)` | Edit unrestricted OR `.claude/` explicitly covered |
| `Write` or `Write(/root/.claude/**)` | Same as Edit |
| `Bash` | Present |
| `mcp__plugin_slack_slack__*` | Present if Slack plugin enabled |
| `mcp__plugin_context-mode_context-mode__*` | Present if context-mode enabled |
| `mcp__plugin_context7_context7__*` | Present if context7 enabled |

Cross-check: for every plugin in `enabledPlugins` where value is `true`, verify a matching `mcp__plugin_<name>__*` allow pattern exists.

**Auto-fix:** If a pattern is missing and the file is writable via Bash, add it with:
```bash
jq '.permissions.allow += ["<missing-pattern>"]' ~/.claude/settings.json > /tmp/s.json && \cp /tmp/s.json ~/.claude/settings.json
```
> NOTE: Never use `tee` to write back to the same file — it truncates the file before jq reads it.

---

### 2. MCP Servers — Connectivity Check

From `enabledPlugins` (global settings), identify all enabled plugins. For each, attempt to list its tools using `ListMcpResourcesTool` or by checking if the plugin's tools appear in the available tool list.

Report:
- ✅ Connected — tools visible
- ❌ Failed — tools not visible (likely auth or config issue)

**Manual fix template** (if MCP fails to connect):
```
Check: claude mcp list
Restart: claude mcp restart <server-name>
Re-auth: follow plugin-specific OAuth/token flow
```

---

### 3. Hooks — Script Existence and Executability

Read `hooks` section from `~/.claude/settings.json`. For every hook `command`:

1. Extract the script path (first token if it's `node <path>` or `bash <path>` etc.)
2. Check the script exists: `ls <path>`
3. Check it's executable (for shell scripts): `test -x <path>`

Report each hook with: script path, exists (✅/❌), executable (✅/❌).

**Auto-fix** missing executable bit:
```bash
chmod +x <path>
```

---

### 4. PATH Tools

Run each check and report ✅ / ❌:

```bash
which powershell.exe 2>/dev/null && echo OK || echo MISSING
which jq            2>/dev/null && echo OK || echo MISSING
which git           2>/dev/null && echo OK || echo MISSING
which make          2>/dev/null && echo OK || echo MISSING
```

**Manual fix** for missing tools:
- `jq`: `apt-get install -y jq`
- `git`: `apt-get install -y git`
- `make`: `apt-get install -y build-essential`
- `powershell.exe`: must be on Windows PATH and accessible from WSL via `/mnt/c/...` symlink

---

### 5. CLAUDE.md Line Count

Check both:
- `~/.claude/CLAUDE.md` (global)
- `CLAUDE.md` in CWD (project)

```bash
wc -l ~/.claude/CLAUDE.md
wc -l CLAUDE.md 2>/dev/null
```

- ✅ ≤ 200 lines
- ⚠️ 180–200 lines — approaching limit, consider moving content to topic files
- ❌ > 200 lines — content after line 200 is truncated and ignored

**Manual fix:** Move verbose sections to `.claude/rules/<topic>.md` and replace with `@.claude/rules/<topic>.md` import.

---

### 6. settings.json Integrity

```bash
jq empty ~/.claude/settings.json 2>&1 && echo VALID || echo INVALID
```

- ✅ Valid JSON
- ❌ Invalid / empty — restore from backup or rewrite (see `~/.claude/projects/*/memory/MEMORY.md` for last known good content)

---

## Health Summary

After all checks, print a single summary block:

```
╔══════════════════════════════════╗
║   Claude Code Health Check       ║
╠══════════════════════════════════╣
║ Settings allow patterns  [✅/❌] ║
║ MCP connectivity         [✅/❌] ║
║ Hook scripts             [✅/❌] ║
║ PATH tools               [✅/❌] ║
║ CLAUDE.md line count     [✅/❌] ║
║ settings.json integrity  [✅/❌] ║
╠══════════════════════════════════╣
║ Overall: GREEN / YELLOW / RED    ║
╚══════════════════════════════════╝
```

**Verdict rules:**
- 🟢 GREEN — all checks pass
- 🟡 YELLOW — 1–2 non-critical issues (missing optional tool, approaching line limit)
- 🔴 RED — any critical issue (empty/invalid settings.json, broken hook, missing Bash/Edit allow)

List all auto-fixes applied and any manual steps remaining.
