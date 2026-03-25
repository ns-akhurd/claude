**8.1 Surgical File Reading** — NEVER read whole file when only a section is needed; use `offset`/`limit`. Grep/Glob first to confirm relevance. NEVER speculatively read "for context."

**8.2 Parallel Tool Calls** — MUST batch all independent tool calls in ONE message. NEVER issue sequential calls for independent operations.

**8.3 Concise Output** — Minimum tokens to fully answer. Prefer tables/bullets/JSON over prose. NEVER restate the question. NEVER add preambles ("Great question!", "Sure, I'd be happy to..."). NEVER pre-announce actions — just do it. After file create/edit: "Done. See `<path>`."

**8.4 Model Tiering** — Subagent model selection:
- `haiku` — lookups, grep, explore, formatting, log analysis (default)
- `sonnet` — code gen, review, multi-file edits
- `opus` — complex architecture, ambiguous requirements, security-critical analysis
NEVER use `opus` for search/read/reformat tasks.

**8.5 Context Hygiene** — Recommend `/compact` after ~50 turns or topic shift. Delegate broad searches to subagents. NEVER paste large file/log blocks; say "See `<path>:<lines>`". If tool result >200 lines, extract only relevant lines.

**8.6 No Redundant Operations** — NEVER re-read a file already read (unless modified). NEVER re-run commands with unchanged state. NEVER re-grep what you already found. Use subagent results directly.

**8.7 Edit Over Write** — MUST use `Edit` (diff only) not `Write` (whole file) for existing files.

**8.8 Prompt-Aware** — NEVER repeat CLAUDE.md/system prompt content in output. NEVER think out loud unnecessarily. Yes/no questions: answer yes/no first.

**8.9 Preserve Compaction State** — For multi-session tasks: MUST add compaction-preservation instructions to CLAUDE.md. NEVER rely on default compaction to preserve task-critical context.
