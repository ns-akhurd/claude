---
name: plearn
description: Review the current session and extract project-specific learnings — architecture decisions, code conventions, tooling quirks, domain knowledge, build/test commands — then persist them to the project CLAUDE.md and project auto-memory. Unlike /learn (which updates global agent directives), /plearn captures what is true about THIS codebase. Use at the end of any session where you learned something new about the project.
---

You are extracting project-specific knowledge from this session and persisting it to the project's CLAUDE.md and auto-memory. This is distinct from global agent behavior rules — you are capturing facts about this codebase.

## Step 1 — Identify the project CLAUDE.md

Check in order:
1. `./CLAUDE.md`
2. `./.claude/CLAUDE.md`

If neither exists: create `./CLAUDE.md` as a new file with the heading `# Project Instructions` and an empty body before proceeding. NEVER skip straight to updates without reading the existing file first — read it in full.

## Step 2 — Scan the session for project-specific signals

Re-read the full conversation. Collect every instance of:

| Signal | Examples |
|---|---|
| **Build/test commands discovered** | `npm run dev`, `make test`, `pytest -x`, custom scripts |
| **File structure insights** | "handlers live in src/api/", "models are co-located with tests" |
| **Naming conventions** | snake_case vs camelCase, file naming patterns, module layout |
| **Architectural decisions** | "we use Repository pattern", "no ORM — raw SQL via pg", "event-driven via Redis pub/sub" |
| **Gotchas / non-obvious behaviours** | "migration runner must be run before tests", "env var X is required", "DO NOT use library Y" |
| **Domain knowledge** | Business rules, entity relationships, special edge cases |
| **Preferred libraries / tools** | "use zod for validation", "axios not fetch", "vitest not jest" |
| **Code patterns to follow** | Reference implementations, style that differs from defaults |
| **Things that broke** | Bugs fixed, root causes found, traps to avoid |
| **User corrections about the codebase** | Any time user said "actually in this project we..." |

DISCARD:
- Generic best practices Claude already knows (e.g., "write clean code")
- Agent behavioral rules — those belong in global `~/.claude/CLAUDE.md` via `/learn`
- Information that only applied to the specific task in this session
- Anything the existing project CLAUDE.md already states (check before adding)

## Step 3 — Deduplicate against existing project CLAUDE.md

For each candidate finding:
1. Read the current project CLAUDE.md (already loaded in Step 1)
2. Does an existing entry already cover this? → skip
3. Does an existing entry partially cover it but is incomplete? → augment in place
4. Is it new? → add

## Step 4 — Update the project CLAUDE.md

Write all new and augmented entries. Organise into sections that match the file's existing structure, or use these defaults if starting fresh:

```markdown
# Project Instructions

## Build & Test
<!-- commands to build, run, test — things Claude can't infer -->

## Architecture
<!-- patterns, constraints, key design decisions -->

## Code Conventions
<!-- naming, file layout, style rules that differ from defaults -->

## Libraries & Tools
<!-- preferred/required libraries; explicitly banned alternatives -->

## Gotchas
<!-- non-obvious behaviours, required setup steps, known traps -->

## Domain Knowledge
<!-- business rules, entity definitions, edge cases -->
```

Rules:
- MUST be concise — each entry one or two lines maximum
- MUST be specific and verifiable — "use zod for all input validation" not "validate inputs"
- MUST use imperative mood for rules: "Use X", "Never Y", "Always Z"
- NEVER add entries longer than 3 lines — link to docs instead
- NEVER exceed 200 lines total in the project CLAUDE.md
- Check into git so the team benefits

## Step 5 — Update project auto-memory

Read `~/.claude/projects/<project>/memory/MEMORY.md` (create if absent — the directory already exists per auto-memory setup).

Add or update entries for:
- New build/test commands discovered
- Key file paths and their purpose
- Architectural decisions made this session
- Root causes of any bugs fixed

Follow memory rules: index only in MEMORY.md (keep under 200 lines), deep notes in topic files.

## Step 6 — Report to user

```
## /plearn Results

Project CLAUDE.md: <path>
Entries added: N
Entries updated: N
Sections modified: <list>

Auto-memory updated: yes/no

Summary of what was learned:
- <one line per entry>

Run `/memory` to review auto-memory changes.
```

If zero learnings were found: say so clearly — NEVER invent entries to fill the file.
