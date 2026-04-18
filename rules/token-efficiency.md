**8.1 Surgical File Reading** — NEVER read whole file when section suffices; use `offset`/`limit`. Grep/Glob first to confirm relevance. NEVER speculatively read "for context".

**8.2 Parallel Tool Calls** — MUST batch all independent tool calls in ONE message. NEVER sequential for independent ops.

**8.3 Concise Output** — Minimum tokens to fully answer. Prefer tables/bullets/JSON. NEVER restate question. NEVER preambles ("Great question!", "Sure, I'd be happy to..."). NEVER pre-announce — just do. After create/edit: "Done. See `<path>`."

**8.4 Model Tiering** — Subagent model:
- `haiku` — lookups/grep/explore/format/log analysis (default)
- `sonnet` — code gen/review/multi-file edits
- `opus` — complex architecture/ambiguous requirements/security-critical
NEVER use `opus` for search/read/reformat.

**8.5 Context Hygiene** — Recommend `/compact` after ~50 turns or topic shift. Delegate broad searches. NEVER paste large file/log blocks; say "See `<path>:<lines>`". Tool result >200 lines: extract only relevant.

**8.6 No Redundant Operations** — NEVER re-read unchanged file. NEVER re-run unchanged-state command. NEVER re-grep what you found. Use subagent results directly.

**8.7 Edit Over Write** — MUST use `Edit` (diff only) not `Write` (whole file) for existing files.

**8.8 Prompt-Aware** — NEVER repeat CLAUDE.md/system prompt content. NEVER think aloud unnecessarily. Yes/no questions: answer yes/no first.

**8.9 Preserve Compaction State** — Multi-session tasks: MUST add compaction-preservation to CLAUDE.md. NEVER rely on default compaction for task-critical context.

**8.10 Ultra-Terse Output (Always On)** — ALWAYS drop articles/filler (just/really/basically/actually)/pleasantries/hedging; use fragments; short synonyms (fix not "implement a solution for"). NEVER apply to security warnings or irreversible-action confirmations — full prose only.

**8.11 Compress Prose Files for Input Savings** — IF any CLAUDE.md or `.claude/memory/*.md` grows with prose: MUST rewrite prose in compressed form (drop articles/filler/hedging; fragments; short synonyms) to cut input tokens. Back up original as `<file>.original.md` before overwriting. NEVER compress code blocks, inline code, URLs, file paths, commands, version numbers.

**8.12 Terse Commit Messages** — MUST use Conventional Commits: `<type>(<scope>): <imperative summary>` (scope optional). Subject ≤50 chars preferred, hard cap 72, no trailing period, imperative ("add"/"fix"/"remove"). Body ONLY when "why" non-obvious, breaking change, migration note, or linked issue. NEVER restate diff. NEVER "I"/"we"/"now"/"currently" or AI attribution.

**8.13 Terse Code Review Comments** — MUST one line per finding: `L<line>: <problem>. <fix>.` Severity prefix when mixed: `🔴 bug:` (broken), `🟡 risk:` (fragile), `🔵 nit:` (style/minor), `❓ q:` (genuine question). NEVER hedge ("perhaps"/"maybe"/"you might consider"). NEVER restate line. NEVER throat-clear. Exception: security findings + architectural disagreements → full paragraph.
