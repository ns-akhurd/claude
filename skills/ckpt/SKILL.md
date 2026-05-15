---
name: ckpt
description: Use when user invokes /ckpt to write a session-state checkpoint file detailed enough for a fresh agent to resume exactly where this session left off. Also use when context is getting large, before /clear, or before ending a long session.
---

# Checkpoint Now

Write a detailed, actionable session checkpoint to `~/.nstools/claude/checkpoints/` so a fresh agent can resume exactly where this session left off.

## Process

### Step 1 — Create Directory

```bash
mkdir -p ~/.nstools/claude/checkpoints
```

### Step 2 — Gather State

Collect ALL of the following. NEVER skip a section — write "None" if empty.

| Section | What to capture |
|---------|----------------|
| **Current Goal** | Primary task/objective this session is working toward |
| **Completed Work** | Every completed step with file paths and what changed |
| **In-Progress Work** | Anything started but not finished — exact state, what's left |
| **Next Steps** | Ordered list of remaining work with enough detail to execute |
| **Key Decisions** | Every design/approach decision with rationale (why X over Y) |
| **Files Touched** | Every file created, modified, or deleted — full absolute paths |
| **Git State** | Branch, worktree path, uncommitted changes (`git status`), recent commits (`git log --oneline -10`), stash entries |
| **Open Questions** | Anything awaiting user input or unresolved ambiguity |
| **Active Subagents/Teams** | Any running background agents, team state, worktree branches |
| **Environment Context** | Relevant env vars, running services, ports, venvs, docker state |
| **Blockers** | Anything preventing progress — errors, missing access, unknowns |
| **Session Learnings** | Bugs found, gotchas discovered, things that didn't work and why |

### Step 3 — Write Checkpoint File

Filename: `~/.nstools/claude/checkpoints/claude-checkpoint-<ISO8601>.md`

Use ISO 8601 timestamp with seconds: `$(date -u +%Y%m%dT%H%M%SZ)`

Example: `claude-checkpoint-20260428T143022Z.md`

**Format:**

```markdown
# Session Checkpoint — [1-line topic]
**Created:** [ISO 8601 timestamp]
**Branch:** [git branch]
**Working Directory:** [pwd]

---

## Current Goal
[Specific, actionable description of what this session is trying to accomplish]

## Completed Work
- [Step 1]: [what was done] — `path/to/file`
- [Step 2]: [what was done] — `path/to/file`

## In-Progress Work
- [What's partially done]: [exact current state, what remains]

## Next Steps
1. [Actionable step with enough detail to execute without context]
2. [Next step]

## Key Decisions
| Decision | Rationale | Alternatives Rejected |
|----------|-----------|----------------------|
| [Choice made] | [Why] | [What else was considered] |

## Files Touched
| Path | Action | Description |
|------|--------|-------------|
| `/full/path` | created/modified/deleted | [What changed] |

## Git State
- **Branch:** [name]
- **Uncommitted changes:** [list or "clean"]
- **Recent commits:**
  ```
  [git log --oneline -10 output]
  ```
- **Stash:** [entries or "empty"]

## Open Questions
- [Question awaiting user input]

## Active Subagents / Teams
- [Agent name/ID]: [task, status]

## Environment Context
- [Relevant env vars, services, ports]

## Blockers
- [Blocker]: [impact, what's needed to unblock]

## Session Learnings
- [Gotcha/bug/discovery]: [details, so next session doesn't repeat]
```

### Step 4 — Output

After writing the file, emit:

```
Checkpoint saved: ~/.nstools/claude/checkpoints/claude-checkpoint-<timestamp>.md
```

Print the **full absolute path** so user can hand it to next session.

## Quality Rules

- MUST be **detail-oriented and actionable** — NOT a high-level summary
- MUST include exact file paths, not descriptions like "the config file"
- MUST include exact git state from actual commands, not memory
- MUST run `git status`, `git branch`, `git log --oneline -10`, `git stash list` — NEVER guess
- Every "Next Step" MUST be executable by a fresh agent with zero session context
- NEVER omit sections — write "None" for empty sections
- NEVER use vague language: "some files were changed", "a few things left"
