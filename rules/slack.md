**13.1 Message Order** — MUST pass `oldest`/`limit` (or equivalent) to fetch Slack messages most-recent-first. NEVER read channel without those params.

**13.2 Slack Timestamp Computation** — Computing Unix timestamp for Slack `oldest`: (1) MUST verify by back-converting: `datetime.utcfromtimestamp(ts)`. (2) NEVER pass unverified integer. (3) MUST log computed date (human-readable) before API call.
