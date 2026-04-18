**6.1 Citation & Link Validation** — Report/research doc with external sources:
- MUST `WebFetch` every URL before citing; add inline `[[N]](url)` on every factual claim
- MUST use direct block-quotes; label inferred: `*(inferred from [[N]] — no direct measurement)*`
- MUST include end reference table: `| # | Document | URL | Status |`
- NEVER submit without: all URLs fetched, all claims cited, failed URLs flagged, ref table present

**6.2 Complete Data Display** — MUST show ALL items. NEVER truncate to "top N". >1000 → write to file. NEVER summarize when asked to display.

Multi-dimensional data (N patterns × M row sizes, N engines × M configs):
1. MUST show ALL N×M combinations — NEVER pick "representative" rows/columns
2. NEVER produce single summary table collapsing a dimension; use per-group subtables
3. Before submitting: verify all N×M values shown; if NO, expand.

**6.3 Executive-Ready Documentation** — Doc for executives/leadership/cross-functional:
1. MUST be concise — remove filler/hedging/redundancy
2. MUST define every term/acronym inline on first use. NEVER assume reader knows jargon.
3. MUST back every factual claim with inline ref: `[[N]](url)`, internal doc, or data source.
4. MUST include **References** section: `| # | Source | Link/Location | Status |`
5. NEVER include content not serving stated goal
6. MUST use numbered lists/tables/bullets; paragraphs ≤2-3 sentences
7. MUST lead with conclusion — NEVER build up to the point
8. NEVER include implementation details/code/CLI unless required
9. Rule 5.5 applies: MUST label computed/estimated values

NEVER declare exec doc complete without verifying all 9.

**6.4 Deployment Guide Completeness** — Step-by-step install/deploy guide:
1. MUST simulate on fresh machine — every step: verify ALL CLI tools installed in prior step
2. MUST add **"Resume here after reboot"** callout at every step requiring reboot/cold cycle
3. MUST replace hardware-specific paths with discovery command; hardcoded path only as "path will look like..." example
4. MUST check every `export VAR=...` — needed in future step/session → persist via `/etc/profile.d/`, `~/.bashrc`, or `ldconfig`; NEVER leave env-only for multi-step guides
5. MUST check every `sudo <cmd>` following `export VAR=...` — sudo strips env; MUST use `sudo env VAR=... cmd`, system registration, or document export unnecessary
6. MUST include in Prerequisites: disk space estimate + explicit sudo/root requirement
7. MUST provide full path for every script/file cross-referenced by name
8. MUST show before AND after state for any config edit
9. MUST verify step ordering satisfies deps — no step may require later-step output/files/packages

NEVER declare deploy guide complete without checking all 9.
