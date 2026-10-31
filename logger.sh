#!/usr/bin/env bash
# logger.sh – Simple logging utilities

set -euo pipefail

# Ensure the log directory exists
mkdir -p "$(dirname "${LOG_FILE:-/tmp/app.log}")"

# Log levels
LOG_LEVEL_INFO="INFO"
LOG_LEVEL_ERROR="ERROR"
LOG_LEVEL_DEBUG="DEBUG"

# Write a log entry with timestamp and level
_log() {
    local level=$1
    shift
    local message=$*
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    printf '[%s] [%s] %s\n' "$timestamp" "$level" "$message" >> "${LOG_FILE:-/tmp/app.log}"
}

log_info()   { _log "$LOG_LEVEL_INFO" "$@"; }
log_error()  { _log "$LOG_LEVEL_ERROR" "$@"; }
log_debug()  { _log "$LOG_LEVEL_DEBUG" "$@"; }