---
name: optimize-claude-files
description: Use when Claude instruction files (CLAUDE.md at any level, MEMORY.md, ~/.claude/rules/*.md, topic memory files, skill SKILL.md files) feel bloated, contradictory, stale, or passive. Audits every Claude-facing file agents load, then rewrites for imperative clarity, zero redundancy, and accurate cross-references. Zero directive intent removed.
---

# Optimize Claude Files

Audit every Claude-facing instruction file under a target root and rewrite for optimal agent consumption: imperative, concise, non-redundant, accurate, load-efficient. **Zero behavioural directive intent may be lost** — only expression changes.

## When to Use

- User invokes `/optimize-claude-files` or says "optimize/audit/clean up claude files"
- CLAUDE.md or memory files feel bloated, passive, or contradictory
- Cross-references between files are stale (dead links, wrong filenames)
- MEMORY.md exceeds 200 lines or contains raw session notes
- Lazy-load rule files duplicate content already in parent CLAUDE.md

## When NOT to Use

- Single-file fix — use `refactor-claude` skill instead
- Adding new rules — this is an audit/compress pass, not authoring
- User asks to remove functionality — confirm first, do not silently drop

## Target File Set

MUST discover all of these under the target root (default: `/root/.claude/` + current project):

| File class | Path pattern | Purpose |
|---|---|---|
| Global CLAUDE.md | `~/.claude/CLAUDE.md` | Agent behavioural directives |
| Project CLAUDE.md | `<project>/CLAUDE.md`, `<project>/.claude/CLAUDE.md` | Project conventions |
| Lazy-load rules | `~/.claude/rules/*.md` | Triggered rule bundles |
| Global memory index | `~/.claude/projects/*/memory/MEMORY.md` | Memory index (≤200 lines) |
| Project memory index | `<project>/.claude/memory/MEMORY.md` | Per-project memory index |
| Memory topic files | `**/memory/*.md` (non-MEMORY.md) | Deep memory notes |
| Skill definitions | `~/.claude/skills/*/SKILL.md`, `<project>/.claude/skills/*/SKILL.md` | Skill instructions |
| Plugin skills | `~/.claude/plugins/**/skills/**/SKILL.md` | Plugin-provided skills |

## Step 1 — Discover

Use `Glob` / `Bash find` to enumerate every file matching the table. Build a checklist before reading any content:

```
tasks/optimize-claude-todo.md
  [ ] <path>  — <file class>  — size LOC
```

NEVER re-read a file already read this session (token-efficiency 8.6).

## Step 2 — Read All Targets Once

Batch reads in parallel (one message, many `Read` calls). Record for each file:
- LOC count
- Section headers
- Tables / lists
- Cross-references (other filenames, skill names, URLs)
- Frontmatter (for SKILL.md)

## Step 3 — Audit Every File

Tag every defect. Keep per-file defect list:

| Tag | Meaning | Fix |
|---|---|---|
| `[PASSIVE]` | "consider", "try", "should", "recommend", "may want to" | Rewrite imperative: MUST/NEVER/ALWAYS |
| `[VAGUE]` | Unmeasurable — no testable condition | Add concrete trigger OR delete |
| `[DUPLICATE-INTRA]` | Same directive repeated within one file | Keep stronger; delete weaker |
| `[DUPLICATE-INTER]` | Same directive in 2+ files (e.g., CLAUDE.md AND rules/*.md) | Keep in canonical location; delete elsewhere; add lazy-load pointer |
| `[CONTRADICTION]` | Rules conflict | STOP. Flag to user with both locations. NEVER silently pick one |
| `[BLOAT]` | Prose justification / motivation / narrative | Strip to directive only |
| `[STALE-REF]` | Cross-reference to missing file / renamed skill / dead path | Verify target exists; fix or remove |
| `[EAGER-LOAD]` | `@path/file.md` in CLAUDE.md force-loads content | Convert to lazy-load trigger or skill |
| `[OVERLOAD]` | File exceeds size budget (CLAUDE.md >200, MEMORY.md >200, SKILL.md >500 words for frequently-loaded) | Extract detail to linked file |
| `[NARRATIVE]` | Session-specific story ("in session X, we found...") in skill or rule | Rewrite as reusable pattern OR move to memory |
| `[RAW-NOTE]` | Memory file contains raw session notes not synthesized | Rewrite as concept article |
| `[NO-BACKLINK]` | Memory topic file missing backlink to MEMORY.md index entry | Add entry + 1–2 sentence summary |

## Step 4 — Verify Canonical Location Before Moving Content

Before moving a directive from file A → file B:
1. Confirm B is the canonical location per its file class (see table in Step 1)
2. Grep entire target root for every callsite referencing the directive
3. Fix all callsites in same pass (code-quality 5.7 parallel symmetry)

## Step 5 — Apply Fixes

Rules that MUST hold across edits:

1. NEVER remove a directive whose intent cannot be expressed imperatively — rewrite it instead
2. NEVER merge rules covering distinct triggers
3. NEVER reorder or renumber sections unless deletion creates a gap
4. NEVER change semantics — only expression
5. NEVER drop a cross-reference without replacing it or confirming target truly gone
6. MUST use `Edit` not `Write` for existing files (token-efficiency 8.7)
7. MUST preserve YAML frontmatter fields verbatim on SKILL.md files
8. MUST keep MEMORY.md as index only — 1 line per entry, ~150 chars, with 1–2 sentence summary

## Step 6 — Post-Edit Verification

For each modified file:
1. Count directives before / after — every deletion maps to `[DUPLICATE]` or confirmed-zero-intent `[VAGUE]`
2. For every deleted directive: write the mapping `<deleted> → surviving rule covering it`
3. For every rewritten rule: confirm imperative form covers all original cases
4. Grep-verify every cross-reference resolves to an existing file + section
5. Re-count LOC; confirm size budgets met

## Step 7 — Report

Output one report covering ALL files:

```
## Optimize-Claude-Files Results

Files scanned: N
Files modified: N
Files unchanged: N

Defects per class:
  PASSIVE:         N  (rewrote imperative)
  VAGUE:           N  (sharpened / deleted)
  DUPLICATE-INTRA: N  (consolidated within file)
  DUPLICATE-INTER: N  (consolidated across files)
  CONTRADICTION:   N  (FLAGGED — see below)
  BLOAT:           N  (stripped)
  STALE-REF:       N  (fixed / removed)
  EAGER-LOAD:      N  (converted to lazy-load)
  OVERLOAD:        N  (extracted to linked file)
  NARRATIVE:       N  (rewritten or moved)
  RAW-NOTE:        N  (synthesized)
  NO-BACKLINK:     N  (added)

Directives before: N  |  after: N  |  Intent preserved: 100%

Size deltas:
  <path>: <before> LOC → <after> LOC  (−X%)

Contradictions requiring your input:
  - <fileA>:§X vs <fileB>:§Y — <conflict> → proposed: <text>

Stale refs removed (target file truly gone):
  - <file>:§X referenced <missing-path>

Modified files:
  - <path>
```

## Red Flags — STOP

Any of these: STOP and ask user before proceeding.

- About to delete a rule with no imperative equivalent anywhere
- Contradiction found — never auto-resolve
- Memory topic file with content user may have hand-curated — confirm before compressing
- Plugin-provided SKILL.md under `~/.claude/plugins/` — these are third-party, NEVER edit; only report findings

## Common Mistakes

| Mistake | Fix |
|---|---|
| Deleting rule because wording felt weak, not because intent duplicated | Rewrite; never delete for style |
| Merging `rules/*.md` back into CLAUDE.md | Keep lazy-load split — CLAUDE.md is hot-path context |
| Dropping "Why:" / "How to apply:" lines from memory files | These are load-bearing — memory/feedback entries need them |
| Editing plugin skill files | Read-only. Report only. |
| Renumbering sections that have external callers | Grep callers first; never break inbound refs |
| Compressing code blocks, commands, file paths, versions | Never — only compress prose (token-efficiency 8.11) |

## Success Criteria

After running:
- Every remaining directive is imperative (MUST / NEVER / ALWAYS)
- No directive appears in two files
- Every cross-reference resolves
- CLAUDE.md ≤200 lines; MEMORY.md ≤200 lines
- Every memory topic file has MEMORY.md backlink + 1–2 sentence summary
- Zero directive intent lost vs pre-run state (verified by mapping in Step 6)
