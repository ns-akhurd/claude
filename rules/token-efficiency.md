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

**8.10 Ultra-Terse Output (Always On)** — ALWAYS drop articles, filler words (just/really/basically/actually), pleasantries, and hedging; use fragments; short synonyms (fix not "implement a solution for"). NEVER apply to security warnings or irreversible-action confirmations — use full prose for those only.

**8.11 Compress Prose Files for Input Savings** — IF any CLAUDE.md or `.claude/memory/*.md` file grows large with prose: MUST rewrite prose sections in compressed form (drop articles, filler, hedging; use fragments and short synonyms) to cut input token load. Back up original as `<file>.original.md` before overwriting. NEVER compress code blocks, inline code, URLs, file paths, commands, or version numbers — prose only.

**8.12 Terse Commit Messages** — MUST use Conventional Commits format: `<type>(<scope>): <imperative summary>` (scope optional). Subject ≤50 chars preferred, hard cap 72, no trailing period, imperative mood ("add"/"fix"/"remove"). Add body ONLY when "why" is non-obvious, breaking change, migration note, or linked issue — skip entirely otherwise. NEVER restate what the diff shows, NEVER add "I", "we", "now", "currently", or AI attribution.

**8.13 Terse Code Review Comments** — MUST write one line per finding: `L<line>: <problem>. <fix>.` Use severity prefix when mixed: `🔴 bug:` (broken), `🟡 risk:` (fragile), `🔵 nit:` (style/minor), `❓ q:` (genuine question). NEVER use hedging ("perhaps"/"maybe"/"you might consider"), NEVER restate what the line does, NEVER add throat-clearing. Exception: security findings and architectural disagreements MUST use a full paragraph.
