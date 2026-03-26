# Learning Digest

Accumulated tips, newest first. Auto-populated by `/learn-web`.

## Format

Each entry:
```
### [YYYY-MM-DD] Source: <source name>
**Tip:** <concise, actionable tip>
**Confidence:** HIGH | MEDIUM
**Status:** pending | [promoted to CLAUDE.md §N.N on YYYY-MM-DD]
```

---

<!-- New entries are prepended below this line -->
### [2026-03-18] Source: Simon Willison (simonwillison.net/guides/agentic-engineering-patterns/anti-patterns/)
**Tip:** NEVER file a PR with agent-produced code you haven't personally reviewed and tested — "inflicting unreviewed code on collaborators" is an anti-pattern; include evidence of manual testing, screenshots, or comments on implementation choices; prefer several small PRs over one large one.
**Confidence:** HIGH
**Status:** [noted 2026-03-18 — semantically covered by §4.6 (fresh-context review) and §2.3 (verify before done); reinforces: always include manual test evidence and implementation notes in agent-assisted PRs]

### [2026-03-18] Source: Anthropic Official Docs (code.claude.com/docs/en/skills)
**Tip:** Use `/batch <instruction>` to orchestrate large-scale codebase changes in parallel — Claude decomposes work into 5–30 independent units, spawns one background agent per unit in an isolated git worktree, each runs tests and opens a PR. Example: `/batch migrate src/ from Solid to React`.
**Confidence:** HIGH
**Status:** [noted 2026-03-18 — bundled skill for parallel codebase migrations; use for large refactors instead of manual subagent spawning]

### [2026-03-18] Source: Anthropic Official Docs (code.claude.com/docs/en/best-practices)
**Tip:** Use `/rewind` (or double-tap Esc) to open a rewind menu — restore conversation only, code only, or both to a checkpoint. Checkpoints persist across sessions, enabling "attempt bold risky changes and rewind if wrong" workflows. Not a replacement for git.
**Confidence:** HIGH
**Status:** [noted 2026-03-18 — user workflow; recommend `/rewind` when user wants to undo agent changes without git; mention checkpoints persist across sessions]

### [2026-03-18] Source: Anthropic Official Docs (code.claude.com/docs/en/best-practices)
**Tip:** Use `/rename` to give sessions descriptive names like "oauth-migration" or "debugging-memory-leak" — treat sessions like git branches; different workstreams get separate, persistent contexts resumable with `claude --continue` or `--resume`.
**Confidence:** HIGH
**Status:** [noted 2026-03-18 — user workflow; suggest `/rename` at the start of multi-session workstreams so sessions can be resumed by name]

### [2026-03-18] Source: Anthropic Official Docs (code.claude.com/docs/en/memory)
**Tip:** CLAUDE.md files over 200 lines consume more context and may reduce adherence — keep project-level CLAUDE.md concise; move verbose content into `.claude/rules/` files or `@path` imports. Debug adherence issues with `/memory` to verify which files are loaded.
**Confidence:** HIGH
**Status:** [promoted to CLAUDE.md §11.3 rule 6 on 2026-03-18]

### [2026-03-18] Source: Anthropic Official Docs (code.claude.com/docs/en/sub-agents)
**Tip:** Subagents do NOT inherit skills from the parent conversation — use the `skills` field in subagent frontmatter to preload full skill content at startup for domain-specific subagents. Without this, subagents start with no skill knowledge.
**Confidence:** HIGH
**Status:** [promoted to CLAUDE.md §4.2 on 2026-03-18]

### [2026-03-18] Source: Anthropic Official Docs (code.claude.com/docs/en/best-practices)
**Tip:** If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches — run `/clear` and start fresh with a more specific prompt incorporating what was learned. A clean session with a better prompt almost always outperforms a long corrected session.
**Confidence:** HIGH
**Status:** [promoted to CLAUDE.md §3.4 on 2026-03-18]

### [2026-03-18] Source: Anthropic Official Docs (code.claude.com/docs/en/best-practices)
**Tip:** For large file migrations (50+ files), generate a file list first, then loop `claude -p "Migrate $file"` with `--allowedTools` restriction in a shell script — test on 2–3 files to refine the prompt before running at scale; `--allowedTools` restricts what Claude can do when running unattended.
**Confidence:** HIGH
**Status:** [promoted to CLAUDE.md §2.10 on 2026-03-18]

### [2026-03-18] Source: Simon Willison (simonwillison.net/guides/agentic-engineering-patterns/hoard-things-you-know-how-to-do/)
**Tip:** "Hoard things you know how to do" — save every successful prompt, working code snippet, and CLAUDE.md pattern in reusable files; the best prompting pattern is to combine 2+ existing working examples and ask the agent to build something new by recombining them.
**Confidence:** MEDIUM
**Status:** [noted 2026-03-18 — workflow technique; accumulate working examples in skills/memory files and combine them as prompting inputs for new features]

### [2026-03-18] Source: Anthropic Official Docs (code.claude.com/docs/en/skills)
**Tip:** Use `allowed-tools: Read, Grep, Glob` in skill frontmatter to create read-only skills that can explore files but cannot modify them — ideal for safe analysis, audit, or review workflows.
**Confidence:** MEDIUM
**Status:** [noted 2026-03-18 — useful for audit/review skills that must not modify files; pair with `disable-model-invocation: true` for pure template skills]

### [2026-03-18] Source: Anthropic Official Docs (code.claude.com/docs/en/skills)
**Tip:** Use `$ARGUMENTS` placeholder in skill content to pass arguments at invocation (e.g. `/fix-issue 123` → `$ARGUMENTS` = "123"); use `disable-model-invocation: true` for pure template skills that just inject text without a model call.
**Confidence:** MEDIUM
**Status:** [noted 2026-03-18 — skill parameterization; use `$ARGUMENTS` for task-number or target-name skills; `disable-model-invocation: true` for pure prompt-injection templates]

### [2026-03-18] Source: Anthropic Official Docs (code.claude.com/docs/en/sub-agents)
**Tip:** Use `memory: user`, `memory: project`, or `memory: local` in subagent frontmatter for cross-session persistent memory scoped to that level — enables specialized long-running assistants (e.g. a security reviewer that accumulates project findings across sessions).
**Confidence:** MEDIUM
**Status:** [noted 2026-03-18 — extends §11 memory patterns to subagents; use `memory: project` for domain subagents that should accumulate codebase knowledge]

### [2026-03-18] Source: Anthropic Official Docs (code.claude.com/docs/en/sub-agents)
**Tip:** Subagents coordinate within a single session (own context window, shared session); agent teams coordinate multiple Claude Code instances across separate sessions — use agent teams when agents need to communicate and share state across independent sessions.
**Confidence:** MEDIUM
**Status:** [noted 2026-03-18 — key architectural distinction; subagents for context isolation within one session, agent teams for true parallel multi-session work]

### [2026-03-18] Source: Anthropic Official Docs (code.claude.com/docs/en/skills)
**Tip:** Skills have a ~16,000-char context window budget — run `/context` to check if skills are being excluded. Override the limit with the `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var for large skills.
**Confidence:** MEDIUM
**Status:** [noted 2026-03-18 — if a skill stops working silently, run `/context` first; set `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var to raise the budget for large skills]

### [2026-03-13] Source: Anthropic Official Docs (code.claude.com/docs/en/best-practices)
**Tip:** Add compaction-preservation instructions directly in CLAUDE.md — e.g., `"When compacting, always preserve the full list of modified files and any test commands"` — so task-critical context survives `/compact`.
**Confidence:** HIGH
**Status:** [promoted to CLAUDE.md §8.10 on 2026-03-13]

### [2026-03-13] Source: Anthropic Official Docs (code.claude.com/docs/en/best-practices)
**Tip:** Use a separate fresh Claude session to review code — a reviewer session with clean context is unbiased and catches issues the authoring session missed; never ask the same session to review code it just wrote.
**Confidence:** HIGH
**Status:** [promoted to CLAUDE.md §4.6 on 2026-03-13]

### [2026-03-13] Source: Anthropic Official Docs (code.claude.com/docs/en/hooks-guide)
**Tip:** Hooks run deterministically and guarantee execution; CLAUDE.md instructions are advisory only — use hooks for any action that MUST happen on every invocation (lint, format, block writes to sensitive paths).
**Confidence:** HIGH
**Status:** [promoted to CLAUDE.md §2.8 on 2026-03-13]

### [2026-03-13] Source: boristane.com + Anthropic Official Docs
**Tip:** Include an explicit "do not write any code yet" instruction in every planning prompt until the written plan is reviewed and approved — prevents Claude from jumping to implementation before the approach is locked in.
**Confidence:** HIGH
**Status:** [promoted to CLAUDE.md §2.7 on 2026-03-13]

### [2026-03-13] Source: Anthropic Official Docs (code.claude.com/docs/en/best-practices)
**Tip:** Use `/btw` for side questions that shouldn't enter conversation history — the answer appears in a dismissible overlay and never consumes context.
**Confidence:** HIGH
**Status:** [noted 2026-03-17 — CLI feature, no CLAUDE.md change needed; use when needing quick answers without polluting context]

### [2026-03-13] Source: Anthropic Official Docs (code.claude.com/docs/en/memory)
**Tip:** Use CLAUDE.md `@path/to/file` import syntax to modularize instructions — reference README, package.json, or workflow docs directly rather than duplicating their content in CLAUDE.md.
**Confidence:** HIGH
**Status:** [noted 2026-03-17 — already applied in .claude/CLAUDE.md via @pr-conventions.md, @CLAUDE_CODE_BEST_PRACTICES.md, @USER_PREFERENCES.md]

### [2026-03-13] Source: Anthropic Official Docs (code.claude.com/docs/en/memory)
**Tip:** Use `.claude/rules/` directory with `paths:` YAML frontmatter to scope rules to specific file types (e.g., only load API rules when editing `src/api/**/*.ts`) — reduces noise and saves context.
**Confidence:** HIGH
**Status:** [deferred 2026-03-17 — no file-type-specific rules needed yet; revisit if adding Go/Python modules]

### [2026-03-13] Source: Anthropic Official Docs (code.claude.com/docs/en/memory)
**Tip:** Run `/init` in any project to auto-generate a starter CLAUDE.md — Claude analyzes build systems, test frameworks, and code patterns to produce a solid starting file to refine.
**Confidence:** HIGH
**Status:** [noted 2026-03-17 — N/A for dataplane (CLAUDE.md already established); apply to new projects]

### [2026-03-13] Source: Anthropic Official Docs (code.claude.com/docs/en/best-practices)
**Tip:** Use `claude --continue` to resume the most recent session or `claude --resume` to pick from recent sessions — treat sessions like branches for different workstreams.
**Confidence:** HIGH
**Status:** [noted 2026-03-17 — added as workflow tip to MEMORY.md]

### [2026-03-13] Source: Anthropic Official Docs (code.claude.com/docs/en/best-practices)
**Tip:** For large features, have Claude interview you first using `AskUserQuestion` tool before writing specs — it surfaces unknowns about edge cases, UX, and tradeoffs you haven't considered; then start a fresh session to implement.
**Confidence:** MEDIUM
**Status:** pending

### [2026-03-13] Source: Anthropic Official Docs (code.claude.com/docs/en/best-practices)
**Tip:** Pipe data directly into Claude — `cat error.log | claude` or `git diff main --name-only | claude -p "review for security issues"` — for context-efficient batch analysis without opening a session.
**Confidence:** MEDIUM
**Status:** pending

### [2026-03-13] Source: amplifying.ai (HN: 611 pts)
**Tip:** Claude Code defaults to custom/DIY implementations in 12 of 20 common feature categories — explicitly name the library or service you want (Stripe, Prisma, etc.) or expect bespoke code.
**Confidence:** MEDIUM
**Status:** pending

### [2026-03-13] Source: amplifying.ai (HN: 611 pts)
**Tip:** Claude Opus 4.6 prefers Drizzle ORM over Prisma and FastAPI BackgroundTasks over Celery compared to earlier models — check tech-stack assumptions when upgrading model versions.
**Confidence:** MEDIUM
**Status:** pending

### [2026-03-13] Source: Anthropic Official Docs (code.claude.com/docs/en/best-practices)
**Tip:** Subagents can maintain their own persistent auto memory — configure `autoMemoryEnabled` per subagent for specialized long-running assistants (e.g., a security reviewer that remembers past findings).
**Confidence:** MEDIUM
**Status:** pending

### [2026-03-13] Source: symmetrybreak.ing (HN: 1085 pts)
**Tip:** Claude Code v2.1.20+ hides file paths and search patterns by default — enable verbose mode to restore full operation visibility when debugging agent behavior.
**Confidence:** MEDIUM
**Status:** pending

### [2026-03-13] Source: boristane.com (HN: 976 pts)
**Tip:** Require Claude to write research and codebase discoveries into a markdown file before planning — verbal summaries disappear from context; a written file persists and can be annotated with corrections.
**Confidence:** MEDIUM
**Status:** pending
