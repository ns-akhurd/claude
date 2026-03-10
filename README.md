# Claude Code Config

Personal Claude Code configuration — behavioral directives, settings, skills, and plugins.

## What's in this repo

| File/Dir | Purpose |
|---|---|
| `CLAUDE.md` | Agent behavioral directives (mandatory rules) |
| `USER_PREFERENCES.md` | Personal preferences |
| `settings.json` | Claude Code settings — model, permissions, env vars, plugins |
| `statusline-robbyrussell.sh` | Custom status line script |
| `skills/` | Custom skill definitions |
| `plugins/` | Plugin registry and marketplace config |

## Restore on a new machine

**Prerequisites:** Claude Code installed, SSH key registered on GitHub.

```bash
# 1. Clone
git clone git@github.com:ns-akhurd/claude.git ~/.claude

# 2. Re-login to AWS SSO (Bedrock)
aws sso login --profile NSBedrockViewer-242201274356

# 3. Launch Claude Code — it will regenerate config.json and reinstall plugins automatically
claude
```

> `config.json` is excluded from this repo as it contains API keys. It is auto-generated on first launch.

## Keeping config in sync

```bash
# Push changes
cd ~/.claude
git add -A
git commit -m "update config"
git push

# Pull on another machine
cd ~/.claude && git pull
```

## What is NOT tracked

| Excluded | Reason |
|---|---|
| `config.json` | Contains API keys |
| `projects/` | Session conversation history |
| `tasks/`, `debug/`, `telemetry/` | Ephemeral session data |
| `cache/`, `file-history/` | Runtime caches |
| `history.jsonl` | Conversation history |
| `session-env/`, `shell-snapshots/` | Runtime state |
