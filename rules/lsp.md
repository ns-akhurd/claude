**10.0 MUST Use LSP Plugins** — LSP plugins are enabled and MUST be used for all supported file types. NEVER fall back to text search or manual file reading for these operations.

LSP is a **deferred tool**. WHEN the first Grep, Read, or Bash targets a C/C++ file (`.c`, `.cpp`, `.hpp`, `.h`, `.cc`): MUST batch `ToolSearch` with `query: "select:LSP"` in that SAME message — before the tool results arrive. NEVER wait until an LSP operation is planned; fetch it proactively on first C++ contact so it is ready.

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

**`workspaceSymbol` requires a file path, not a directory** (e.g. `libs/base/ns_types.h`). NEVER pass a directory — the tool rejects it with "Path is not a file".
| List all symbols in a file | `documentSymbol` | Read the whole file |
| Find all usages | `findReferences` | `grep` for the name |
| Get type/signature info | `hover` | Read the header |
| Trace callers/callees | `incomingCalls` / `outgoingCalls` | Manual grep + read |
| Jump to implementation | `goToImplementation` | `grep` for impl |

NEVER use Grep/Bash/Read above without attempting LSP first. If LSP returns no results, fall back to Grep — document why.

**10.2** Before renaming or changing a function signature, MUST use `findReferences` to find all call sites first.

**10.3** After every file edit, MUST check LSP diagnostics via the active plugin; fix any type errors or missing imports in the same turn before declaring done.

**10.4** Use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't apply.

**10.5 Never Guess Signatures** — Before calling any function not read in this session:
- MUST use `goToDefinition` (LSP) or Read the header to confirm parameter order, types, and return value
- NEVER guess or infer a signature from a call site — wrong guesses compile silently and fail at runtime
