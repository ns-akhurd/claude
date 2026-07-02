---
name: code-graph
description: Use when the user wants to build, query, or maintain a code knowledge graph at C:\Users\AkshaySanjayKhurd\codegraph (WSL: /mnt/c/Users/AkshaySanjayKhurd/codegraph). Triggers on "graph this", "ingest code", "code graph", "who calls", "call chain", "trace flow", "update code graph".
user_invocable: true
allowed-tools:
  - Bash(grep *)
  - Bash(rg *)
  - Bash(find *)
  - Bash(python3 *)
  - Bash(diff *)
  - Bash(cd /root/code/dataplane && git *)
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Task
---

# Code Graph

Code knowledge graph at `/mnt/c/Users/AkshaySanjayKhurd/codegraph`. Source: `/root/code/dataplane/libs/dlp` on `develop` branch only.

## Prerequisite

Before any operation: `cd /root/code/dataplane && git checkout develop && git pull origin develop`

## Ingest — Module

1. `find /root/code/dataplane/libs/dlp/<module> -name "*.cpp" -o -name "*.h" -o -name "*.hpp"`
2. `cp` files to `raw/` (flat, filename only). Write `develop` commit hash to `raw/.git_commit`.
3. Read each file. For >20 files: Task subagents (3-5 files each) extracting: 1-sentence purpose, functions (name, signature, line number, 1-line description), classes (name, members), `#include` list, cross-file calls, `TODO`/`FIXME`/`CRITICAL` with line numbers.
4. **Validate line numbers**: `rg -n "<fn_name>" <source_file>` — must match. NEVER guess.
5. **Validate call edges**: `rg "<called_fn>" /root/code/dataplane/libs/dlp --include "*.cpp" --include "*.hpp"` — must return ≥1 hit. Discard unconfirmed.
6. Create pages: `wiki/files--<name>.md` per file, `wiki/functions--<fn>.md` per function (skip <5 lines, getters/setters, typedefs), `wiki/classes--<name>.md` per class/struct (skip trivial typedefs), `wiki/modules--<name>.md` overview.
7. Cross-link confirmed edges only: `[[files--<n>]]`, `[[functions--<n>]]`, `[[classes--<n>]]`.
8. Update `wiki/index.md` and `wiki/log.md`.

## Ingest — File

1. Read source. Create `wiki/files--<filename>.md`.
2. Create `wiki/functions--<fn>.md` / `wiki/classes--<name>.md` for definitions >5 lines.
3. **Validate**: `rg -n` confirms line numbers. `rg` confirms callers/callees.
4. Cross-link confirmed edges only. Update index and log.

## Sync — Detect and Update Changed Files Only

Run when user says "sync", "update code graph", "refresh".

1. `git checkout develop && git pull origin develop`
2. Read `last_commit` from `raw/.git_commit`. If missing: `git log --oneline -1 --format="%H" develop`.
3. `git diff --name-status <last_commit> develop -- libs/dlp/`
   - `A` → Ingest — File
   - `D` → delete `wiki/files--<name>.md` + `wiki/functions--*.md` + `wiki/classes--*.md` for that file, remove from index, remove inbound links from other pages
   - `M` → Update — File
   - No output → nothing changed, stop
4. Write `develop` commit to `raw/.git_commit`.
5. Update `wiki/log.md` with changed filenames only.

## Update — File (modified source only)

1. `diff raw/<filename> <source>` — identify changed line ranges.
2. Re-read source. Update `wiki/files--<filename>.md` for changed functions/classes only — do NOT rewrite unchanged sections.
3. For changed functions: update `wiki/functions--<fn>.md`.
   - `rg -n "<fn>" <file>` confirms new line numbers.
   - `rg "<fn>" /root/code/dataplane/libs/dlp --include "*.cpp" --include "*.hpp"` confirms edges. Remove stale edges. Add new confirmed edges.
4. For changed classes: update `wiki/classes--<name>.md`.
5. Deleted functions/classes: delete wiki page, remove from index, `rg` for inbound links and remove them.
6. New functions/classes: create wiki page, add to index, `rg` for callers and add inbound links.
7. `cp <source> raw/<filename>` — update snapshot.
8. Update index and log with changed filenames only.

## Query

1. Read `wiki/index.md`. Read matching pages. Answer with `[[links]]`.
2. Call-chain spanning >3 functions: create `wiki/flows--<name>.md` with ordered `[[functions--<fn>]]` links.

## Lint

1. Broken wikilinks — `[[target]]` page does not exist.
2. Orphan pages — zero inbound links.
3. Missing pages — function/class listed in a file page but no dedicated page.
4. Stale snapshots — `diff raw/<filename> <source>` non-empty.
5. Invalid line numbers — `rg -n "<fn>" <source>` does not match written line number.
6. Invalid call edges — `rg "<fn>" /root/code/dataplane/libs/dlp --include "*.cpp" --include "*.hpp"` returns 0 hits.
7. Report table. Offer to fix.

## Page format

- **File** `wiki/files--<filename>.md`: 1-sentence purpose, functions with `file.cpp:NNN` line refs, `#include` list, callers (`[[functions--<fn>]]`), callees (`[[functions--<fn>]]`).
- **Function** `wiki/functions--<fn>.md`: exact signature, 1-sentence purpose, callees (`[[functions--<fn>]]`), callers (`[[functions--<fn>]]`), `file.cpp:NNN` line refs.
- **Class** `wiki/classes--<name>.md`: 1-sentence purpose, members (name + type), methods (`[[functions--<method>]]`), used by (`[[files--<name>]]`).
- **Module** `wiki/modules--<name>.md`: 1-sentence purpose, files (`[[files--<name>]]`), dependencies (`[[modules--<name>]]`).
- **Flow** `wiki/flows--<name>.md`: ordered call chain (`[[functions--<fn>]]`), entry point, exit points.
- **Frontmatter**: `type`, `module`, `created`, `updated`, `source_files`, `tags`.
- **Links**: `[[files--<n>]]`, `[[functions--<n>]]`, `[[classes--<n>]]`.
- **Line refs**: `ns_dlp_accumulator.cpp:727` — verified via `rg -n`.
- **Skip**: functions <5 lines, getters/setters, `typedef` aliases, generated code, test files (unless asked).

## Rules

- NEVER modify `raw/` (except `cp` for snapshot updates and `.git_commit` writes).
- NEVER write a line number without `rg -n` confirmation.
- NEVER write a call edge without `rg` confirmation in source.
- NEVER rewrite unchanged wiki sections — edit only what changed.
- NEVER create pages for functions <5 lines, getters/setters, typedefs, generated code, tests.
- NEVER create flow pages for call chains ≤3 functions.
- All operations on `develop` branch only. NEVER graph from feature branches.
- Source code is the only source of truth. Graph pages are derived.
