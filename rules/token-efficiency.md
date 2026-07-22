**8.1 Surgical File Reading** — NEVER read whole file when section suffices; use `offset`/`limit`. Grep/Glob first to confirm relevance. NEVER speculatively read "for context".

**8.2 Parallel Tool Calls** — MUST batch all independent tool calls in ONE message. NEVER sequential for independent ops.

**8.3 Concise Output** — Minimum tokens to fully answer. Prefer tables/bullets/JSON. NEVER restate question. NEVER preambles ("Great question!", "Sure, I'd be happy to..."). NEVER pre-announce — just do. After create/edit: "Done. See `<path>`."

**8.4 Model Tiering** — Subagent model:
- `haiku` — lookups/grep/explore/format/log analysis (default)
- `sonnet` — code gen/review/multi-file edits
- `opus` — complex architecture/ambiguous requirements/security-critical
NEVER use `opus` for search/read/reformat.
Opus 4.7: raise `effort` param before rewriting prompts — low-effort Opus 4.7 ≈ medium-effort Opus 4.6; use `max`/`xhigh` with ≥64k token budget for deep agentic work.

**8.5 Context Hygiene** — At ~50 turns or topic shift: MUST recommend `/compact` (same task) or `/clear` (new task) per 8.15. Delegate broad searches. NEVER paste large file/log blocks; say "See `<path>:<lines>`". Tool result >200 lines: extract only relevant.

**8.6 No Redundant Operations** — NEVER re-read unchanged file. NEVER re-run unchanged-state command. NEVER re-grep what you found. NEVER re-read/re-grep to "double-check" an already-established fact — tool-call only on genuine uncertainty. Use subagent results directly.

**8.7 Edit Over Write** — MUST use `Edit` (diff only) not `Write` (whole file) for existing files.

**8.8 Prompt-Aware** — NEVER repeat CLAUDE.md/system prompt content. NEVER think aloud unnecessarily. Yes/no questions: answer yes/no first.

**8.9 Preserve Compaction State** — Multi-session tasks: MUST add compaction-preservation to CLAUDE.md. NEVER rely on default compaction for task-critical context.

**8.10 Ultra-Terse Output (Always On)** — ALWAYS drop articles/filler (just/really/basically/actually)/pleasantries/hedging; use fragments; short synonyms (fix not "implement a solution for"). NEVER apply to security warnings or irreversible-action confirmations — full prose only.

**8.11 Compress Prose Files for Input Savings** — IF any CLAUDE.md or `.claude/memory/*.md` grows with prose: MUST rewrite prose in compressed form (drop articles/filler/hedging; fragments; short synonyms) to cut input tokens. Back up original as `<file>.original.md` before overwriting. NEVER compress code blocks, inline code, URLs, file paths, commands, version numbers.

**8.12 Terse Commit Messages** — MUST use Conventional Commits: `<type>(<scope>): <imperative summary>` (scope optional). Subject ≤50 chars preferred, hard cap 72, no trailing period, imperative ("add"/"fix"/"remove"). Body ONLY when "why" non-obvious, breaking change, migration note, or linked issue. NEVER restate diff. NEVER "I"/"we"/"now"/"currently" or AI attribution.

**8.13 Terse Code Review Comments** — MUST one line per finding: `L<line>: <problem>. <fix>.` Severity prefix when mixed: `🔴 bug:` (broken), `🟡 risk:` (fragile), `🔵 nit:` (style/minor), `❓ q:` (genuine question). NEVER hedge ("perhaps"/"maybe"/"you might consider"). NEVER restate line. NEVER throat-clear. Exception: security findings + architectural disagreements → full paragraph.

(8.14 lives in CLAUDE.md — context-mode tools.)

**8.15 Clear vs Compact** — MUST recommend `/clear` (not `/compact`) when next task is unrelated to current context — `/clear` drops the whole window, `/compact` only summarizes. Use `/compact` when continuing the SAME task past ~50 turns. NEVER carry an unrelated prior task's context into a new one — wasted input tokens every turn.

**8.16 Cap Command Output** — MUST bound any command whose output could exceed ~50 lines before it enters context:
- Grep: MUST pass `head_limit`; use `output_mode: "files_with_matches"` or `"count"` when content not needed
- Bash: MUST append `| head -n N`, use tool `-n`/`--max-count` flags, and `git --no-pager` (NEVER let `git log`/`diff`/`branch` page full history)
- NEVER `cat` a whole file into context to inspect a section — use Read `offset`/`limit` (8.1)
- Large unavoidable output: delegate to subagent (parallelism 4.1) — only its summary returns

**8.17 Batch Clarifying Questions** — Multiple open questions: MUST ask all in ONE `AskUserQuestion` call (up to 4). NEVER serialize across turns — each round-trip re-sends full context.

**8.18 Stop When Done** — Answer delivered / task verified: MUST stop. NEVER add recap, "let me also…", or speculative follow-up work. Extra turns cost input re-send of whole context.

## Session Command Cheat-Sheet — cost levers
Recommend these to the user (Claude can't invoke slash-commands itself; surface them). "Rule" = full detail, not restated here.
| Command | When | Rule |
|---|---|---|
| `/clear` | unrelated task | 8.15 |
| `/compact` | same task, ~50+ turns | 8.15 |
| `/model opusplan` | non-trivial multi-file changes | 8.22 |
| `/model haiku` | lookups, formatting, simple edits | 8.4 |
| `/cost` | anytime | shows session spend |
| `/fast` | Opus 4.6/4.7 only | faster output, same model |
| `/effort low` | simple known-answer tasks | ~50% fewer output tokens |
| `--allowedTools <list>` | unattended `claude -p` loops | 2.9 |
| `git --no-pager log/diff -n N` | inspecting history | 8.16 |

**8.19 Targeted Test Execution** — MUST run the narrowest test selection covering the change (single test/file/filter, e.g. `pytest path::test`, `--gtest_filter=`, `go test -run`). NEVER run the full suite when a subset covers the change. MUST cap test output (`-q`, fail-fast, `| tail`). Full suite ONLY on explicit request or final pre-commit gate.

**8.21 No Verify-Read After Edit** — NEVER re-read a file solely to confirm an `Edit`/`Write` applied — the tool errors on failure, so success is implicit. Re-read ONLY when subsequent logic needs content changed by a different actor (hook, formatter, concurrent process).

**8.22 Opusplan for Non-Trivial Changes** — For multi-file or design-heavy work: recommend `/model opusplan` — Opus drives plan mode, Sonnet executes after plan accepted. NEVER use Opus for mechanical execution of an already-approved plan.

**8.23 Logs → File Path or Script** — Large logs/dumps: MUST save to file and Read specific lines, OR write a small extraction script and run it. NEVER pipe raw logs (>50 lines) through prompt context. Extraction script cost ≪ reasoning over full dump.

**8.24 Bound Output Shape** — Analysis/summary/relationship tasks: MUST request specific output shape ("list top 5", "one-paragraph summary", "table of X vs Y"). Output tokens grow faster than input — unbounded analysis burns tokens without proportional insight.

**8.25 Explicit Stopping Condition** — Iterative/agentic work (fix N tests, process records, search-and-fix): MUST state stopping condition ("stop after 10 fixes", "stop when test passes", "stop at 3 failures"). NEVER rely on model to decide "done" — tends to over-iterate or stop short.

**8.26 Deterministic → Script** — Repeated work with stable logic (parse known format, apply rule across inputs, same transformation each time): MUST push to a script after pattern emerges (~2-3 manual iterations). Prompt becomes thin orchestration wrapper. NEVER keep paying inference tokens for deterministic transforms.
