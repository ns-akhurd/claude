#!/usr/bin/env python3
"""Convert Confluence storage-format HTML (from API JSON response) to markdown.

Usage:
  python3 html_to_md.py <input.json> [output.md]

Input: JSON file from `confluence page <ID>` — must contain body.storage.value.
Output: markdown to stdout (or file if specified).
"""
import sys
import json
import re
import html
from html.parser import HTMLParser
from bs4 import BeautifulSoup


def get_inline_text(el):
    result = []
    for child in el.children:
        if isinstance(child, str):
            result.append(html.unescape(child))
        elif child.name == 'em':
            result.append(f"*{child.get_text()}*")
        elif child.name == 'strong':
            result.append(f"**{child.get_text()}**")
        elif child.name == 'code':
            result.append(f"`{child.get_text()}`")
        elif child.name == 'a':
            href = child.get('href', '')
            result.append(f"[{child.get_text()}]({href})")
        elif child.name == 'br':
            result.append("\n")
        else:
            result.append(child.get_text())
    return ''.join(result)


def process_list(el, indent=0, ordered=False, start=1):
    lines = []
    items = el.find_all('li', recursive=False)
    for i, li in enumerate(items):
        prefix = "  " * indent
        marker = f"{start + i}." if ordered else "-"
        text_parts = []
        for child in li.children:
            if child.name in ('ul', 'ol'):
                continue
            if child.name == 'a':
                text_parts.append(f"[{child.get_text()}]({child.get('href', '')})")
            elif isinstance(child, str):
                s = html.unescape(child).strip()
                if s:
                    text_parts.append(s)
            elif child.name == 'code':
                text_parts.append(f"`{child.get_text()}`")
            else:
                s = child.get_text().strip()
                if s:
                    text_parts.append(s)
        text = ' '.join(t for t in text_parts if t).strip()
        if text:
            lines.append(f"{prefix}{marker} {text}")
        for nested in li.find_all(['ul', 'ol'], recursive=False):
            if nested.name == 'ol':
                ns = int(nested.get('start', 1))
                lines.extend(process_list(nested, indent + 1, ordered=True, start=ns))
            else:
                lines.extend(process_list(nested, indent + 1, ordered=False))
    return lines


def process_table(el):
    lines = []
    rows = el.find_all('tr', recursive=False)
    if not rows:
        tbody = el.find('tbody')
        if tbody:
            rows = tbody.find_all('tr', recursive=False)
    for i, tr in enumerate(rows):
        cells = tr.find_all(['th', 'td'], recursive=False)
        cell_texts = []
        for c in cells:
            cell_texts.append(get_inline_text(c).strip().replace('\n', ' '))
        line = "| " + " | ".join(cell_texts) + " |"
        lines.append(line)
        if i == 0:
            lines.append("| " + " | ".join(["---"] * len(cells)) + " |")
    return lines


def html_to_md(storage_html):
    soup = BeautifulSoup(storage_html, 'html.parser')
    md_lines = []

    for el in soup.children:
        if not el.name:
            continue
        tag = el.name.lower()
        if tag == 'h1':
            md_lines.append(f"\n# {el.get_text(strip=True)}\n")
        elif tag == 'h2':
            md_lines.append(f"\n## {el.get_text(strip=True)}\n")
        elif tag == 'h3':
            md_lines.append(f"\n### {el.get_text(strip=True)}\n")
        elif tag == 'h4':
            md_lines.append(f"\n#### {el.get_text(strip=True)}\n")
        elif tag == 'h5':
            md_lines.append(f"\n##### {el.get_text(strip=True)}\n")
        elif tag == 'h6':
            md_lines.append(f"\n###### {el.get_text(strip=True)}\n")
        elif tag == 'p':
            text = get_inline_text(el)
            if text.strip():
                md_lines.append(text.strip())
            md_lines.append("")
        elif tag == 'ul':
            md_lines.extend(process_list(el, ordered=False))
            md_lines.append("")
        elif tag == 'ol':
            start = int(el.get('start', 1))
            md_lines.extend(process_list(el, ordered=True, start=start))
            md_lines.append("")
        elif tag == 'table':
            md_lines.extend(process_table(el))
            md_lines.append("")
        elif tag == 'hr':
            md_lines.append("\n---\n")
        elif tag == 'br':
            continue
        elif tag == 'code':
            md_lines.append(f"```\n{el.get_text()}\n```")
        elif tag == 'blockquote':
            text = get_inline_text(el)
            for line in text.strip().split('\n'):
                md_lines.append(f"> {line}")
            md_lines.append("")
        elif tag == 'ac:structured-macro':
            macro_name = el.get('ac:name', 'unknown')
            if macro_name == 'code':
                body = el.find('ac:plain-text-body')
                if body:
                    lang_param = el.find('ac:parameter', {'ac:name': 'language'})
                    lang = lang_param.get_text() if lang_param else ''
                    md_lines.append(f"```{lang}\n{body.get_text()}\n```")
            elif macro_name in ('info', 'note', 'warning', 'tip'):
                body = el.find('ac:rich-text-body')
                if body:
                    label = macro_name.upper() if macro_name != 'tip' else 'TIP'
                    inner = html_to_md(str(body))
                    for line in inner.split('\n'):
                        if line.strip():
                            md_lines.append(f"> **{label}:** {line}" if line == inner.split('\n')[0] else f"> {line}")
            elif macro_name == 'jira':
                key_param = el.find('ac:parameter', {'ac:name': 'key'})
                if key_param:
                    key = key_param.get_text()
                    md_lines.append(f"[{key}](https://netskope.atlassian.net/browse/{key})")
            elif macro_name == 'children':
                md_lines.append("*(child pages listed in Confluence)*")
            elif macro_name == 'toc':
                md_lines.append("*(table of contents)*")
            elif macro_name == 'expand':
                body = el.find('ac:rich-text-body')
                if body:
                    md_lines.append("<details>")
                    md_lines.append(html_to_md(str(body)))
                    md_lines.append("</details>")
            else:
                body = el.find('ac:rich-text-body') or el.find('ac:plain-text-body')
                if body:
                    md_lines.append(body.get_text().strip())
            md_lines.append("")
        elif tag == 'ac:link':
            page_ref = el.find('ri:page')
            if page_ref:
                title = page_ref.get('ri:content-title', '')
                md_lines.append(f"[[{title}]]")
        else:
            text = el.get_text(strip=True)
            if text:
                md_lines.append(text)

    md = '\n'.join(md_lines)
    md = re.sub(r'\n{3,}', '\n\n', md).strip()
    return md


def main():
    if len(sys.argv) < 2:
        print("Usage: html_to_md.py <input.json> [output.md]", file=sys.stderr)
        sys.exit(1)

    input_path = sys.argv[1]
    with open(input_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    body_html = data.get('body', {}).get('storage', {}).get('value', '')
    if not body_html:
        print("No body.storage.value found in JSON", file=sys.stderr)
        sys.exit(1)

    md = html_to_md(body_html)

    if len(sys.argv) >= 3:
        with open(sys.argv[2], 'w', encoding='utf-8') as f:
            f.write(md)
        print(f"Written to {sys.argv[2]}", file=sys.stderr)
    else:
        print(md)


if __name__ == '__main__':
    main()
