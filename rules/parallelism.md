**4.1 When to Spawn Subagents** — MUST use subagents for:
- Multiple independent subtasks → launch parallel subagents in ONE message
- Large content (logs, many files, broad search) → delegate to protect main context
- Any exploration that may return >200 lines of tool output
- Work that benefits from isolated context (separate concern, separate codebase area)
- NOT for: single reads, one grep, simple lookups, or tasks with <3 tool calls

**4.2 Spawning Discipline** — MUST follow when creating subagents:
1. ONE task per subagent — NEVER overload a single subagent with unrelated work
2. MUST specify in the prompt: (a) exact goal, (b) exact files/patterns to examine, (c) exact output format expected, (d) constraints/boundaries
3. MUST set `max_turns` proportional to task complexity: simple lookup=3, exploration=10, code gen=15
4. MUST select model tier per Rule 8.4: haiku for reads/grep/explore, sonnet for code gen/review, opus only for complex architecture
5. MUST launch ALL independent subagents in ONE tool-call message — NEVER spawn sequentially when parallel is possible
6. NEVER duplicate work between subagents — each subagent MUST have a non-overlapping scope
7. NEVER spawn a subagent for work the main agent has already completed or is mid-way through
8. MUST use `skills` field in subagent frontmatter to preload domain-specific skill content — subagents do NOT inherit skills from the parent conversation
9. For read-only exploration: MUST use `subagent_type: "Explore"`

**4.3 Validating Subagent Completions** — AFTER every subagent returns:
1. MUST check the result addresses the original goal — if partial or off-target, either fix inline or re-delegate with corrected prompt
2. MUST verify factual claims from subagents before presenting to user
3. NEVER paste subagent output directly — synthesize, deduplicate, and present coherently
4. IF subagent returns an error or empty result: MUST diagnose and retry with corrected parameters — NEVER silently drop failed subagent results
5. IF multiple subagents return overlapping or conflicting findings: MUST reconcile before presenting — state which is authoritative and why

**4.4 Subagent Anti-Patterns** — NEVER do these:
- NEVER spawn a subagent then immediately do the same work yourself in the main context
- NEVER spawn >5 subagents in a single message without clear justification
- NEVER use subagents as a delay tactic — if you already know the answer, answer directly
- NEVER re-spawn a failed subagent with identical parameters — adjust the prompt, scope, or model first

**4.5 Background Notifications** — If already retrieved and used: respond in one sentence. NEVER re-read, re-summarize, or act again.

**4.6 Fresh-Context Code Review** — For non-trivial code review: MUST use a separate new Claude session with clean context — NEVER ask the session that wrote the code to also review it.
