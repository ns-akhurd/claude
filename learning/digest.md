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
