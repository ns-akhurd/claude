**10.0 MUST Use LSP Plugins** — The following LSP plugins are enabled and MUST be used for all supported file types. NEVER fall back to text search or manual file reading for operations these plugins handle:

| Plugin | Languages | When to use |
|---|---|---|
| `clangd-lsp` | C, C++ | All C/C++ navigation, diagnostics, completions |
| `pyright-lsp` | Python | All Python type checks, navigation, imports |
| `typescript-lsp` | TypeScript, JavaScript | All TS/JS navigation, type errors, refactors |
| `gopls-lsp` | Go | All Go navigation, diagnostics, formatting |
| `lua-lsp` | Lua | All Lua navigation and diagnostics |

**10.1 Prefer LSP over text search for code navigation:**
- `goToDefinition` / `goToImplementation` — jump to source, NEVER grep for definitions
- `findReferences` — find all usages across the codebase
- `workspaceSymbol` — locate where something is defined by name
- `documentSymbol` — list all symbols in a file
- `hover` — get type info without reading the file
- `incomingCalls` / `outgoingCalls` — trace call hierarchy

**10.2** Before renaming or changing a function signature, MUST use `findReferences` to find all call sites first.

**10.3** After every file edit, MUST check LSP diagnostics via the active plugin; fix any type errors or missing imports in the same turn before declaring done.

**10.4** Use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't apply.

**10.5 Never Guess Signatures** — Before calling any function not read in this session:
- MUST use `goToDefinition` (LSP) or Read the header to confirm parameter order, types, and return value
- NEVER guess or infer a signature from a call site — wrong guesses compile silently and fail at runtime
