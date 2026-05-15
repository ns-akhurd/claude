---
name: pr-description
description: Use when user invokes /pr-description to generate a formatted PR description from current git diff and branch context.
---

# pr-description

## Behavior

When invoked, gather context from the current git branch, then produce a PR description in the exact format below. Fill every section from actual code changes — never leave placeholder text.

## Steps

1. Run `git log main..HEAD --oneline` (or `develop..HEAD`) to list commits on this branch.
2. Run `git diff main...HEAD --stat` to see files changed.
3. Run `git diff main...HEAD` (or read key changed files) to understand what changed and why.
4. Extract the Jira ticket from the branch name (e.g. `feature/ENG-12345-foo` → `ENG-12345`) or from commit messages.
5. Write the description using the template below. Every bullet must be concrete — derived from actual diffs, not generic.

## Output Format

Produce ONLY the markdown below, filled in. No preamble, no "Here is your PR description", no trailing commentary.

```markdown
# Description
**Jira Ticket #:**\
<TICKET-ID>

**Details:**
<2–4 sentence summary of WHAT this PR does and WHY. Reference the feature/bug/ticket context. Be specific — name components, protocols, data structures, or flows touched.>

## Type of change:
**1.) Please describe what is included in this PR (use bullet points):**\
- <concrete change 1>
- <concrete change 2>
- <add more as needed>

**2.) What is _NOT_ included in this PR:**
- <explicitly out-of-scope item 1 — e.g. follow-on work, known gaps, deferred features>
- <add more as needed>

## Manual testing done:
- <describe how the change was verified — build target, test suite run, simulator, manual curl, etc.>

## Additional comments:
<Any context a reviewer needs: architecture decisions, known limitations, follow-up tickets, migration notes. Write "None." if nothing to add.>
```

## Rules

- MUST read actual git diff before writing — never fabricate changes.
- MUST derive Jira ticket from branch name or commits — never invent one.
- "What is NOT included" MUST list at least one item (known gaps, deferred work, or follow-up tickets).
- "Manual testing done" MUST name the actual test binary or command run, not just "tested locally".
- NEVER output the fenced code block markers — output raw markdown only.
- Ticket ID format: if branch has no ticket, write `N/A` for ticket field.
