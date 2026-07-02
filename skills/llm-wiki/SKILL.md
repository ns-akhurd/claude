---
name: llm-wiki
description: Use when the user wants to ingest sources into or query the LLM wiki at C:\Users\AkshaySanjayKhurd\vault (WSL: /mnt/c/Users/AkshaySanjayKhurd/vault). Triggers on "ingest this", "add to wiki", "wiki", "query wiki", "search wiki", or when the user provides a URL and says "ingest". Also use when the user says "lint the wiki" or "health check the wiki".
user_invocable: true
allowed-tools:
  - Bash(~/.claude/plugins/cache/netskope/eng-skills/*/skills/confluence/scripts/confluence *)
  - Bash(~/.claude/plugins/eng-skills@netskope/skills/confluence/scripts/confluence *)
  - Bash(~/.claude/skills/llm-wiki/scripts/html_to_md.py *)
  - Bash(gh *)
  - Bash(curl *)
  - Bash(python3 *)
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - WebFetch
---

# LLM Wiki — Ingest & Query

Maintain and query the personal knowledge wiki at `/mnt/c/Users/AkshaySanjayKhurd/vault` (Windows: `C:\Users\AkshaySanjayKhurd\vault`).

## Vault structure

```
vault/
├── CLAUDE.md      # Schema — wiki conventions and operations
├── raw/           # Immutable source documents (NEVER modify)
├── wiki/          # LLM-generated markdown pages (YOU own these)
│   ├── index.md   # Catalog of all wiki pages
│   └── log.md     # Chronological operation log
└── .obsidian/     # Obsidian config (managed by Obsidian)
```

## Operations

### Ingest — File

When the user drops a file into `raw/` or points to a local file:
1. Read the source fully.
2. Discuss key takeaways with the user.
3. Create a source-summary page: `wiki/src--<slug>.md` with frontmatter (type, created, updated, sources, tags).
4. Create or update concept/entity pages for key topics — one topic per page.
5. Cross-link new pages to existing wiki pages using `[[wikilinks]]`.
6. Update `wiki/index.md` with entries for any new/changed pages.
7. Append to `wiki/log.md`: `## [YYYY-MM-DD] ingest | <source title>`
8. Flag contradictions with existing wiki pages.

### Ingest — Link

When the user provides a URL:

1. **Determine source type** and fetch:
   - **Confluence** (`netskope.atlassian.net/wiki/...`): Extract page ID from URL. Use the confluence CLI:
     ```bash
     ~/.claude/plugins/cache/netskope/eng-skills/1.1.0/skills/confluence/scripts/confluence page <PAGE_ID>
     ```
     Then convert HTML storage body to markdown using:
     ```bash
     python3 ~/.claude/skills/llm-wiki/scripts/html_to_md.py /tmp/opencode/page_<ID>.json
     ```
   - **GitHub** (`github.com/...`): Use `gh` CLI or WebFetch.
   - **Public web pages**: Use WebFetch (returns markdown directly).
   - **Jira** (`netskope.atlassian.net/browse/...`): Use confluence CLI `get` or curl with Atlassian API token.
   - **Other URLs**: Try WebFetch first, fall back to curl.

2. **Save** fetched content to `raw/src--<slug>.md` with frontmatter (source_url, fetched date, page_id, title, author, last_modified).

3. **Run the normal ingest (file) workflow** on the saved file.

4. **Append to log**: `## [YYYY-MM-DD] ingest-link | <url> | <source title>`

5. If fetching fails, tell the user what went wrong and what credentials/tools are needed.

### Ingest — Confluence Page + Children

When the user says "this and all pages under <confluence URL>":

1. Extract parent page ID from URL.
2. Fetch parent page: `confluence page <PARENT_ID>`
3. Fetch all descendants: `confluence get "content/<PARENT_ID>/descendant/page?limit=100"`
4. Parse descendant IDs from JSON response.
5. Fetch each child page in parallel (background `&` processes, write to `/tmp/opencode/page_<ID>.json`).
6. Convert each to markdown using `html_to_md.py`.
7. Save all to `raw/`.
8. Create wiki pages: one overview/source-summary for the parent, individual source-summaries for each child, concept pages for key topics.
9. Cross-link everything, update index and log.

### Query

When the user asks a question against the wiki:

1. Read `wiki/index.md` to find relevant pages.
2. Read the relevant wiki pages.
3. Synthesize an answer with `[[wikilinks]]` citations.
4. If the answer is substantial, file it back as a new wiki page (type: analysis) and update index.
5. Append to log: `## [YYYY-MM-DD] query | <short description>`

### Lint

When the user asks to health-check the wiki:

1. Read `wiki/index.md`.
2. Check for:
   - Contradictions between pages
   - Stale claims superseded by newer sources
   - Orphan pages (no inbound links)
   - Important concepts mentioned but lacking their own page
   - Missing cross-references
   - Broken wikilinks (target page doesn't exist)
3. Report findings in a table.
4. Offer to fix issues.
5. Append to log: `## [YYYY-MM-DD] lint | <summary>`

## Page conventions

- All wiki pages: markdown `.md`, lowercase-hyphenated filenames.
- YAML frontmatter: `type`, `created`, `updated`, `sources`, `tags`.
- Types: `entity`, `concept`, `source-summary`, `comparison`, `analysis`, `overview`.
- Internal links: `[[page-name]]` or `[[page-name|display text]]`.
- Source summary pages: named `src--<slug>.md`.
- Concept pages: named `<topic>.md`.
- NEVER modify files in `raw/`.
- NEVER delete wiki pages without explicit user permission.
- When new data contradicts old claims, flag explicitly — don't silently overwrite.
- Prefer updating existing pages over creating new ones.
- One entity/concept/topic per page.

## URL to page ID extraction

Confluence URLs contain the page ID as the numeric segment before the title:
```
https://netskope.atlassian.net/wiki/spaces/DataSecurityTeam/pages/1908770176/Rule+Engine
                                                    page ID = 1908770176
```

For URLs with query parameters, use the `pageId` parameter.

## HTML to markdown conversion

The script `~/.claude/skills/llm-wiki/scripts/html_to_md.py` converts Confluence storage-format HTML to markdown. Usage:

```bash
python3 ~/.claude/skills/llm-wiki/scripts/html_to_md.py <input.json> [output.md]
```

- Input: JSON file from `confluence page <ID>` (full API response).
- Output: markdown string (to stdout if no output file).
- Handles: headings, lists (nested), tables, links, code blocks, blockquotes, Confluence macros (code, info, warning, note, jira, children).

## Batch fetching Confluence children

```bash
# Get all descendant page IDs
confluence get "content/<PARENT_ID>/descendant/page?limit=100"

# Fetch all in parallel
for id in $(python3 -c "import json; d=json.load(open('/tmp/opencode/descendants.json')); print(' '.join(r['id'] for r in d['results']))"); do
  confluence page $id > /tmp/opencode/page_$id.json 2>&1 &
done
wait
```
