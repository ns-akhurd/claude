#!/usr/bin/env python3
"""PreToolUse hook: block `git commit` whose message lacks a ticket ID.

Allow cases:
  - not a git commit command
  - NO_TICKET=1 env var set (explicit user bypass)
  - message supplied via -F - (stdin) or editor (no -m/-F): can't inspect
  - message contains a token matching [A-Z]{2,}-[0-9]+

Deny otherwise, telling Claude to add a ticket ID prefix or use the
commit-with-ticket skill.
"""
import json
import os
import re
import shlex
import sys

TICKET_RE = re.compile(r"[A-Z]{2,}-[0-9]+")


def allow():
    sys.exit(0)


def deny(reason):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }))
    sys.exit(0)


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        allow()
    cmd = (data.get("tool_input") or {}).get("command", "")
    if not cmd:
        allow()
    try:
        tokens = shlex.split(cmd)
    except ValueError:
        tokens = cmd.split()
    if "git" not in tokens or "commit" not in tokens:
        allow()
    if os.environ.get("NO_TICKET") == "1":
        allow()

    msg_parts = []
    saw_minus_f_stdin = False
    i = 0
    while i < len(tokens):
        t = tokens[i]
        if t == "-m" and i + 1 < len(tokens):
            msg_parts.append(tokens[i + 1]); i += 2; continue
        if t.startswith("-m") and len(t) > 2 and not t.startswith("--"):
            msg_parts.append(t[2:]); i += 1; continue
        if t == "-F" and i + 1 < len(tokens):
            fp = tokens[i + 1]
            if fp == "-":
                saw_minus_f_stdin = True
            else:
                try:
                    with open(fp) as f:
                        msg_parts.append(f.read())
                except OSError:
                    pass
            i += 2; continue
        if t.startswith("-F") and len(t) > 2 and not t.startswith("--"):
            fp = t[2:]
            if fp == "-":
                saw_minus_f_stdin = True
            else:
                try:
                    with open(fp) as f:
                        msg_parts.append(f.read())
                except OSError:
                    pass
            i += 1; continue
        i += 1

    if not msg_parts:
        # editor / -F - / unknown: can't inspect -> don't block
        allow()
    msg = "\n\n".join(msg_parts)
    if TICKET_RE.search(msg):
        allow()
    deny(
        "Commit message has no ticket ID (expected pattern [A-Z]+-[0-9]+, e.g. "
        "'ENG-XXXXXX: <imperative subject>'). Prefix the subject with the ticket "
        "or invoke the commit-with-ticket skill. To bypass for a deliberate "
        "no-ticket commit, set NO_TICKET=1."
    )


if __name__ == "__main__":
    main()
