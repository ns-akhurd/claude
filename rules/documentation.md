**6.1 Citation & Link Validation** — In any report/research doc with external sources:
- MUST `WebFetch` every URL before citing; add inline `[[N]](url)` on every factual claim
- MUST use direct block-quotes; label inferred claims: `*(inferred from [[N]] — no direct measurement)*`
- MUST include reference table at end: `| # | Document | URL | Status |`
- NEVER submit without: all URLs fetched, all claims cited, failed URLs flagged, reference table present

**6.2 Complete Data Display** — MUST show ALL items. NEVER truncate to "top N". If >1000 items → write to file. NEVER summarize when asked to display.

IF the data has multiple dimensions (e.g., N patterns × M row sizes, N engines × M configs):
1. MUST show ALL N×M combinations — NEVER pick "representative" rows or columns as a substitute
2. NEVER produce a single summary table that collapses a dimension; produce per-group subtables if needed
3. Before submitting: verify all N×M values shown. If NO, expand.

**6.3 Executive-Ready Documentation** — IF creating a document intended for executives, leadership, or cross-functional stakeholders:
1. MUST be concise — remove filler, hedging, redundancy
2. MUST define every term/acronym inline on first use. NEVER assume reader knows jargon.
3. MUST back every factual claim with inline reference: `[[N]](url)`, internal doc, or data source. NEVER state facts without attribution.
4. MUST include a **References** section at the end with all cited sources: `| # | Source | Link/Location | Status |`
5. NEVER include content that does not directly serve the document's stated goal
6. MUST use numbered lists, tables, bullets over prose; limit paragraphs to 2-3 sentences.
7. MUST lead with conclusion/result — NEVER build up to the point.
8. NEVER include implementation details, code snippets, or CLI commands unless the document explicitly requires them
9. Rule 5.5 applies: MUST label computed/estimated values

NEVER declare exec-facing doc complete without verifying all 9 items.

**6.4 Deployment Guide Completeness** — IF writing or reviewing a step-by-step installation/deployment guide:
1. MUST simulate execution on a **fresh machine** — for EVERY step, verify ALL CLI tools used are installed in a prior step
2. MUST add **"Resume here after reboot"** callout at every step ending with a required reboot or cold power cycle
3. MUST replace every **hardware-specific path** with a discovery command; any hardcoded path MUST appear only as a "path will look like..." example
4. MUST check every `export VAR=...` — if needed in a future step or new session, MUST persist via `/etc/profile.d/`, `~/.bashrc`, or `ldconfig`; NEVER leave env-only vars for multi-step guides
5. MUST check every `sudo <cmd>` following an `export VAR=...` — sudo strips user env vars; MUST either use `sudo env VAR=... cmd`, register via system mechanism, or document that the export is not needed
6. MUST include in Prerequisites: estimated disk space and explicit sudo/root access requirement
7. MUST provide the full path or location of every script/file cross-referenced by name
8. MUST show **before AND after** state for any configuration file edit
9. MUST verify step ordering satisfies dependency order — no step may require output, files, or packages from a later step

NEVER declare deployment guide complete without checking all 9 items.
