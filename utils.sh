#!/usr/bin/env bash
# utils.sh – Helper functions used across the project

set -euo pipefail

# Ensure required external commands are available
check_dependencies() {
    local missing=()
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done

    if (( ${#missing[@]} )); then
        log_error "Missing dependencies: ${missing[*]}"
        echo "Error: The following commands are required but not installed: ${missing[*]}" >&2
        exit 1
    fi
}

# Convert a note title to a safe filename (lowercase, alnum, dashes)
sanitize_title() {
    local title=$1
    # Replace spaces with dashes, remove non‑alnum characters, lowercase
    echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-'
}

# Prompt the user for a Yes/No answer; returns 0 for Yes
confirm() {
    local prompt=$1
    read -r -p "$prompt [y/N]: " answer
    case "${answer,,}" in
        y|yes) return 0 ;;
        *)     return 1 ;;
    esac
}