**5.1 Design Doc Completeness** — Every plan/design/architecture doc MUST have 3+ sentence sections for all 10:
1. Security — auth, data isolation, encryption, network exposure
2. Error handling — every failure mode with detection + recovery
3. Scaling — multi-device, multi-tenant, capacity limits
4. Performance — quantitative targets vs specs
5. Capacity planning — memory/pool sizing with workload calc
6. Operational tooling — metrics, alert thresholds, diagnostics
7. Version constraints — specific versions
8. Hot-reload — config update without restart
9. Upgrade/rollback — safe dep update procedure
10. Resource cleanup — orderly shutdown, leak prevention

**5.2 Redo = Clean Rebuild** — "redo"/"scrap this"/"do it better" → MUST build cleanest from scratch. NEVER patch incrementally.

**5.3 Single Source of Truth** — Data exists as authoritative source: load dynamically, delete static copy. NEVER create second copy.

**5.4 Sample Actual Data** — Before writing any display/format function: MUST grep/query actual source for ALL real values first. NEVER write formatter on assumed values.

**5.5 Label Computed Values** — User-facing output: MUST label computed/estimated (e.g., "~est.", "calc."). NEVER present as exact system measurement.

**5.6 Demand Elegance (Balanced)** — Non-trivial changes:
- MUST evaluate simpler approach before finalizing
- Hacky-feeling fix: MUST apply "Knowing everything I know now, implement the elegant solution"
- NEVER apply elegance check to simple obvious fixes

**5.7 Parallel Component Symmetry** — Feature/param/behavior change to one of a parallel set (engines, adapters, services, plugins, clients):
1. MUST identify ALL siblings
2. MUST apply same change to ALL siblings SAME pass — NEVER wait for "same for X?"
3. MUST document siblings where change intentionally skipped + reason

**5.8 Grep Before Add** — Before new function/constant/data structure:
- MUST grep codebase for existing similar
- Exists: extend/reuse — NEVER create near-duplicate
