---
name: dlp-oncall-tracker
description: Use when querying historical DLP oncall issues, incident trends, Jira ticket status from #dlp-oncall Slack channel, or checking tracker run health. Use when asked about DLP incidents, oncall patterns, issue categories, FP blockers, WD aborts, or plane (DP/MP) issues.
---

# DLP Oncall Tracker

SQLite database of raw Slack messages from the #dlp-oncall channel. Updated automatically at 10:00 UTC via cron (message fetch only). **Summarization is done inline by you (the agent) when answering questions.**

## DB Location

```
/root/code/tools/dlp_oncall_tracker/dlp_oncall.db
```

## Key Tables

| Table | Contents |
|---|---|
| `messages` | Raw Slack messages: ts, user_name, text, fetched_at |
| `run_log` | One row per cron run: status (success/failure), message_count, error |
| `jira_tickets` | Jira ticket details (populated by enrichment): title, status, assignee, priority |
| `confluence_pages` | Confluence page excerpts found in messages |
| `daily_digests` | Legacy: AI-generated JSON digests (no longer written by cron) |
| `issue_categories` | Legacy: categorized issues (no longer written by cron) |

## Common Queries

```bash
# Raw messages for a date
sqlite3 /root/code/tools/dlp_oncall_tracker/dlp_oncall.db \
  "SELECT ts, user_name, text FROM messages
   WHERE date(fetched_at) = '2026-03-24'
   ORDER BY ts;"

# Messages for last 24 hours
sqlite3 /root/code/tools/dlp_oncall_tracker/dlp_oncall.db \
  "SELECT ts, user_name, text FROM messages
   WHERE fetched_at >= datetime('now', '-1 day')
   ORDER BY ts DESC;"

# Messages for a date range
sqlite3 /root/code/tools/dlp_oncall_tracker/dlp_oncall.db \
  "SELECT date(fetched_at) as day, COUNT(*) as msgs
   FROM messages
   WHERE fetched_at >= datetime('now', '-7 days')
   GROUP BY day ORDER BY day DESC;"

# Run health check
sqlite3 /root/code/tools/dlp_oncall_tracker/dlp_oncall.db \
  "SELECT run_at, status, message_count, error FROM run_log ORDER BY run_at DESC LIMIT 10;"

# Jira tickets seen recently
sqlite3 /root/code/tools/dlp_oncall_tracker/dlp_oncall.db \
  "SELECT ticket_id, title, status, assignee, priority FROM jira_tickets ORDER BY fetched_at DESC;"
```

## Agent Workflow for "Today's Issues"

1. Query `messages` for today:
   ```sql
   SELECT ts, user_name, text FROM messages
   WHERE date(fetched_at) = date('now')
   ORDER BY ts;
   ```
2. If no rows → run `python3 /root/code/tools/dlp_oncall_tracker/main.py` via Bash, then re-query
3. **Read the messages and summarize inline** — categorize them yourself using the DLP Oncall Categories below. Do NOT invoke a subprocess or external tool for summarization.

## DLP Oncall Categories

When summarizing messages, classify issues into these buckets:

| Category | Description |
|---|---|
| **FP Blockers** | False positive alerts blocking customer workflows |
| **WD Aborts** | Watchdog or workflow abort events |
| **DP Issues** | Data plane (enforcement engine) problems |
| **MP Issues** | Management plane (policy/config/API) problems |
| **Scan Failures** | Content inspection or DLP scan errors |
| **Tenant Issues** | Customer-specific misconfigurations or escalations |
| **Integration Failures** | Third-party connector or API failures |
| **Other** | Everything else |

For each category found, report:
- **Severity**: critical / high / medium / low
- **Incident count**: number of distinct incidents
- **Plane**: DP, MP, both, or unknown
- **Open**: whether the issue appears resolved in the thread
- **Summary**: 1-2 sentence description
- **Jira tickets**: any `[A-Z]+-\d+` patterns mentioned

## Manual Run (Fetch Missing Days)

```bash
python3 /root/code/tools/dlp_oncall_tracker/main.py
```

Idempotent — only fetches days not yet in `run_log`. Safe to re-run.
