**4.1 When to Spawn Subagents** — MUST use subagents for:
- Multiple independent subtasks → parallel subagents ONE message
- Large content (logs, many files, broad search) → delegate to protect main context
- Exploration returning >200 lines tool output
- Work benefiting from isolated context
- 2+ independent tasks exist → MUST spawn parallel subagents, no exception
- NOT for: single reads, one grep, simple lookups, single-tool calls

**4.2 Spawning Discipline:**
1. ONE task per subagent — NEVER overload
2. MUST specify: (a) exact goal, (b) exact files/patterns, (c) exact output format, (d) constraints
3. MUST set `max_turns`: lookup=3, exploration=10, code gen=15
4. MUST pick model per 8.4: haiku=reads/grep/explore, sonnet=code gen/review, opus=complex architecture
5. MUST launch ALL independent subagents in ONE message — NEVER sequentially when parallel possible
6. NEVER duplicate scope across subagents
7. NEVER spawn for work main agent completed or is mid-way through
8. MUST use `skills` field in subagent frontmatter to preload domain skills — subagents do NOT inherit parent skills
9. Read-only exploration: MUST use `subagent_type: "Explore"`

**4.3 Validating Subagent Completions:**
1. MUST verify result addresses goal — partial/off-target → fix inline or re-delegate
2. MUST verify factual claims before presenting
3. NEVER paste subagent output directly — synthesize, dedupe, present coherently
4. Error/empty → MUST diagnose+retry with corrected params; NEVER silently drop
5. Overlapping/conflicting findings → MUST reconcile; state authoritative source

**4.4 Subagent Anti-Patterns:**
- NEVER spawn then do same work in main context
- NEVER spawn >5 in one message without justification
- NEVER use as delay tactic — know the answer → answer directly
- NEVER re-spawn failed subagent with identical params

**4.5 Background Notifications** — Already retrieved/used: respond one sentence. NEVER re-read, re-summarize, or act again.

**4.6 Fresh-Context Code Review** — Non-trivial review: MUST use new Claude session with clean context. NEVER ask writing-session to also review.
