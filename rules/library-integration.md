### Initialization & State

**15.1 Zero-Init All Structs** — MUST initialize every field of any struct passed to library call — even output-only. Use `memset` or designated initializers. NEVER rely on stack/heap defaults.

**15.2 Initialize Every Pointer in Arrays** — MUST ensure every `array[i]` points to valid allocated object before passing `type **array` to library.

**15.3 Never Read Back Fields You Set** — NEVER assume library preserves your fields on output. MUST track own state. NEVER read back post-call.

### Debugging & Root Cause

**15.4 Exhaust Caller-Side Causes First** — MUST eliminate uninitialized memory, use-after-free, wrong argument, wrong API usage as root causes BEFORE attributing crash to library. NEVER blame library without proof.

**15.5 Never Generalize from One Failure** — NEVER document constraint from single failure. MUST test multiple configs before concluding on limits.

**15.6 Use Core Dumps and Disassembly** — Source unavailable: MUST use core dumps + disassembly to identify crashing instruction; trace bad register/field values to caller. NEVER guess from symptoms.

### Performance

**15.7 Sweep Parameters Systematically** — MUST sweep (e.g., batch 1, 2, 4…1024) before concluding on perf limits.

**15.8 Distinguish Software from Hardware Ceiling** — MUST determine if plateau from caller code or device — run multiple concurrency/batch levels.

**15.9 A/B Test Every Optimization** — MUST measure before+after every lib optimization. Revert if slower.

**15.10 Verify Allocator Caching Behavior** — MUST verify freed resources actually reusable when pool tight vs in-flight concurrency.

**15.11 Challenge Suspiciously Low Throughput** — IF throughput <20% theoretical hw bandwidth: MUST investigate software bottleneck before accepting as hw limit.

**15.12 Re-Verify Prior-Session Constraints** — Resuming perf work across sessions: MUST re-test any documented hw/library constraint. NEVER trust prior-session claims without fresh evidence.

### Benchmarking

**15.13 Design Benchmark Methodology Before Code** — Before writing benchmark, MUST document: (1) timer scope — inside vs outside timed section, (2) work equivalence — both engines identical work in timed section, (3) throughput formula — one formula, reviewed once, (4) no non-O(1) ops (sets/maps/allocations) in timed loops.

**15.14 Remove Old Approach When Pivoting** — Changing impl approach: MUST remove old code in same commit.

### Documentation

**15.15 No Speculative Root Causes as Facts** — MUST NOT document root cause as confirmed without evidence (disassembly/reproducer/vendor confirmation). Unknown mechanism → write "crashes for unknown reasons" + repro steps only.

**15.16 Update Docs When Constraints Are Disproven** — MUST update docs immediately when documented limitation disproven. NEVER leave stale constraints.
