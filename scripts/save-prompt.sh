#!/bin/bash
# save-prompt.sh - Saves user prompt and timestamp for notifications
# Hook: UserPromptSubmit

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$HOME/.claude-code-notifier/data"

# Load config
source "$SCRIPT_DIR/config.sh"

# Ensure data directory exists
mkdir -p "$DATA_DIR"

# Read stdin (JSON from Claude Code)
INPUT=$(cat)

# Extract session_id and prompt from JSON
if command -v jq &> /dev/null; then
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
    PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)
else
    # Fallback: basic extraction with grep/sed
    SESSION_ID=$(echo "$INPUT" | grep -o '"session_id":"[^"]*"' | sed 's/"session_id":"\(.*\)"/\1/' | head -1)
    PROMPT=$(echo "$INPUT" | grep -o '"prompt":"[^"]*"' | sed 's/"prompt":"\(.*\)"/\1/' | head -1)
fi

# Default session ID if empty
if [ -z "$SESSION_ID" ]; then
    SESSION_ID="default"
fi

# Exit silently if no prompt
if [ -z "$PROMPT" ]; then
    exit 0
fi

# Format prompt preview
LENGTH=${#PROMPT}
if [ $LENGTH -le $PROMPT_PREVIEW_LENGTH ]; then
    FORMATTED_PROMPT="$PROMPT"
else
    FORMATTED_PROMPT="${PROMPT:0:$PROMPT_PREVIEW_LENGTH}..."
fi

# Save prompt and timestamp
TIMESTAMP=$(date +%s)
echo "$FORMATTED_PROMPT" > "$DATA_DIR/prompt-${SESSION_ID}.txt"
echo "$TIMESTAMP" > "$DATA_DIR/timestamp-${SESSION_ID}.txt"

exit 0
