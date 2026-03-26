# Task List Creation Process

You are creating a tasks breakdown from a given spec and requirements for a new feature.

## PHASE 1: Get and read the spec.md and/or requirements document(s)

You will need ONE OR BOTH of these files to inform your tasks breakdown:
- `agent-os/specs/[this-spec]/spec.md`
- `agent-os/specs/[this-spec]/planning/requirements.md`

IF you don't have ONE OR BOTH of those files in your current conversation context, then ask user to provide direction on where to you can find them by outputting the following request then wait for user's response:

```
I'll need a spec.md or requirements.md (or both) in order to build a tasks list.

Please direct me to where I can find those.  If you haven't created them yet, you can run /shape-spec or /write-spec.
```

## PHASE 1.5: Collect referenced documents

After reading the spec, scan for references to external documents containing exact definitions (e.g., "defined in api-spec.md section 6", "schema from schema.sql", "per design-doc.md"). Collect all such documents — they must be passed to the task-list-creator alongside the spec.

## PHASE 2: Create tasks.md

Once you have `spec.md` AND/OR `requirements.md`, use the **tasks-list-creator** subagent to break down the spec and requirements into an actionable tasks list with strategic grouping and ordering.

Provide the tasks-list-creator:
- `agent-os/specs/[this-spec]/spec.md` (if present)
- `agent-os/specs/[this-spec]/planning/requirements.md` (if present)
- `agent-os/specs/[this-spec]/planning/visuals/` and its' contents (if present)
- **All referenced documents from Phase 1.5**

**Include this instruction in the task-list-creator prompt:**

> When the spec references another document for exact definitions, you MUST read that document and transcribe the exact names, types, and structures. Never infer or paraphrase field-level details.

The tasks-list-creator will create `tasks.md` inside the spec folder.

## PHASE 2.5: Verify tasks against source documents

After tasks.md is created, use a **spec-verifier** or **Explore** agent to cross-check tasks against the spec and all referenced documents. Check field name accuracy, completeness, and structural correctness. If discrepancies are found, list them and regenerate.

## PHASE 3: Inform user

Once the tasks-list-creator has created `tasks.md` AND verification has passed, output the following to inform the user:

```
Your tasks list ready!

✅ Tasks list created: `agent-os/specs/[this-spec]/tasks.md`
✅ Verified against source documents

NEXT STEP 👉 Run `/implement-tasks` (simple, effective) or `/orchestrate-tasks` (advanced, powerful) to start building!
```
