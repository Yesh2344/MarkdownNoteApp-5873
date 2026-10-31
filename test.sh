#!/usr/bin/env bash
# test.sh – Minimal test suite for MarkdownNoteApp

set -euo pipefail

# Load the same configuration as the app (but use a temp dir)
TEST_NOTE_DIR=$(mktemp -d)
export NOTE_DIR="$TEST_NOTE_DIR"
export LOG_FILE="${NOTE_DIR}/app.log"
export DEFAULT_EDITOR="true"   # 'true' exits immediately, creating an empty file

# Source the library files
source "./config.sh"
source "./logger.sh"
source "./utils.sh"
source "./notes.sh"

# Helper: assert that a command succeeds
assert_success() {
    if ! "$@"; then
        echo "FAIL: Expected success: $*" >&2
        exit 1
    fi
}

# Helper: assert that a command fails
assert_failure() {
    if "$@"; then
        echo "FAIL: Expected failure: $*" >&2
        exit 1
    fi
}

# 1. Create a note
NOTE_TITLE="TestNote"
assert_success create_note "$NOTE_TITLE"

# 2. List should contain the note
output=$(list_notes)
if ! grep -q "Testnote" <<<"$output"; then
    echo "FAIL: 'list_notes' did not show created note." >&2
    exit 1
fi

# 3. View (just ensure it exits successfully)
assert_success view_note "$NOTE_TITLE" <<< $'q'   # send 'q' to less

# 4. Export to HTML
HTML_OUTPUT="${NOTE_DIR}/testnote.html"
assert_success export_note "$NOTE_TITLE" "$HTML_OUTPUT"
if [[ ! -s "$HTML_OUTPUT" ]]; then
    echo "FAIL: Exported HTML file is empty." >&2
    exit 1
fi

# 5. Delete the note (auto‑confirm)
export DEFAULT_EDITOR="true"
confirm() { return 0; }   # mock confirm to always say yes
assert_success delete_note "$NOTE_TITLE"
if [[ -e "${NOTE_DIR}/testnote.md" ]]; then
    echo "FAIL: Note file still exists after deletion." >&2
    exit 1
fi

echo "All tests passed."