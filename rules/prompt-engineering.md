**16.1 XML Prompt Structure** — Writing prompts (subagent, skill, delegation): MUST use XML tags `<context>`, `<instructions>`, `<constraints>`, `<output_format>`. One element per tag; tag names must match semantic purpose. Consistency across a session matters more than specific names.

**16.2 Documents Above Instructions** — Prompt includes docs ≥20k tokens: MUST place ALL documents BEFORE instruction text. Placing long docs after instructions degrades response quality by ~30%.

**16.3 Concrete Examples Over Abstract Descriptions** — Desired output style/format/tone: MUST provide 2-3 concrete examples in `<example>` tags. NEVER describe abstractly ("be professional, concise") — Claude pattern-matches examples more reliably than prose descriptions.

**16.4 Explicit Scope Boundaries** — Instruction applies to multiple items: MUST state scope explicitly ("apply this to all three strategies, not just the first"). NEVER assume Claude will generalize silently — Opus 4.7 is more literal and will process only what's explicitly scoped.

**16.5 Positive Format Examples Beat Negative Constraints** — Controlling verbosity/concision: MUST show a positive example at the desired level. NEVER rely solely on "don't be verbose" — positive examples outperform prohibitions for format control.

**16.6 Explicit Anti-Pattern Constraints** — MUST include "do NOT" lines for known bad output defaults: preambles, platitudes, hedging openers (e.g., "Do NOT open with 'In today's rapidly evolving...'", "Skip preamble — start with the key insight"). Claude won't suppress these without explicit instruction.

**16.7 No Unfilled Placeholders** — MUST fill every `[PLACEHOLDER]` in prompt templates before submission. NEVER send prompts with template variables remaining — they degrade output quality silently.

**16.8 Reasoning Separation** — Complex analysis: MUST add `<analysis>` tag for reasoning and a separate `<output>` tag for the final answer, OR instruct "think through this step by step in <analysis> before answering". Prevents pattern-matching and back-filled justifications.

**16.9 Prompt Structure Order** — MUST follow: `<context>` → `<instructions>` → `<constraints>` → `<output_format>` → `<examples>`. NEVER put instructions before context — Claude reads top-to-bottom and context-starved instructions produce worse results.
