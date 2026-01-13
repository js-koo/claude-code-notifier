#!/bin/bash
# cleanup-session.sh - Cleans up session files when Claude Code session ends
# Hook: SessionEnd

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Read stdin (JSON from Claude Code)
INPUT=$(cat)

SESSION_ID=$(json_get "$INPUT" "session_id")

# Clean up session files if session_id exists
if [ -n "$SESSION_ID" ]; then
    rm -f "$DATA_DIR/prompt-${SESSION_ID}.txt"
    rm -f "$DATA_DIR/timestamp-${SESSION_ID}.txt"
fi

exit 0
