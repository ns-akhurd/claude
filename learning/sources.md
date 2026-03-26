# Learning Sources

Edit this file to add/remove sources. The `/learn-web` skill reads this at runtime.

## Active Sources

| Category | Source | URL | Status |
|---|---|---|---|
| Docs | Claude Code official best practices | `https://code.claude.com/docs/en/best-practices` | OK |
| Docs | Claude Code memory/CLAUDE.md guide | `https://code.claude.com/docs/en/memory` | OK |
| Docs | Claude Code hooks reference | `https://code.claude.com/docs/en/hooks-guide` | OK |
| Docs | Claude Code skills guide | `https://code.claude.com/docs/en/skills` | OK |
| Docs | Claude Code sub-agents guide | `https://code.claude.com/docs/en/sub-agents` | OK |
| Blog | Anthropic blog | `https://www.anthropic.com/blog` | OK |
| Blog | Simon Willison | `https://simonwillison.net` | OK |
| HN | HN top Claude Code stories | `https://hn.algolia.com/api/v1/search?query=claude+code&tags=story&numericFilters=points%3E50` | OK |
| HN | HN top agentic AI stories | `https://hn.algolia.com/api/v1/search?query=agentic+coding&tags=story&numericFilters=points%3E50` | OK |
| HN | HN top CLAUDE.md / system prompt stories | `https://hn.algolia.com/api/v1/search?query=CLAUDE.md&tags=story&numericFilters=points%3E20` | OK |
| GitHub | Anthropic Cookbook | `https://github.com/anthropics/anthropic-cookbook` | OK |
| Tracker | Claude Code degradation tracker | `https://marginlab.ai/trackers/claude-code/` | OK |
| Research | Claude Code tool-choice research | `https://amplifying.ai/research/claude-code-picks` | OK |
| Reddit | r/ClaudeAI top weekly | `https://www.reddit.com/r/ClaudeAI/top/.json?t=week&limit=15` | BLOCKED — skip |
| Reddit | r/LocalLLaMA top weekly | `https://www.reddit.com/r/LocalLLaMA/top/.json?t=week&limit=10` | BLOCKED — skip |
| Reddit | r/programming AI posts | `https://www.reddit.com/r/programming/search.json?q=claude+ai+coding&sort=top&t=week` | BLOCKED — skip |
| GitHub | awesome-claude-code | `https://github.com/heshenxian1/awesome-claude-code` | 404 — skip |
| Blog | Simon Willison — Agentic Engineering Patterns | `https://simonwillison.net/guides/agentic-engineering-patterns/` | OK |
| GitHub | Addy Osmani — Gemini CLI Tips (agentic coding patterns) | `https://github.com/addyosmani/gemini-cli-tips` | OK |
| X/Twitter | Andrej Karpathy (nitter) | `https://nitter.net/karpathy` | EMPTY — skip |
| X/Twitter | Simon Willison (nitter) | `https://nitter.net/simonw` | EMPTY — skip |
| X/Twitter | Anthropic AI (nitter) | `https://nitter.net/AnthropicAI` | EMPTY — skip |

## Tip Extraction Criteria

Extract tips matching ANY of:
- Claude-specific prompting techniques
- CLAUDE.md / system prompt patterns
- MCP server usage tricks
- Claude Code CLI workflows
- AI pair-programming patterns
- Agentic loop / multi-agent patterns
- Context window management techniques
- Dev productivity with AI tools
- Insights from Karpathy / Willison / Anthropic team

## Auto-Promote Criteria (HIGH confidence only)

Only auto-promote to CLAUDE.md if ALL of:
- Confidence = HIGH
- Not semantically covered by any existing CLAUDE.md rule
- Can be stated as an unambiguous MUST/NEVER directive
- Verified by 2+ sources OR from authoritative source (Anthropic, Karpathy, Willison)
