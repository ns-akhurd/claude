---
name: docgen
description: Use when user invokes /docgen [topic] or asks to generate a structured document. Produces a point-form document with table of contents, each concept as bullets (no paragraphs), terse and precise, validated by the grill skill before done.
---

# docgen

Generate a structured, point-form document. Lead with key goals. No filler, no repetition, no prose paragraphs, no em dashes.

## Step 0: Read Before Writing

If the topic names a file, function, system, or component:
1. Locate via LSP (`workspaceSymbol` → `goToDefinition`) or `grep` if LSP unavailable.
2. Read actual source. NEVER document from memory or training data alone.
3. Read callers/callees relevant to understanding (max 3 hops).
4. Anchor claims with `file:line` citations where useful.

If purely conceptual (no code artifact): skip Step 0. Use trusted sources only; if WebFetch needed, fetch before writing.

## Step 1: Identify Key Goals

1. Parse the user request. Extract the goals the document MUST address.
2. NEVER add sections not asked for. If unsure whether a section is wanted → ask one focused question (rule 3.0) BEFORE writing.
3. Write the goal list as the first thing in the doc, under a `## Goals` heading.
4. Every later section MUST map to a goal. No goal → no section.

## Step 2: Table of Contents

1. Build the TOC from the goal list ONLY.
2. One TOC entry per goal (or per concept needed to reach a goal).
3. Order: dependency order, not alphabetical. Reader follows top-to-bottom without forward refs.
4. Link each TOC entry to its heading anchor.

## Step 3: Write Each Concept as Points

For every section:
- Headings: `##` and `###` only. One concept per heading.
- Body: bullets and nested bullets ONLY. NEVER write a prose paragraph.
- One sentence per bullet. Terse. Strip filler ("Note that", "It is important to", "This means that", "In order to").
- Depth: 2 to 3 levels. Stop when nesting adds no new info.
- Vocabulary: high-impact nouns and verbs. Avoid weak verbs (is, has, uses → performs, holds, invokes).
- Code/config: use fenced code blocks. Keep snippets minimal: only the lines that teach the concept.

## Step 4: Hard Formatting Rules

- NEVER use em dashes (— or --). Use period, comma, colon, or parentheses.
- NEVER explain the same concept twice. If a later section needs it, link back to the first occurrence, do not restate.
- NEVER add sections the user did not ask for (Summary, Conclusion, Background, Glossary, "Why this matters") unless requested.
- NEVER write intro or outro sentences. Start with content. End with content.
- Keep language simple for a human reader. Plain words. No jargon when a plain word works.
- Label computed or estimated values (e.g., "~est.", "calc."). Never present estimates as exact measurements.

## Step 5: Grill Validation (MANDATORY before done)

1. After the draft is complete, invoke the `grill` skill (Skill tool, name: `grill`) on the generated document.
2. Scope = the document file(s) written this session.
3. Treat grill findings as blockers for these additional lenses:
   - **Redundancy**: same concept explained in two places → `[GAP]`. Keep the first, link from the second.
   - **Paragraph leak**: any prose paragraph outside code/table → `[CRITICAL]`. Rewrite as bullets.
   - **Em dash present**: any `—` or `--` used as punctuation → `[CRITICAL]`. Replace per Step 4.
   - **Unrequested section**: a section with no mapping to a goal → `[GAP]`. Delete it.
   - **Vague/hedged bullet**: "might", "could", "perhaps", "it seems" without a real uncertainty → `[GAP]`. State directly.
   - **Jargon without plain-word alt**: term a general reader would not know, used where a plain word works → `[SMELL]`.
4. Fix ALL findings in severity order (CRITICAL → GAP → UNCLEAR → SMELL) per grill Step 6.
5. Re-grill after fixes. Repeat until grill returns **PASS** (no CRITICAL/GAP).
6. Safety cap: 4 grill iterations. Not PASS after 4 → stop, surface remaining findings to the user.
7. NEVER declare the document done before grill returns PASS.

## Step 6: Output

- Write the document to the file path the user gave, or to `<topic>.md` in CWD if none given.
- Print the file path and the final grill verdict (PASS / remaining findings). One line each.
- No recap, no closing paragraph.

## Document Template

```
# [Document title]

## Goals
- [Goal 1]
- [Goal 2]
- ...

## Table of Contents
1. [Section 1](#section-1)
2. [Section 2](#section-2)
...

## [Section 1]
- [Point 1]
  - [Sub-point 1]
  - [Sub-point 2]
- [Point 2]
  - [Sub-point]

## [Section 2]
- [Point]
  - [Sub-point]
```

## Example

```
# User Auth Flow

## Goals
- Explain how a user logs in.
- Explain token refresh.

## Table of Contents
1. [Login](#login)
2. [Token Refresh](#token-refresh)

## Login
- Client posts credentials to `/auth/login`.
  - Server validates email and password hash.
  - Server issues an access token (15 min) and a refresh token (30 days).
- Client stores tokens in an httpOnly cookie.
  - Refresh token never sent to the browser JS.

## Token Refresh
- Access token expiry triggers a call to `/auth/refresh`.
  - Server validates the refresh token from the cookie.
  - Server issues a new access token; refresh token unchanged.
- Refresh token expired → client redirects to login.
```
