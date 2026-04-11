**5.1 Design Doc Completeness** — Every plan/design doc/architecture proposal MUST have 3+ sentence sections for all 10:
1. Security — auth, data isolation, encryption, network exposure
2. Error handling — every failure mode with detection + recovery
3. Scaling — multi-device, multi-tenant, capacity limits
4. Performance — quantitative targets justified against specs
5. Capacity planning — memory/pool sizing with workload calculations
6. Operational tooling — metrics, alerting thresholds, diagnostics
7. Version constraints — specific versions, not just library names
8. Hot-reload — update config without restart
9. Upgrade/rollback — safe dependency update procedure
10. Resource cleanup — orderly shutdown, leak prevention

**5.2 Redo = Clean Rebuild** — "redo"/"scrap this"/"do it better" → MUST build cleanest solution from scratch. NEVER patch incrementally.

**5.3 Single Source of Truth** — If data exists as an authoritative source: load dynamically, delete static copy. NEVER create a second copy.

**5.4 Sample Actual Data** — Before writing any display/format function: MUST grep/query actual data source to find ALL real values first. NEVER write formatter based on assumed values.

**5.5 Label Computed Values** — In any user-facing output: MUST label computed/estimated metrics (e.g., "~est.", "calc."). NEVER present computed values as exact system measurements.

**5.6 Demand Elegance (Balanced)** — For non-trivial changes:
- MUST evaluate whether a simpler approach exists before finalizing
- If a fix feels hacky: MUST apply the rule "Knowing everything I know now, implement the elegant solution"
- NEVER apply elegance checks to simple, obvious fixes.

**5.7 Parallel Component Symmetry** — IF adding a feature, parameter, or behavioural change to one component in a set of functionally parallel components (engines, adapters, services, plugins, clients):
1. MUST immediately identify ALL sibling components in that set
2. MUST apply the same change to ALL siblings in the SAME pass — NEVER wait for the user to ask "same for X?"
3. MUST document any sibling where the change intentionally does NOT apply, and state the reason explicitly

**5.8 Grep Before Add** — Before writing any new function, constant, or data structure:
- MUST grep the codebase for existing similar implementations first
- If one exists: extend or reuse it — NEVER create a near-duplicate
