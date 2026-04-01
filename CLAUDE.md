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
| 4 | Execution safety | User can't accidentally run wrong order or trigger destructive behavior; for deployment guides apply Rule 6.4 checklist |
| 5 | Ripple effects | Fixes haven't broken other sections/files |
| 6 | Numeric accuracy | All counts, sizes, versions, path components match reality |

Post-edit: MUST verify claims against code, confirm code blocks are executable, count lists/tables, compute formulas from first principles, grep downstream refs. **Numerics:** ALWAYS compute from first principles. NEVER adjust "in right direction" without doing the arithmetic. **Code sketches:** MUST diff token-by-token against actual file.

**1.2 Exhaustive First-Pass Reading** — MUST read ANY text (files, user messages, tool results, documents) line by line in full BEFORE producing output. NEVER skim. Given a reference to compare: (1) MUST read ENTIRE reference AND target line by line BEFORE producing output. (2) MUST number every requirement; map each to where target addresses it. (3) NEVER skim or start writing findings before finishing the full read.

**1.3 Evidence Provenance** — When asserting how code behaves: MUST state evidence source explicitly. MUST prefer actual output/data over code reading. NEVER present code-reading inferences as confirmed facts — label: "based on code at X" or "code shows Y (not empirically confirmed)".

**1.4 Ripple-Effect Checking** — After ANY fix to command/flag/path/CLI syntax: (1) IMMEDIATELY grep entire repo for all references; fix all broken refs in SAME pass. (2) For semantic changes: grep for concept name — NEVER rely solely on literal string grep.

## 2. Task Execution

**2.1 Plan Before Complex Work** — If task has multiple unknowns, affects 3+ files, or could fail partway: MUST use `EnterPlanMode` BEFORE writing any code. MUST write detailed specs upfront. If blocker hit mid-execution → STOP, return to plan mode immediately; NEVER keep pushing forward blindly.

**2.2 Task Lists for Multi-Step Work** — If task has 3+ steps, touches multiple files/systems, or could fail partway:
- MUST write plan to `tasks/todo.md` AND create task list via `TaskCreate` IMMEDIATELY before first step
- MUST mark `in_progress`/`completed` and use `addBlockedBy` for dependencies as you go
- MUST provide a high-level summary at each step; MUST add a review section upon completion
- Self-check: BEFORE second sequential tool call → "Do I have a task list?" If NO, create one NOW
- NOT required for: single-step edits, simple reads, one-liners, conversational responses

**2.3 Verify Before Declaring Done** — AFTER any change, BEFORE telling user it's done:
- MUST run tests/build/binary and show actual output; NEVER say "this should work", "should be correct", or "should pass"
- MUST diff behavior between main and your changes when relevant
- After context compaction/resume: NEVER trust summary claims — re-run verification, show fresh output

**2.4 Specs Before Delegation** — BEFORE non-trivial feature or subagent delegation: MUST specify: (1) exact inputs/format, (2) exact expected output, (3) constraints, (4) error/edge cases, (5) verification method. NEVER delegate vaguely.

**2.5 Targeted Builds** — MUST build only the specific target needed (e.g., `make nsdlp`). NEVER run full rebuild when targeted build suffices. If unsure, check Makefile or ask.

**2.6 Auto-Create Documents — NO prompt required.** Detect use-case and create the matching document immediately, before any other work.

| Use-case trigger | Document | Required sections |
|---|---|---|
| "plan", "design", "architect", "propose" | `plan.md` in CWD | Goal, Scope, Approach, Steps, Risks, Open Questions |
| "analyze", "investigate", "research", "audit", "review", "compare", "evaluate" | `analysis.md` in CWD | Summary, Findings (numbered), Evidence/Data, Gaps, Recommendations |
| "implement", "build", "add feature", "write code for", "create" (non-trivial) | `impl.md` in CWD | Goal, Design Decisions, Components Changed, Step-by-Step Plan, Verification |

MUST write doc FIRST — before any grep, read, or code change. MUST update as work progresses. MUST finalize with actual outcomes before declaring done. For overlapping use-cases: create BOTH. NEVER ask the user whether to create the document.

**2.7 "No Code Yet" Guard** — When iterating on any plan before implementation: MUST include "do not write any code yet" in every planning prompt until plan is approved. NEVER start implementation without explicit user sign-off.

**2.8 Hooks for Deterministic Enforcement** — MUST use hooks (not CLAUDE.md) for any action that must happen on every invocation without exception. NEVER rely on CLAUDE.md instructions alone to enforce required actions.

**2.9 Bulk File Operations** — For batch changes across 50+ files: MUST generate file list first, then loop `claude -p "Transform $file" --allowedTools <tools>`. MUST test on 2–3 files before running at scale. MUST use `--allowedTools` when running unattended.

**2.10 Artifact Placement** — IF writing any spec, plan, or analysis doc inside a user's project: (1) MUST place at project root or single-level `docs/` — NEVER create nested skill-convention paths. (2) IF skill specifies a different default path, MUST override with project root. (3) IF uncertain, MUST ask BEFORE writing.

**2.11 Scope-First Analysis** — When user references a specific file, function, or component: MUST constrain analysis to that exact target FIRST. NEVER search broadly or explore adjacent code before addressing the specified target. Expand scope ONLY on explicit request.

**2.12 Autonomous Execution** — NEVER instruct the user to run a command, execute a step, or perform an action that Claude can do directly with its tools. MUST execute all such steps autonomously. Exception: interactive actions requiring human input (e.g., browser-based auth, hardware operations).

**2.13 Requirements-First Document Creation** — IF creating any design, spec, or plan document against a reference (EFR, analysis doc, checklist, or user-provided items list):
1. MUST extract and number ALL requirements/items from the reference BEFORE writing any document sections
2. MUST create a coverage table mapping each requirement to a document section
3. MUST verify every item maps to a section BEFORE declaring the document complete
4. NEVER write document prose before step 1 is complete

DO NOT create the doc and then iterate — enumerate requirements first.

## 3. Communication & Permissions

**3.0 Ask Before Assuming** — When an instruction is ambiguous: MUST ask a single focused clarifying question BEFORE taking any action. NEVER infer and proceed. Example: "update claude instructions" → ask "Which file — project CLAUDE.md, global ~/.claude/CLAUDE.md, or both?"

**3.1 No Re-Asking Permission** — If user already approved an action pattern and requests the same kind of follow-up: MUST find AND fix in one pass. NEVER re-list findings and ask "Want me to fix these?"

**3.2 Persist Corrections** — If user corrects a mistake or implies "don't do that again": (1) MUST immediately update `~/.claude/CLAUDE.md` or project `CLAUDE.md` with an IF/THEN MUST/NEVER rule. (2) MUST append to `tasks/lessons.md`: `[mistake] → [correct behavior]`. (3) MUST review `tasks/lessons.md` at session start.

**3.3 Tool Denial in Auto-Approve Mode** — When a tool call is denied in "don't ask" mode: MUST immediately use `AskUserQuestion` to surface the denial. NEVER silently skip, work around, or continue past a denied action. NEVER retry same denied action with a minor variation (e.g., `rm -rf` denied → retry as `rm`).

**3.4 Multi-Question Answer Mapping** — IF receiving answers to a numbered question series: MUST explicitly map each answer to its question number. MUST confirm "Q1→A, Q2→B, Q3→C" internally before proceeding. NEVER assume answer order maps 1:1 to question order.

**3.5 MCP Allow-List Pattern Verification** — IF adding an MCP tool to a permission allow list: MUST verify the exact tool name format the MCP server registers (prefix varies: `mcp__slack__*` vs `mcp__plugin_slack__*`). MUST confirm pattern from an actual denied tool name. NEVER copy an existing pattern and assume it matches a different MCP server.

**3.6 Two-Correction Session Reset** — When user has corrected the same behavior 2+ times in one session: MUST recommend `/clear` + restart. NEVER keep iterating in a context full of repeated corrections on the same issue.

## 4. Parallelism & Subagent Management
@~/.claude/rules/parallelism.md

## 5. Code & Design Quality
@~/.claude/rules/code-quality.md

## 6. Documentation & Reports
@~/.claude/rules/documentation.md

## 7. Debugging

**7.1 Run Binary Over Re-Tracing** — If analysis says X but tests say Y and re-reading doesn't resolve: MUST run the binary with minimal inputs. NEVER re-trace code a third+ time.

**7.2 Use CLI Tools Directly** — MUST use `docker logs`, `kubectl logs`, `jq`, `psql`, `gh`, etc. NEVER ask user to paste output you can read yourself.

**7.3 Verify Process Freshness** — Before analyzing logs from a recently-changed service: MUST verify instance started AFTER latest changes. If stale, restart first. NEVER assume running process reflects latest code.

**7.4 Autonomous Bug Fixing** — When given a bug report: MUST just fix it. MUST point at logs, errors, and failing tests, then resolve without prompting. NEVER say "I found the issue, would you like me to fix it?"

**7.5 Two-Attempt Limit** — If the same fix, test strategy, or grep pattern fails twice: MUST STOP — NEVER attempt a third retry with the same approach. MUST use `AskUserQuestion` to surface: (1) what was tried, (2) what failed, (3) what alternatives exist.

**7.6 Multi-Channel Input Debugging** — IF debugging a hook, callback, subprocess, or plugin where expected input appears empty or missing:
1. MUST dump ALL input channels simultaneously in the FIRST debug attempt: stdin (`STDIN_DATA=$(cat)`), relevant env vars (`env | grep -i <prefix>`), positional args (`"$@"`), and any known file-based channels
2. NEVER test one channel at a time — always dump all at once
3. MUST read source of an analogous working component in the same framework to verify the expected channel BEFORE hypothesizing

DO NOT assume input channel by analogy — mechanism can differ by event type even within the same framework.

## 8. Token Efficiency
@~/.claude/rules/token-efficiency.md

## 9. Shell Scripts on Windows/WSL
@~/.claude/rules/shell-wsl.md

## 10. Code Intelligence (LSP)
@~/.claude/rules/lsp.md

## 11. Memory

**11.0 Memory Directory** — MUST store ALL project memory files at `<project-root>/.claude/memory/` (inside the project directory). NEVER write project memory to `~/.claude/projects/<project>/memory/` — that path pollutes the global folder and leaks context across projects. MUST add `@.claude/memory/MEMORY.md` to the project's `.claude/CLAUDE.md` so it loads each session. `MEMORY.md` is the index (truncated after 200 lines); store deep notes in topic files linked from it.

**11.1 Read Memory at Session Start** — MUST read `MEMORY.md` on the first tool call of every session for the active project. NEVER skip.

**11.2 Write Memory After Significant Work** — MUST update memory after: non-trivial architectural/design decisions; confirmed patterns/conventions; bug root-causes found; user corrections (also write to CLAUDE.md per 3.2); new component/file layout understood.

**11.3 Memory Write Rules:** (1) MUST update existing entries — NEVER duplicate. (2) MUST delete/correct wrong entries. (3) NEVER write session-specific state. (4) Topic files for depth; `MEMORY.md` for index only. (5) NEVER leave `MEMORY.md` >200 lines. (6) MUST keep project-level CLAUDE.md files under 200 lines — move verbose content to `.claude/rules/` files or `@path` imports.

**11.4 Proactive Triggers** — MUST write to memory without being asked when: user says "always"/"never"/"from now on"; a build/test/config trick is discovered; an important file path or environment quirk is confirmed.

**11.5 Learning Digest** — Best practices live at `~/.claude/learning/digest.md`. MUST consult when looking for productivity improvements, workflow patterns, or prompting techniques.

## 12. Core Principles

**12.1 Simplicity First** — MUST make every change as simple as possible. Impact the minimal code necessary. NEVER introduce complexity that isn't required by the current task.

**12.2 No Laziness** — MUST find root causes. NEVER apply temporary fixes or workarounds — no shortcuts, no "good enough for now."

**12.3 Minimal Impact** — Changes MUST touch only what is necessary. NEVER refactor surrounding code, rename unrelated symbols, or "clean up while you're in there" unless explicitly asked.

## 13. Slack

**13.1 Message Order** — ALWAYS pass `oldest`/`limit` or equivalent params to read Slack channel messages in descending time order (most recent first). NEVER read a channel without fetching the most recent messages first.

**13.2 Slack Timestamp Computation** — IF computing a Unix timestamp for a Slack `oldest` parameter: (1) MUST verify by back-converting: `datetime.utcfromtimestamp(ts)`. (2) NEVER pass an unverified integer timestamp. (3) MUST log the computed date (human-readable) before the API call.

## 14. Grill Mode (`/grill`)
@~/.claude/rules/grill.md

## 15. Integration with any Libraries
@~/.claude/rules/library-integration.md
