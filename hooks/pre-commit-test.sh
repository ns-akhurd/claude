#!/bin/bash
# Hook: run CI engine tests before any git commit.
# If tests are not yet built or binary is missing, skip (first commit).
cmd=$(python3 -c "import json,os; print(json.loads(os.environ.get('CLAUDE_TOOL_INPUT','{}')).get('command',''))" 2>/dev/null)

# Only act on git commit commands
echo "$cmd" | grep -q "git commit" || exit 0

TEST_BIN="/root/code/dataplane/obj/dlp_ciengine_test"
if [ ! -x "$TEST_BIN" ]; then
    echo "WARNING: $TEST_BIN not found — skipping pre-commit test gate" >&2
    exit 0
fi

echo "Running pre-commit tests..."
"$TEST_BIN" >/tmp/pre_commit_test_out.txt 2>&1
rc=$?

if [ $rc -ne 0 ]; then
    echo "BLOCKED: tests failed — commit not allowed until tests pass." >&2
    echo "--- Last 30 lines of test output ---" >&2
    tail -30 /tmp/pre_commit_test_out.txt >&2
    exit 1
fi

passed=$(grep -oP '\d+ test[s]? passed' /tmp/pre_commit_test_out.txt | tail -1)
echo "Pre-commit gate: PASSED ($passed) — commit allowed."
exit 0
