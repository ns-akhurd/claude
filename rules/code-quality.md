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
4. Bug found in one sibling's helper/utility (path resolution, config lookup, file traversal): MUST inspect ALL siblings for same bug class SAME pass — NEVER wait for failure evidence in sibling before checking

**5.8 Grep Before Add** — Before new function/constant/data structure:
- MUST grep codebase for existing similar
- Exists: extend/reuse — NEVER create near-duplicate

**1.4 Ripple-Effect Checking** — After ANY fix to command/flag/path/CLI: (1) grep ENTIRE repo (`libs/`, `apps/`, `test/`, `src/`) — NEVER limit grep to source dir of changed file; (2) fix broken refs SAME pass. (3) Semantic changes: grep concept name — NEVER rely on literal string grep only. (4) New field on struct/class: grep all construction sites (constructors, factories, `make_shared`/`make_unique`, copy/move, test fixtures) — NEVER assume defaults cover all. (5) Serialization output change (enum/type emits different string): MUST grep all test files for OLD expected string BEFORE touching any test — find ALL assertion sites, fix ALL one pass. NEVER discover incrementally via repeated build failures.

**12.6 Test Injection Without Production Change** — Before adding function pointer/hook/indirection to production code solely for test injection: MUST first check whether a real failure triggers via bad inputs (invalid key length, malformed data, boundary value). If yes, NEVER add production infrastructure — use bad input in test.

**12.7 Error Path Trace-Through** — After writing an error recovery branch (e.g., `patchRedactionOutcome(Error...)`): MUST trace every path from error site to response serialization and verify the error actually prevents downstream side-effects (uploads, writes). NEVER assume a top-of-block guard prevents subsequent calls — read the actual flow.
