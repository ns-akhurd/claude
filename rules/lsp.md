**10.0 MUST Use LSP Plugins** — LSP plugins enabled; MUST use for all supported file types. NEVER fall back to text search or manual reading.

LSP is a **deferred tool**. WHEN first Grep/Read/Bash targets C/C++ file (`.c`, `.cpp`, `.hpp`, `.h`, `.cc`): MUST batch `ToolSearch` with `query: "select:LSP"` in SAME message — before results arrive. NEVER wait for LSP op; fetch on first C++ contact.

| Plugin | Languages | Use |
|---|---|---|
| `clangd-lsp` | C, C++ | All C/C++ navigation/diagnostics/completions |
| `pyright-lsp` | Python | All Python type checks/navigation/imports |
| `typescript-lsp` | TypeScript, JavaScript | All TS/JS navigation/type errors/refactors |
| `gopls-lsp` | Go | All Go navigation/diagnostics/formatting |
| `lua-lsp` | Lua | All Lua navigation/diagnostics |

**10.1 LSP-first navigation — strict fallback order:**

| Task | MUST use | NEVER instead |
|---|---|---|
| Find symbol definition | `workspaceSymbol` → `goToDefinition` | `grep`, `Bash grep`, `Glob` |
| List file symbols | `documentSymbol` | Read whole file |
| Find all usages | `findReferences` | `grep` for name |
| Get type/signature | `hover` | Read header |
| Trace callers/callees | `incomingCalls` / `outgoingCalls` | Manual grep + read |
| Jump to implementation | `goToImplementation` | `grep` for impl |

`workspaceSymbol` requires file path, not directory (e.g. `libs/base/ns_types.h`). NEVER pass directory — tool rejects "Path is not a file".

NEVER use Grep/Bash/Read above without LSP first. LSP no results → fall back to Grep; document why.

**10.2** Before renaming/changing function signature: MUST use `findReferences` for all call sites first.

**10.3** After every file edit: MUST check LSP diagnostics; fix type errors / missing imports same turn before done.

**10.4** Grep/Glob only for text/pattern (comments, strings, config values) where LSP doesn't apply.

**10.5 Never Guess Signatures** — Before calling any function not read this session:
- MUST `goToDefinition` (LSP) or Read header to confirm param order/types/return
- NEVER guess from call site — wrong guesses compile silently, fail at runtime
