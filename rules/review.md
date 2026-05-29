**1.1 Multi-Lens Review** — Doc review/audit: apply ALL 6 lenses ONE pass. NEVER declare complete after fewer.

| # | Lens | Check |
|---|------|-------|
| 1 | Spec alignment | Every statement matches reference |
| 2 | Code alignment | Every command/path/flag matches disk — READ files |
| 3 | Internal consistency | No contradictions; counts/sizes/terms consistent |
| 4 | Execution safety | No wrong order / destructive risk; deploy guides → `documentation.md` 6.4 |
| 5 | Ripple effects | Fixes haven't broken other sections/files |
| 6 | Numeric accuracy | Counts/sizes/versions match reality |

Post-edit: MUST verify claims vs code, confirm code executes, count lists/tables, compute formulas first-principles, grep downstream refs. Compute numerics first-principles — NEVER adjust "right direction" without arithmetic. Diff code sketches token-by-token vs file.

**1.2 Exhaustive First-Pass Reading** — MUST read ANY text line-by-line in full BEFORE output. NEVER skim. Target vs reference: (1) number every requirement in reference; map to target. (2) NEVER write findings before full read.

**1.3 Evidence Provenance** — Asserting code behavior: MUST state source. Prefer actual output over code-reading. NEVER present inferences as confirmed — label: "based on code at X" or "code shows Y (not empirically confirmed)".
