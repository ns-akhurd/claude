# Skill: learn-web

Harvest Claude/AI best practices from curated online sources, append to the learning digest, and auto-promote HIGH-confidence tips into CLAUDE.md.

## Invocation
`/learn-web`

## Steps

### 1. Load sources
Read `~/.claude/learning/sources.md` to get the live source list and extraction criteria.

### 2. Fetch all sources (parallel)
Use `WebFetch` on every URL in the sources table. For each:
- Reddit JSON endpoints: parse `.data.children[].data` — extract `title` + `selftext` (first 500 chars). If blocked (403/redirect), log SKIP and continue.
- HN Algolia API: parse `.hits[]` — extract `title` + `url` + `points`. Then fetch the TOP 5 linked article URLs (highest points with a non-null URL) in parallel to extract actual tip content.
- Blog/HTML pages: extract article titles, dates, and summary paragraphs
- Nitter/X pages: extract tweet text. If empty or blocked, log SKIP and continue.
- On fetch error (4xx/5xx/timeout): log `SKIP: <source> — <reason>` and continue; NEVER abort
- Check `sources.md` Status column — skip any source marked `BLOCKED — skip` or `404 — skip` immediately without attempting fetch

### 3. Filter for actionable tips
From all fetched content, extract only items matching the "Tip Extraction Criteria" in sources.md.

Discard:
- Vague general advice ("AI is changing everything")
- Tips already present in `~/.claude/learning/digest.md` (semantic match, not just string)
- Tips already covered by a rule in `~/.claude/CLAUDE.md` (semantic match)
- Tips about non-Claude AI tools unless directly applicable to Claude Code workflow

### 4. Score each tip
- **HIGH**: Concrete, tested, specific workflow/prompt/config trick — directly actionable in Claude Code
- **MEDIUM**: General best practice or conceptual insight — useful but less specific

### 5. Append to digest
Read `~/.claude/learning/digest.md`. Prepend new entries after the `<!-- New entries -->` comment, newest first:

```
### [YYYY-MM-DD] Source: <source name>
**Tip:** <concise, actionable tip — one sentence>
**Confidence:** HIGH | MEDIUM
**Status:** pending
```

Use today's date. Write all new entries in one `Edit` call.

### 6. Auto-promote HIGH tips to CLAUDE.md
For each HIGH confidence tip:
1. Read `~/.claude/CLAUDE.md`
2. Check: Is this semantically covered by ANY existing rule? If yes → skip
3. Check: Can this be stated as an unambiguous MUST/NEVER directive? If no → downgrade to MEDIUM, skip
4. Check: Is it verified by 2+ sources OR from an authoritative source (Anthropic, Karpathy, Willison)? If no → skip
5. If all checks pass:
   - Identify the correct thematic section in CLAUDE.md (match by topic)
   - Append the new rule as the next numbered sub-rule in that section
   - Format: `**N.X New Rule Name** — <imperative rule text>`
   - Update digest entry Status: `[promoted to CLAUDE.md §N.X on YYYY-MM-DD]`

### 7. Discover and add new sources
After fetching existing sources, identify any NEW high-quality sources encountered during this run:
- Blog posts or authors referenced 2+ times in fetched content
- GitHub repos with 200+ stars about Claude Code / AI coding workflows
- Official documentation pages not yet in sources.md
- High-quality HN submissions (500+ points) from domains not yet tracked

For each new candidate:
1. Fetch it to verify it returns actionable content
2. Add it to `~/.claude/learning/sources.md` Active Sources table with `Status: OK`
3. Extract tips from it immediately as part of this run

NEVER add sources that are paywalled, require login, or returned empty/blocked content.

### 8. Report to user
Output a summary:
```
## /learn-web Results — YYYY-MM-DD

Sources fetched: N / M (list skipped sources with reason)
Tips extracted: N
  - HIGH: N
  - MEDIUM: N
New digest entries: N
Auto-promoted to CLAUDE.md: N
  - §X.Y: <rule summary>
  - ...

See ~/.claude/learning/digest.md for full details.
```

## Constraints
- NEVER modify existing CLAUDE.md rules — only append new ones
- NEVER remove or overwrite existing digest entries
- NEVER promote a tip that contradicts an existing CLAUDE.md rule — flag it to the user instead
- NEVER hallucinate sources — only use content actually returned by WebFetch
- If zero tips found: report honestly, do not invent entries
