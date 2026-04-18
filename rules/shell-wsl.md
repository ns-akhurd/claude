**9.1 Strip CRLF** — After writing any `.sh` file while CWD on Windows-mounted fs (`/mnt/c/...`):
1. MUST run `sed -i 's/\r//' <path>`
2. MUST verify with `bash -n <path>`
NEVER skip — CRLF causes `bash: set: -: invalid option` and silent runtime failures.

**9.2 Python venv** — Python script requiring pip packages:
1. MUST use `.venv` in project dir — NEVER global `pip install`/`pip3 install`
2. MUST use `.venv/bin/pip` and `.venv/bin/python` explicitly in scripts/service files
3. MUST include in launcher: `if [ ! -d .venv ]; then python3 -m venv .venv; fi`
4. NEVER write `pip install …` or `python script.py` without `.venv/bin/` prefix