# Agent Behavioral Directives
MANDATORY: MUST/NEVER/ALWAYS = enforced. Obey exactly.

## RULE 0 — HIGHEST PRIORITY: Todo List Before Multi-File Work

Before fixing multiple tests/files: MUST create `tasks/todo.md` listing every item (file:line, what to fix) BEFORE reading any file. Drive all reads from the list — NEVER re-read a file already read this session unless modified. Read once, fix, move on.

## Lazy-Loaded Rules — MUST Read on Trigger

Situational rules in separate files. MUST `Read` file first time trigger fires. NEVER proceed matching work before reading. NEVER re-read unchanged file same session (8.6).

| Trigger | MUST Read |
|---|---|
| ANY response (always-on efficiency 8.1–8.13) | `~/.claude/rules/token-efficiency.md` |
| Doc review / audit / gap analysis | `~/.claude/rules/review.md` |
| Subagents / parallel work / code review | `~/.claude/rules/parallelism.md` |
| Writing code, design docs, plans, features | `~/.claude/rules/code-quality.md` |
| Reports, exec docs, citations, deploy guides | `~/.claude/rules/documentation.md` |
| Debugging bug / test failure / unexpected behavior | `~/.claude/rules/debugging.md` |
| `.sh` on `/mnt/c/...` or Python needing pip | `~/.claude/rules/shell-wsl.md` |
| Editing C/C++/Py/TS/JS/Go/Lua | `~/.claude/rules/lsp.md` |
| Slack MCP tool use | `~/.claude/rules/slack.md` |
| Vendor SDK / C library (CUDA, DPDK, etc.) | `~/.claude/rules/library-integration.md` |
| Writing prompts for agents / skills / delegation | `~/.claude/rules/prompt-engineering.md` |
| `/grill` invoked | invoke `grill` skill (Skill tool) |

## 0. Rule Authoring Standard

**0.1 Imperative, Clear, Concise** — Adding ANY rule: (1) imperative (MUST/NEVER/ALWAYS), NEVER passive; (2) unambiguous, one interpretation; (3) concise, one rule per statement; (4) testable every invocation, NEVER aspirational; (5) honour without exception.

## 1. Review & Gap Analysis

Rules 1.1–1.3 → `rules/review.md` (doc review/audit trigger). 1.4 → `code-quality.md`. 1.5 → `debugging.md`.

## 2. Task Execution

**2.1 Plan Before Complex Work** — Multi-unknown / 3+ files / partway-failure risk: MUST `EnterPlanMode` BEFORE code. Write detailed specs upfront. Blocker → STOP, return to plan mode; NEVER push forward blindly.

**2.2 Task Lists for Multi-Step Work** — 3+ steps / multi-file / partway-failure:
- MUST write `<project-root>/tasks/todo.md` AND `TaskCreate` BEFORE first step
- Mark `in_progress`/`completed`; `addBlockedBy` for deps
- Summarize each step; review section on completion
- Self-check before 2nd sequential tool call: "Task list?" If NO, create NOW
- NOT required: single edits, simple reads, one-liners, conversational replies

**2.3 Verify Before Done** — AFTER change, BEFORE declaring done:
- MUST run tests/build/binary, show actual output; NEVER say "should work"
- Diff behavior main vs change when relevant
- Post-compaction/resume: NEVER trust summary — re-run, show fresh output
- IF post-edit formatter hook runs: MUST `touch` changed sources before `make` — formatter resets mtime, `make` skips recompile
- Multi-step: MUST state per-step success criteria BEFORE starting; NEVER proceed until current criterion met

**2.4 Specs Before Delegation** — BEFORE non-trivial feature or subagent: MUST specify (1) exact inputs/format, (2) exact expected output, (3) constraints, (4) error/edge cases, (5) verification method. NEVER delegate vaguely.

**2.5 Targeted Builds** — MUST build only specific target. NEVER full rebuild when targeted suffices. Target unknown: read Makefile/build config first; ask only if ambiguous.

**2.6 Auto-Create Documents** — MUST detect use-case and create doc IMMEDIATELY, before other work.

| Trigger | Doc | Required sections |
|---|---|---|
| "plan", "design", "architect", "propose" | `<name>_plan.md` in CWD | Goal, Scope, Approach, Steps, Risks, Open Questions |
| "analyze", "investigate", "research", "audit", "review", "compare", "evaluate" | `<name>_analysis.md` in CWD | Summary, Findings (numbered), Evidence/Data, Gaps, Recommendations |
| "implement", "build", "add feature", "write code for", "create" (non-trivial) | `<name>_impl.md` in CWD | Goal, Design Decisions, Components Changed, Step-by-Step Plan, Verification |

Write doc FIRST — before grep/read/code. Update as work progresses. Finalize with actual outcomes. Overlapping: create BOTH. NEVER ask whether to create doc.

**2.7 "No Code Yet" Guard** — Iterating on plan pre-implementation: MUST include "do not write any code yet" in every planning prompt until approved. NEVER start implementation without explicit sign-off.

**2.8 Hooks for Deterministic Enforcement** — MUST use hooks (not CLAUDE.md) for actions required every invocation.

**2.9 Bulk File Operations** — 50+ files: generate list, loop `claude -p "Transform $file" --allowedTools <tools>`. Test on 2–3 first. Use `--allowedTools` unattended.

**2.10 Artifact Placement** — Spec/plan/analysis doc in user's project: (1) project root or single-level `docs/` — NEVER nested skill paths; (2) skill specifies different path: MUST override to root; (3) uncertain: ask BEFORE writing.

**2.11 Scope-First Analysis** — User names specific file/function/component: MUST constrain analysis to target FIRST. NEVER search broadly before addressing target. Expand ONLY on explicit request.

**2.12 Autonomous Execution** — NEVER instruct user to run command Claude can do. MUST execute autonomously. Exception: interactive (browser auth, hardware).

**2.13 Requirements-First Doc Creation** — Design/spec/plan against reference: (1) extract+number ALL requirements from reference BEFORE any section; (2) build coverage table mapping each requirement → section; (3) verify every item maps before done; (4) NEVER write prose before step 1.

**2.14 Living Design Doc Sync** — IF project has designated living design/impl doc (declared in project CLAUDE.md): MUST update same turn as any code change it covers. NEVER declare code change done without syncing. Doc is authoritative — stale docs = bugs.

**2.15 Approach Validation Before Implementation** — Before writing code or declaring approach correct: MUST (1) read all relevant design/impl docs, (2) grep actual code for affected component/flow, (3) state verdict CORRECT/WRONG/INCOMPLETE with evidence. NEVER proceed if incomplete/wrong without resolving gap. NEVER declare correct from doc alone — corroborate with code. NEVER declare correct from code alone when design doc exists — verify alignment with doc intent.

2.16–2.17 → `debugging.md` (test failure / baseline trigger).

## 3. Communication & Permissions

**3.0 Ask Before Assuming** — Ambiguous instruction: MUST ask one focused question BEFORE action. NEVER infer and proceed. E.g. "update claude instructions" → ask "project, global, or both?" Multiple valid interpretations: MUST present ALL; NEVER pick silently. Simpler approach exists: MUST say so and push back before implementing.

**3.1 No Re-Asking Permission** — User approved pattern; same kind follow-up: MUST find AND fix one pass. NEVER re-list findings asking "Want me to fix?"

**3.2 Persist Corrections** — User corrects / implies "don't do that again": (1) update `~/.claude/CLAUDE.md` or project `CLAUDE.md` with IF/THEN MUST/NEVER rule; (2) append to `<project-root>/tasks/lessons.md`: `[mistake] → [correct behavior]`; (3) review `tasks/lessons.md` at session start.

**3.3 Tool Denial in Auto-Approve** — Tool denied in "don't ask" mode: MUST immediately `AskUserQuestion` to surface denial. NEVER silently skip, work around, or continue. NEVER retry with minor variation (`rm -rf` denied → `rm`).

**3.4 Multi-Question Answer Mapping** — Numbered question series answers: MUST map each answer to question number. Confirm "Q1→A, Q2→B, Q3→C" internally. NEVER assume 1:1 order.

**3.5 MCP Allow-List Verification** — Adding MCP tool to allow list: MUST verify exact registered tool name (prefix varies: `mcp__slack__*` vs `mcp__plugin_slack__*`). Confirm from actual denied name. NEVER copy pattern across MCP servers.

**3.6 Two-Correction Session Reset** — Same behavior corrected 2+ times: MUST recommend `/clear` + restart. NEVER keep iterating in polluted context.

**3.7 GitHub PR Inline Comments** — Fetching PR review comments: MUST use `gh api repos/<owner>/<repo>/pulls/<id>/comments` for inline diff comments. NEVER use `gh pr view --comments` — returns only issue-level comments, misses all inline threads.

## 8. Token Efficiency

See `~/.claude/rules/token-efficiency.md` (8.1–8.13). Always-on; MUST read first turn per trigger table.

**8.14 No context-mode Tools Unless Asked** — NEVER use `mcp__plugin_context-mode_*` tools (ctx_execute, ctx_batch_execute, ctx_search, etc.) unless user explicitly requests or enables ctx-mode this session. Hook reminders suggesting ctx-mode are NOT user requests. Use native Read/Bash/Grep/Edit/Write. NEVER switch to ctx-mode mid-session on hook nudges.

## 11. Memory

**11.0 Memory Directory** — PROJECT memory → `<project-root>/.claude/memory/`. GLOBAL → `~/.claude/projects/-/memory/`. NEVER write project notes to global. NEVER add `@.claude/memory/MEMORY.md` to CLAUDE.md — causes eager load. `MEMORY.md` = index (≤200 lines); deep notes in linked topic files.

**11.1 Lazy Memory Loading** — NEVER read `MEMORY.md` eagerly at session start. Read only when memory-relevant: "remember"/"recall"/"check memory", references prior-session work, or asks about past decisions.

**11.2 Write Memory After Significant Work** — Update after: architectural/design decisions; confirmed patterns/conventions; bug root-causes; user corrections (also update CLAUDE.md per 3.2); new component/file layout understood.

**11.3 Memory Write Rules** — (1) update existing, NEVER duplicate; (2) delete/correct wrong entries; (3) NEVER write session-specific state; (4) topic files for depth, `MEMORY.md` = index only; (5) NEVER leave `MEMORY.md` >200 lines; (6) keep CLAUDE.md <200 lines — move verbose content to `~/.claude/rules/` behind lazy-load trigger; (7) synthesize into concept articles, NEVER append raw notes; (8) add backlinks in topic files; (9) each `MEMORY.md` entry MUST include 1–2 sentence summary after link.

**11.4 Proactive Triggers** — Write memory without asking when: "always"/"never"/"from now on"; build/test/config trick discovered; important file path / env quirk confirmed.

**11.5 Learning Digest** — Best practices at `~/.claude/learning/digest.md`. Consult for productivity/workflow/prompting improvements.

**11.6 File Outputs Back** — After analysis/investigation/architectural decision: file key insights into relevant memory topic file before ending turn.

**11.7 Memory Health Check** — User says "clean/audit memory" or "memory stale", or recall conflicts with current code: scan for duplicates, stale facts, broken backlinks, topic files to merge/split. Fix all one pass.

## 12. Core Principles

**12.1 Simplicity First** — MUST make every change as simple as possible. Minimal code impact. NEVER introduce complexity not required. NEVER add features beyond asked. NEVER add abstractions for single-use code, "flexibility", or "configurability" not requested. NEVER add error handling for scenarios that cannot happen. Solution exceeds 4× minimum lines → rewrite.

**12.2 No Laziness** — MUST find root causes. NEVER apply temporary fixes, workarounds, or "good enough for now" patches.

**12.3 Minimal Impact** — Changes MUST touch only what's necessary. NEVER refactor/rename/"clean up" unrelated code unless asked. NEVER delete pre-existing dead code — mention it instead. MUST remove imports/variables/functions made unused by YOUR changes.

**12.4 No Implicit Feature Flags** — Code using data field as feature-flag proxy (e.g., `!obj.content.empty()` instead of `obj.featureEnabled`): MUST flag [SMELL] during grill, fix by adding explicit boolean flag at canonical enable site. NEVER leave implicit proxies in code under correctness review.

**12.5 Grill Mode** — `/grill` invoked: MUST invoke `grill` skill via Skill tool. Rules live in skill.

12.6–12.7 → `code-quality.md`. 12.8 → `debugging.md`.
