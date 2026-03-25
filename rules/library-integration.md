### Initialization & State

**15.1 Zero-Init All Structs** — MUST initialize every field of any struct passed to a library call — even fields believed to be "output-only." NEVER rely on stack or heap defaults. Use `memset` or designated initializers for the full struct before setting required fields.

**15.2 Initialize Every Pointer in Arrays** — MUST ensure every `array[i]` points to a valid, allocated object before passing `type **array` to a library.

**15.3 Never Read Back Fields You Set** — NEVER assume the library preserves your fields on output. MUST track your own state (e.g., a parallel array indexed by slot ID) rather than reading back fields post-call.

### Debugging & Root Cause

**15.4 Exhaust Caller-Side Causes First** — MUST eliminate uninitialized memory, use-after-free, wrong argument, and wrong API usage as root causes BEFORE attributing a crash to the library. NEVER blame the library without proof.

**15.5 Never Generalize from One Failure** — MUST NOT write a constraint into documentation from a single failure mode. MUST test multiple configurations before concluding on limits.

**15.6 Use Core Dumps and Disassembly** — When source is unavailable, MUST use core dumps and disassembly to identify the crashing instruction and trace bad register/field values back to caller code. NEVER guess root cause from symptoms alone.

### Performance

**15.7 Sweep Parameters Systematically** — MUST sweep parameters (e.g., batch size 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024) before concluding on performance limits.

**15.8 Distinguish Software from Hardware Ceiling** — MUST determine whether a throughput plateau is caused by caller code or the device. Run at multiple concurrency levels/batch sizes to confirm which is the bottleneck.

**15.9 A/B Test Every Optimization** — MUST measure before and after every optimization against the library. Revert if slower.

**15.10 Verify Allocator Caching Behavior** — MUST verify that freed resources are actually available for reuse when pool size is tight relative to in-flight concurrency.

**15.13 Challenge Suspiciously Low Throughput** — IF measured throughput is <20% of theoretical hardware bandwidth, MUST investigate whether software is the bottleneck before accepting the number as a hardware limit. NEVER accept low throughput as "hardware reality" without ruling out caller-side bugs.

**15.14 Re-Verify Prior-Session Constraints** — When resuming performance work across sessions, MUST re-test any documented hardware/library constraint that limits throughput or capability — NEVER trust prior-session claims without fresh evidence.

### Benchmarking

**15.15 Design Benchmark Methodology Before Code** — Before writing any benchmark, MUST define and document: (1) timer scope — exactly what is inside vs outside the timed section, (2) work equivalence — both engines MUST do identical work inside the timed section, (3) throughput formula — standard, reviewed once, (4) no non-O(1) operations (sets, maps, allocations) inside timed loops.

**15.16 Remove Old Approach When Pivoting** — When changing implementation approach, MUST remove the old approach's code in the same commit.

### Documentation

**15.11 No Speculative Root Causes as Facts** — MUST NOT document a root cause as confirmed unless you have evidence (disassembly, reproducer, vendor confirmation). If the mechanism is unknown, write "crashes for unknown reasons" with reproduction steps only.

**15.12 Update Docs When Constraints Are Disproven** — MUST update documentation immediately when a previously-documented limitation is disproven. NEVER leave stale constraints in any file.
