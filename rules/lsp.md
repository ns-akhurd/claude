**10.0 MUST Use LSP Plugins** — The following LSP plugins are enabled and MUST be used for all supported file types. NEVER fall back to text search or manual file reading for operations these plugins handle.

LSP is a **deferred tool** — its schema is not loaded at session start. MUST call `ToolSearch` with `query: "select:LSP"` before the first LSP operation in any session. Do this at the same time as the first file read or grep, not as a separate step.

| Plugin | Languages | When to use |
|---|---|---|
| `clangd-lsp` | C, C++ | All C/C++ navigation, diagnostics, completions |
| `pyright-lsp` | Python | All Python type checks, navigation, imports |
| `typescript-lsp` | TypeScript, JavaScript | All TS/JS navigation, type errors, refactors |
| `gopls-lsp` | Go | All Go navigation, diagnostics, formatting |
| `lua-lsp` | Lua | All Lua navigation and diagnostics |

**10.1 LSP-first for all code navigation — strict fallback order:**

| Task | MUST use | NEVER use instead |
|---|---|---|
| Find where a symbol is defined | `workspaceSymbol` → `goToDefinition` | `grep`, `Bash grep`, `Glob` |
| List all symbols in a file | `documentSymbol` | Read the whole file |
| Find all usages | `findReferences` | `grep` for the name |
| Get type/signature info | `hover` | Read the header |
| Trace callers/callees | `incomingCalls` / `outgoingCalls` | Manual grep + read |
| Jump to implementation | `goToImplementation` | `grep` for impl |

NEVER reach for Grep/Bash/Read for any of the above without first attempting the LSP operation. If LSP returns no results, THEN fall back to Grep — and document why.

**10.2** Before renaming or changing a function signature, MUST use `findReferences` to find all call sites first.

**10.3** After every file edit, MUST check LSP diagnostics via the active plugin; fix any type errors or missing imports in the same turn before declaring done.

**10.4** Use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't apply.

**10.5 Never Guess Signatures** — Before calling any function not read in this session:
- MUST use `goToDefinition` (LSP) or Read the header to confirm parameter order, types, and return value
- NEVER guess or infer a signature from a call site — wrong guesses compile silently and fail at runtime
