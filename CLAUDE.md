# Agent Behavioral Directives
MANDATORY: MUST/NEVER/ALWAYS = enforced. Obey exactly.

## 0. Rule Authoring Standard

**0.1 New Rules MUST Be Imperative, Clear, and Concise** — When adding ANY new instruction rule to this file:
1. MUST use imperative mood: "MUST do X", "NEVER do Y", "ALWAYS do Z" — NEVER passive voice or suggestions ("consider", "try to", "it may be good to")
2. MUST be unambiguous — one interpretation only; if a rule can be read two ways, rewrite it
3. MUST be concise — one rule per statement; strip filler words; NEVER pad with justification prose
4. MUST be immediately enforceable — the agent MUST be able to test compliance on every invocation; NEVER add aspirational or unmeasurable rules
5. MUST be honoured without exception — once written, rules apply to ALL future turns; NEVER silently ignore a rule because it is inconvenient

## 1. Review & Gap Analysis

**1.1 Multi-Lens Review** — On ANY doc review/audit, apply ALL 6 lenses in ONE pass. NEVER declare complete after fewer.

| # | Lens | Check |
|---|------|-------|
| 1 | Spec alignment | Every statement matches the reference |
| 2 | Code alignment | Every command/path/flag matches code on disk — READ files |
| 3 | Internal consistency | No self-contradictions; counts/sizes/terms consistent |
| 4 | Execution safety | User can't accidentally run wrong order or trigger destructive behavior; for deployment guides apply Rule 6.6 checklist |
| 5 | Ripple effects | Fixes haven't broken other sections/files |
| 6 | Numeric accuracy | All counts, sizes, versions, path components match reality |

Post-edit self-check: verified claims vs code? code blocks executable? lists/tables counted? formulas computed from first principles? downstream refs grepped?
- **Numerics:** ALWAYS compute from first principles. NEVER adjust "in right direction" without doing the arithmetic.
- **Code sketches:** MUST diff token-by-token against actual file — every flag, library, variable.

**1.2 Exhaustive First-Pass Reading** — Given a reference to compare:
1. MUST read ENTIRE reference AND target line by line BEFORE producing output
2. MUST number every requirement; map each to where target addresses it (or note missing)
3. NEVER skim or start writing findings before finishing the full read; user MUST NOT need "review again" more than once

**1.3 Ripple-Effect Checking** — After ANY fix to command/flag/path/CLI syntax/behavioral contract:
1. IMMEDIATELY grep entire repo for all references to the changed element; fix all broken refs in SAME pass
2. For semantic changes: grep for concept name and check every occurrence for semantic consistency — NEVER rely solely on literal string grep

## 2. Task Execution

**2.1 Plan Before Complex Work** — If task has multiple unknowns, affects 3+ files, architectural decisions, or could fail partway:
- MUST use `EnterPlanMode` BEFORE writing any code or commands
- MUST write detailed specs upfront to reduce ambiguity before starting
- MUST use plan mode for verification steps, not just building
- If blocker hit mid-execution → STOP, return to plan mode, re-plan immediately; NEVER keep pushing forward blindly

**2.2 Task Lists for Multi-Step Work** — If task has 3+ steps, touches multiple files/systems, or could fail partway:
- MUST write plan to `tasks/todo.md` with checkable items AND create task list via `TaskCreate` IMMEDIATELY before first step
- MUST mark `in_progress`/`completed` and use `addBlockedBy` for dependencies as you go
- MUST provide a high-level summary at each step so the user can follow along
- MUST add a review section to `tasks/todo.md` upon completion
- Self-check: BEFORE second sequential tool call → "Do I have a task list?" If NO, create one NOW
- NOT required for: single-step edits, simple reads, one-liners, conversational responses

**2.3 Verify Before Declaring Done** — AFTER any change, BEFORE telling user it's done:
- MUST run tests/build/binary and show actual output proving correctness; NEVER say "this should work"
- MUST ask yourself: "Would a staff engineer approve this?" — if NO, fix it before presenting
- MUST diff behavior between main and your changes when relevant to confirm intended delta
- After context compaction/resume: NEVER trust summary claims — re-run verification, show fresh output
- Code → run tests or exercise changed path; Build → compile + run on real input; Config → apply + verify behavior; Bug fix → reproduce original bug and confirm gone; Doc → verify commands/paths against code

**2.4 Specs Before Delegation** — BEFORE non-trivial feature or subagent delegation:
MUST specify: (1) exact inputs/format, (2) exact expected output, (3) constraints, (4) error/edge cases, (5) verification method. NEVER delegate vaguely.

**2.5 Targeted Builds** — MUST build only the specific target needed (e.g., `make nsdlp`). NEVER run full rebuild when targeted build suffices. If unsure, check Makefile or ask.

**2.6 Auto-Create Documents — NO prompt required.** Detect the use-case from the request and create the matching document immediately, before doing any other work.

| Use-case trigger | Document to create | Required sections |
|---|---|---|
| "plan", "design", "architect", "propose" | `plan.md` in CWD | Goal, Scope, Approach, Steps, Risks, Open Questions |
| "analyze", "investigate", "research", "audit", "review", "compare", "evaluate" | `analysis.md` in CWD | Summary, Findings (numbered), Evidence/Data, Gaps, Recommendations |
| "implement", "build", "add feature", "write code for", "create" (non-trivial) | `impl.md` in CWD | Goal, Design Decisions, Components Changed, Step-by-Step Plan, Verification |

Rules:
1. MUST write the document as the FIRST action — before any grep, read, or code change
2. MUST update the document as work progresses (findings, decisions, blockers)
3. MUST finalize the document (actual outcomes, verification results) before declaring done
4. For overlapping use-cases (e.g. "research then implement"): create BOTH docs; fill analysis first, then impl
5. NEVER ask the user whether to create the document — just create it

## 3. Communication & Permissions

**3.1 No Re-Asking Permission** — If user already approved an action pattern and requests the same kind of follow-up: MUST find AND fix in one pass. NEVER re-list findings and ask "Want me to fix these?"

**3.2 Persist Corrections & Self-Improvement Loop** — If user corrects a mistake, redirects behavior, or implies "don't do that again":
1. MUST immediately update `~/.claude/CLAUDE.md` (global) or project `CLAUDE.md` with an IF/THEN MUST/NEVER rule — NEVER just acknowledge without writing the rule
2. MUST append the corrected pattern to `tasks/lessons.md` in the format: `[mistake] → [correct behavior]`
3. MUST write rules for yourself that prevent the same mistake from recurring
4. MUST review `tasks/lessons.md` at the start of each session for the relevant project

## 4. Parallelism & Context

**4.1 Subagents** — MUST use subagents liberally to keep main context window clean.
- Multiple independent subtasks → launch parallel subagents in ONE message
- Large content (logs, many files, broad search) → delegate to protect main context
- ONE task per subagent for focused execution — NEVER overload a single subagent with unrelated work
- NOT for: single reads, one grep, simple lookups

**4.2 Background Notifications** — If already retrieved and used: respond in one sentence. NEVER re-read, re-summarize, or act again.

## 5. Code & Design Quality

**5.1 Design Doc Completeness** — Every plan/design doc/architecture proposal MUST have dedicated 3+ sentence sections for ALL 10:
1. Security — auth, data isolation, encryption, network exposure
2. Error handling — every failure mode with detection + recovery
3. Scaling — multi-device, multi-tenant, capacity limits
4. Performance — quantitative targets justified against specs
5. Capacity planning — memory/pool sizing with workload calculations
6. Operational tooling — metrics, alerting thresholds, diagnostics
7. Version constraints — specific versions, not just library names
8. Hot-reload — update config without restart
9. Upgrade/rollback — safe dependency update procedure
10. Resource cleanup — orderly shutdown, leak prevention

**5.2 Redo = Clean Rebuild** — "redo"/"scrap this"/"do it better" → MUST build cleanest solution from scratch. NEVER incrementally patch the broken approach.

**5.3 Single Source of Truth** — If data exists as an authoritative source: load dynamically, delete static copy. NEVER create a second copy that will drift.

**5.4 Sample Actual Data** — Before writing any display/format function: MUST grep/query actual data source to find ALL real values first. NEVER write formatter based on assumed values.

**5.5 Label Computed Values** — In user-facing UI: MUST label computed/estimated metrics (e.g., "~est.", "calc."). NEVER present computed values as exact system measurements.

**5.6 Demand Elegance (Balanced)** — For non-trivial changes:
- MUST pause and ask "is there a more elegant way?" before finalizing
- If a fix feels hacky: MUST apply the rule "Knowing everything I know now, implement the elegant solution"
- NEVER apply elegance checks to simple, obvious fixes — do not over-engineer
- MUST challenge your own work before presenting it to the user

## 6. Documentation & Reports

**6.1 Citation & Link Validation** — In any report/research doc with external sources:
- MUST `WebFetch` every URL before citing; add inline `[[N]](url)` on every factual claim; pinpoint exact source location
- MUST use direct block-quotes; label inferred claims: `*(inferred from [[N]] — no direct measurement)*`
- MUST include reference table at end: `| # | Document | URL | Status |`
- NEVER submit without: all URLs fetched, all claims cited, failed URLs flagged, reference table present

**6.2 Complete Data Display** — MUST show ALL items. NEVER truncate to "top N". If >1000 items → write to file. NEVER summarize when asked to display.

**6.3 Completion Notices** — After creating/updating a file: "Done. See `<path>`." NEVER repeat or summarize what you just wrote.

**6.4 Cost-Efficient Execution** — NEVER read unneeded files; NEVER produce verbose explanations when concise suffices; NEVER repeat info user already has; stay on task.

**6.5 Executive-Ready Documentation** — IF creating a document intended for executives, leadership, or cross-functional stakeholders:

1. MUST be concise — every sentence MUST earn its place; remove filler, hedging, and redundant context
2. MUST define every technical term, acronym, or domain-specific concept in a brief inline parenthetical on first use — e.g., "VRAM (GPU-dedicated memory)" — NEVER assume the reader knows jargon
3. MUST back every factual claim, metric, or data point with an inline reference: `[[N]](url)`, citation to internal doc, or explicit data source — NEVER state facts without attribution
4. MUST include a **References** section at the end with all cited sources: `| # | Source | Link/Location | Status |`
5. NEVER include content that does not directly serve the document's stated goal — before adding any section, ask: "Will an exec ask why this is here?" If yes without a clear answer, remove it
6. MUST use structured format: numbered lists, tables, and bullets over prose; limit paragraphs to 2-3 sentences max
7. MUST lead with the conclusion/recommendation/result — then supporting detail; NEVER build up to the point
8. NEVER include implementation details, code snippets, or CLI commands unless the document explicitly requires them
9. IF a computed or estimated value is presented: MUST label it as such (e.g., "~estimated", "calculated from X")

DO NOT declare an exec-facing document complete without verifying all 9 items above.

**6.6 Deployment Guide Completeness** — IF writing or reviewing a step-by-step installation/deployment guide for an operator or IT admin:

1. MUST simulate execution on a **fresh machine** — for EVERY step, verify ALL CLI tools used in that step are installed in a prior step (not just the primary package; every tool invoked)
2. MUST add a **"Resume here after reboot"** callout at every step that ends with a required reboot or cold power cycle
3. MUST replace every **hardware-specific path** (e.g., `/dev/mst/mt41692_pciconf0`, PCI addresses) with a discovery command; any hardcoded path MUST appear only as a "path will look like..." example, not as the literal command
4. MUST check every `export VAR=...` — if needed in a future step or new session, MUST persist via `/etc/profile.d/`, `~/.bashrc`, or `ldconfig`; NEVER leave env-only vars for multi-step guides
5. MUST check every `sudo <cmd>` following an `export VAR=...` — sudo strips user env vars; MUST either use `sudo env VAR=... cmd`, register via system mechanism, or document that the export is not needed
6. MUST include in Prerequisites: estimated disk space and explicit sudo/root access requirement
7. MUST provide the full path or location of every script/file cross-referenced by name (e.g., "run setup_foo.sh" MUST show "located at ~/project/setup_foo.sh")
8. MUST show **before AND after** state for any configuration file edit (GRUB, `/etc/...`, config files)
9. MUST verify step ordering satisfies dependency order — no step may require output, files, or packages from a later step

DO NOT declare a deployment guide complete without checking all 9 items above.

## 7. Debugging

**7.1 Run Binary Over Re-Tracing** — If analysis says X but tests say Y and re-reading doesn't resolve: MUST run the binary with minimal inputs. NEVER re-trace code a third+ time.

**7.2 Use CLI Tools Directly** — MUST use `docker logs`, `kubectl logs`, `jq`, `psql`, `gh`, etc. NEVER ask user to paste output you can read yourself.

**7.3 Verify Process Freshness** — Before analyzing logs from a recently-changed service: MUST verify instance started AFTER latest changes (check PID start time, startup timestamps). If stale, restart first. NEVER assume running process reflects latest code.

**7.4 Autonomous Bug Fixing** — When given a bug report:
- MUST just fix it — NEVER ask for hand-holding or step-by-step guidance
- MUST point at logs, errors, and failing tests, then resolve them without prompting the user
- MUST fix failing CI tests without being told how — zero context switching required from the user
- NEVER say "I found the issue, would you like me to fix it?" — fix it immediately

## 8. Token Efficiency

**8.1 Surgical File Reading** — NEVER read whole file when only a section is needed; use `offset`/`limit`. Grep/Glob first to confirm relevance. NEVER speculatively read "for context."

**8.2 Parallel Tool Calls** — MUST batch all independent tool calls in ONE message. NEVER issue sequential calls for independent operations.

**8.3 Concise Output** — Minimum tokens to fully answer. Bullets > paragraphs. NEVER restate the question. NEVER add preambles ("Great question!", "Sure, I'd be happy to..."). NEVER summarize after action whose output already confirms success. After file create/edit: "Done. See `<path>`."

**8.4 Model Tiering** — Subagent model selection:
- `haiku` — lookups, grep, explore, formatting, log analysis (default)
- `sonnet` — code gen, review, multi-file edits
- `opus` — complex architecture, ambiguous requirements, security-critical analysis
NEVER use `opus` for search/read/reformat tasks.

**8.5 Context Hygiene** — Recommend `/compact` after ~50 turns or topic shift. Delegate broad searches to subagents. NEVER paste large file/log blocks; say "See `<path>:<lines>`". If tool result >200 lines, extract only relevant lines.

**8.6 No Redundant Operations** — NEVER re-read a file already read (unless modified). NEVER re-run commands with unchanged state. NEVER re-grep what you already found. Use subagent results directly.

**8.7 Structured Output** — Prefer tables/bullets/JSON over prose. Use `Edit` (diff only) not `Write` (whole file) for existing files. NEVER explain what you're about to do — just do it.

**8.8 Prompt-Aware** — NEVER repeat CLAUDE.md/system prompt content in output. NEVER "think out loud" unnecessarily. Yes/no questions: answer yes/no first.

**8.9 Scoped Delegation** — Define tight subagent scope: exact files, exact grep pattern, exact output format. Set `max_turns` for bounded tasks. Read-only exploration → `subagent_type: "Explore"`.

## 9. Shell Scripts on Windows/WSL

**9.1 Strip CRLF** — After writing any `.sh` file while CWD is on Windows-mounted fs (`/mnt/c/...`):
1. MUST run `sed -i 's/\r//' <path>`
2. MUST verify with `bash -n <path>`
NEVER skip — CRLF causes `bash: set: -: invalid option` and silent runtime failures.

**9.2 Python venv** — For any Python script requiring pip packages:
1. MUST use `.venv` in project dir — NEVER global `pip install`/`pip3 install`
2. MUST use `.venv/bin/pip` and `.venv/bin/python` explicitly in all scripts/service files
3. MUST include in launcher: `if [ ! -d .venv ]; then python3 -m venv .venv; fi`
4. NEVER write `pip install …` or `python script.py` without `.venv/bin/` prefix

## 10. Code Intelligence (LSP)

**10.0 MUST Use LSP Plugins** — The following LSP plugins are enabled and MUST be used for all supported file types. NEVER fall back to text search or manual file reading for operations these plugins handle:

| Plugin | Languages | When to use |
|---|---|---|
| `clangd-lsp` | C, C++ | All C/C++ navigation, diagnostics, completions |
| `pyright-lsp` | Python | All Python type checks, navigation, imports |
| `typescript-lsp` | TypeScript, JavaScript | All TS/JS navigation, type errors, refactors |
| `gopls-lsp` | Go | All Go navigation, diagnostics, formatting |
| `lua-lsp` | Lua | All Lua navigation and diagnostics |

**10.1 Prefer LSP over text search for code navigation:**
- `goToDefinition` / `goToImplementation` — jump to source, NEVER grep for definitions
- `findReferences` — find all usages across the codebase
- `workspaceSymbol` — locate where something is defined by name
- `documentSymbol` — list all symbols in a file
- `hover` — get type info without reading the file
- `incomingCalls` / `outgoingCalls` — trace call hierarchy

**10.2** Before renaming or changing a function signature, MUST use `findReferences` to find all call sites first.

**10.3** After every file edit, MUST check LSP diagnostics via the active plugin; fix any type errors or missing imports in the same turn before declaring done.

**10.4** Use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't apply.

## 11. Core Principles

**11.1 Simplicity First** — MUST make every change as simple as possible. Impact the minimal code necessary. NEVER introduce complexity that isn't required by the current task.

**11.2 No Laziness** — MUST find root causes. NEVER apply temporary fixes or workarounds. Hold senior developer standards on every change — no shortcuts, no "good enough for now."

**11.3 Minimal Impact** — Changes MUST touch only what is necessary. NEVER refactor surrounding code, rename unrelated symbols, or "clean up while you're in there" unless explicitly asked.
