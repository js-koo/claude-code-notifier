#!/bin/bash
# notify.sh - OS Router for Claude Code notifications
# Hook: Stop
# Detects OS and routes to appropriate notifier

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
source "$SCRIPT_DIR/config.sh"

# Read stdin into variable (for passing to child scripts)
INPUT=$(cat)

# Export config as environment variables for child scripts
export MIN_DURATION_SECONDS
export MSG_COMPLETED
export PROMPT_PREVIEW_LENGTH

# Detect OS and route to appropriate notifier
if grep -qi microsoft /proc/version 2>/dev/null; then
    # WSL (Windows Subsystem for Linux)
    export NOTIFIER_DATA_DIR_WIN=$(wslpath -w "$HOME/.claude-code-notifier/data")

    PS1_PATH="$SCRIPT_DIR/notifiers/windows.ps1"
    PS1_PATH_WIN=$(wslpath -w "$PS1_PATH")

    echo "$INPUT" | powershell.exe -ExecutionPolicy Bypass -File "$PS1_PATH_WIN"

elif [ "$(uname)" = "Darwin" ]; then
    # macOS
    echo "$INPUT" | "$SCRIPT_DIR/notifiers/macos.sh"

else
    # Linux (native)
    echo "$INPUT" | "$SCRIPT_DIR/notifiers/linux.sh"
fi

# Always exit successfully (don't block Claude Code)
exit 0
