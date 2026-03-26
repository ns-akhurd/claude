---
name: todo
description: Use when user invokes /todo to manage their personal per-project todo list. Handles list, add, remove, done, update, and clear operations. Only acts on explicit user commands — never adds, removes, or modifies items automatically or proactively.
---

# Todo — Personal Per-Project Task List Manager

## Overview

Maintains the user's personal todo list scoped to the **current project** at `<project-root>/.claude/todo.md`. Every operation requires an explicit user command. Agents MUST NOT add, remove, or modify items automatically — not during coding sessions, not from conversational asides, not ever.

**This list is for the user's own items only.** It is NOT the same as `TaskCreate`/`TaskUpdate` (which track agent work). Never conflate the two.

## Storage

**File:** `<cwd>/.claude/todo.md` — where `<cwd>` is the current working directory (project root)
**Format:** Numbered markdown checkboxes

```markdown
# Todo

1. [ ] Buy milk
2. [x] Fix login bug
3. [ ] Call dentist
```

Each project has its own independent list. If the user switches projects (different CWD), they get a different list.

If the file does not exist, create `.claude/todo.md` in the CWD with the `# Todo` header when the user first adds an item. Never create it speculatively.

## Operations

| User says | Action |
|-----------|--------|
| `/todo` or `/todo list` | Read file, display all items with numbers and status |
| `/todo add <text>` | Append new `[ ]` item, assign next number |
| `/todo remove <n>` | Delete item n, renumber remaining items |
| `/todo done <n>` | Change item n from `[ ]` to `[x]` |
| `/todo undone <n>` | Change item n from `[x]` to `[ ]` |
| `/todo update <n> <new text>` | Replace item n's text, keep its checkbox state |
| `/todo clear` | Remove all `[x]` (completed) items, renumber remaining |

## Display Format

Always show the full list after any write operation so the user sees the result:

```
# Todo

1. [ ] Buy milk
2. [ ] Call dentist
```

If list is empty: `Your todo list is empty.`

## The Imperative Rule

**ONLY act when the user explicitly invokes a todo operation.**

| Situation | Correct behavior |
|-----------|-----------------|
| User mentions "I should do X later" during a chat | Do nothing. No auto-add. |
| User completes a task you were helping with | Do nothing. No auto-done. |
| User asks you to do a coding task | Do nothing to the todo list. |
| User says "/todo add X" | Add X. Confirm with updated list. |

**Never suggest adding items.** Never ask "Should I add that to your todo list?"

## Common Mistakes

- **Wrong storage location** — Personal todos live at `<cwd>/.claude/todo.md`. The global `~/.claude/` and `tasks/todo.md` are wrong locations.
- **Auto-adding from context** — A user saying "remind me to X" or "I should X" is NOT a `/todo add` command.
- **Conflating with TaskCreate** — `TaskCreate`/`TaskUpdate` MCP tools track agent work sessions. Never use them for user's personal list.
- **Renumbering on display** — Always keep item numbers stable between operations; only renumber after `remove` or `clear`.
