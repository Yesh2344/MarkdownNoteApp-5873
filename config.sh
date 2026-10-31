#!/usr/bin/env bash
# config.sh – Load environment configuration with defaults

set -euo pipefail

# Load .env if present; otherwise fall back to defaults
if [[ -f ".env" ]]; then
    # shellcheck disable=SC1091
    source ".env"
fi

# Set defaults if variables are still empty
: "${NOTE_DIR:=$HOME/.markdown_notes}"
: "${LOG_FILE:=$NOTE_DIR/app.log}"
: "${DEFAULT_EDITOR:=nano}"
# tiny readability tweak

# Export for subshells
export NOTE_DIR LOG_FILE DEFAULT_EDITOR