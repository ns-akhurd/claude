---
name: init-agent-os
description: Use when setting up Agent OS on a new project to enable AI-driven spec writing, task creation, and parallel implementation via Claude Code subagents. Triggers on /init-agent-os or when user asks to set up Agent OS, initialize agent pipeline, or add Claude Code development workflow to a project.
---

# Init Agent OS

## Overview

Bootstraps the Agent OS development pipeline in the current project by writing all agents and commands from this skill's bundled files, creating directory scaffolding, and launching the first planning step.

All agent and command files are bundled inside this skill at:
- `~/.claude/skills/init-agent-os/agents/` — 9 agent files
- `~/.claude/skills/init-agent-os/commands/` — 8 command files

**No external repository is required.**

## Steps

### 1. Confirm project root

MUST verify CWD is the project root (contains a recognizable marker: `.git`, `package.json`, `pyproject.toml`, `Makefile`, etc.). If not, ask the user to confirm the correct directory before proceeding.

### 2. Check for existing setup

Use Glob with pattern `.claude/agents/agent-os/*.md` to check if agents already exist.

- If files found: tell the user Agent OS is already initialized. Ask if they want to overwrite or just add missing files. NEVER silently overwrite.
- If not found: proceed.

### 3. Write bundled agents to project

Read each source file and write it to the project using the Read + Write tools. The Write tool creates parent directories automatically.

**Source:** `~/.claude/skills/init-agent-os/agents/`

Write ALL 9 agents:

| Source | Target |
|--------|--------|
| `~/.claude/skills/init-agent-os/agents/product-planner.md` | `.claude/agents/agent-os/product-planner.md` |
| `~/.claude/skills/init-agent-os/agents/spec-initializer.md` | `.claude/agents/agent-os/spec-initializer.md` |
| `~/.claude/skills/init-agent-os/agents/spec-shaper.md` | `.claude/agents/agent-os/spec-shaper.md` |
| `~/.claude/skills/init-agent-os/agents/spec-writer.md` | `.claude/agents/agent-os/spec-writer.md` |
| `~/.claude/skills/init-agent-os/agents/spec-verifier.md` | `.claude/agents/agent-os/spec-verifier.md` |
| `~/.claude/skills/init-agent-os/agents/spec-auto-completer.md` | `.claude/agents/agent-os/spec-auto-completer.md` |
| `~/.claude/skills/init-agent-os/agents/tasks-list-creator.md` | `.claude/agents/agent-os/tasks-list-creator.md` |
| `~/.claude/skills/init-agent-os/agents/implementer.md` | `.claude/agents/agent-os/implementer.md` |
| `~/.claude/skills/init-agent-os/agents/implementation-verifier.md` | `.claude/agents/agent-os/implementation-verifier.md` |

### 4. Write bundled commands to project

**Source:** `~/.claude/skills/init-agent-os/commands/`

Write ALL 8 commands:

| Source | Target |
|--------|--------|
| `~/.claude/skills/init-agent-os/commands/plan-product.md` | `.claude/commands/agent-os/plan-product.md` |
| `~/.claude/skills/init-agent-os/commands/shape-spec.md` | `.claude/commands/agent-os/shape-spec.md` |
| `~/.claude/skills/init-agent-os/commands/shape-spec-auto-complete.md` | `.claude/commands/agent-os/shape-spec-auto-complete.md` |
| `~/.claude/skills/init-agent-os/commands/write-spec.md` | `.claude/commands/agent-os/write-spec.md` |
| `~/.claude/skills/init-agent-os/commands/create-tasks.md` | `.claude/commands/agent-os/create-tasks.md` |
| `~/.claude/skills/init-agent-os/commands/implement-tasks.md` | `.claude/commands/agent-os/implement-tasks.md` |
| `~/.claude/skills/init-agent-os/commands/orchestrate-tasks.md` | `.claude/commands/agent-os/orchestrate-tasks.md` |
| `~/.claude/skills/init-agent-os/commands/improve-skills.md` | `.claude/commands/agent-os/improve-skills.md` |

### 5. Verify and report

Use Glob to confirm files are present:
- `.claude/agents/agent-os/*.md` — expect 9 files
- `.claude/commands/agent-os/*.md` — expect 8 files

Report to user: "Wrote 9 agents, 8 commands."

### 7. Kick off planning

Tell the user:

```
Agent OS is ready!

✅ 9 agents installed in `.claude/agents/agent-os/`
✅ 8 commands installed in `.claude/commands/agent-os/`
✅ Scaffolding created: `agent-os/product/`, `agent-os/specs/`, `agent-os/standards/`

NEXT STEP 👉 Run `/agent-os:plan-product` to define your product mission, roadmap, and tech stack — this creates the foundation all other agents build on.
```

If the user already described the product in this conversation, offer to run `/agent-os:plan-product` immediately with that context.

---

## Pipeline Reference

| Step | Command | Output |
|------|---------|--------|
| 1 | `/agent-os:plan-product` | `agent-os/product/{mission,roadmap,tech-stack}.md` |
| 2 | `/agent-os:shape-spec` | Requirements gathered interactively |
| 2a | `/agent-os:shape-spec-auto-complete` | Requirements auto-answered by architect AI |
| 3 | `/agent-os:write-spec` | `agent-os/specs/<name>/spec.md` |
| 4 | `/agent-os:create-tasks` | `agent-os/specs/<name>/tasks.md` |
| 5 | `/agent-os:implement-tasks` | One task group implemented per run |
| 5a | `/agent-os:orchestrate-tasks` | All task groups in parallel |
| 6 | `/agent-os:improve-skills` | Improve skill descriptions for discoverability |

## Adding Project-Specific Standards

After setup, populate `agent-os/standards/` with coding conventions docs (e.g., `backend.md`, `frontend.md`, `testing.md`). Agents reference these during implementation to stay consistent with your codebase patterns.

## Guards

- NEVER overwrite existing `.claude/agents/agent-os/` without explicit user confirmation
- NEVER run this in a non-project directory
- If partial setup exists (agents but no commands, or vice versa), report what's missing and write only the missing files
- NEVER source files from any external repository — always use the bundled files in `~/.claude/skills/init-agent-os/`
