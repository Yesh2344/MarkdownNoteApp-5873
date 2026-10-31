#!/usr/bin/env bash
# main.sh – Entry point for MarkdownNoteApp

set -euo pipefail

# Load configuration and utilities
source "./config.sh"
source "./logger.sh"
source "./utils.sh"
source "./notes.sh"

# Global help message
print_help() {
    cat <<'EOF'
MarkdownNoteApp – Simple markdown note‑taking utility

Usage:
  ./main.sh <command> [arguments]

Commands:
  create <title>               Create a new note with the given title
  list                         List all existing notes
  view <title>                 View a note in the terminal
  export <title> [output.html] Export a note to HTML (pandoc required)
  delete <title>               Delete a note (asks for confirmation)
  help                         Show this help message

Examples:
  ./main.sh create "Meeting Notes"
  ./main.sh list
  ./main.sh view "Meeting Notes"
  ./main.sh export "Meeting Notes" meeting.html
  ./main.sh delete "Old Note"
EOF
}

# Ensure at least one argument
if (( $# == 0 )); then
    print_help
    exit 1
fi

# Parse command
command=$1
shift || true

case "$command" in
    create)
        if (( $# != 1 )); then
            echo "Error: 'create' requires exactly one argument (title)." >&2
            exit 1
        fi
        create_note "$1"
        ;;
    list)
        list_notes
        ;;
    view)
        if (( $# != 1 )); then
            echo "Error: 'view' requires exactly one argument (title)." >&2
            exit 1
        fi
        view_note "$1"
        ;;
    export)
        if (( $# < 1 || $# > 2 )); then
            echo "Error: 'export' requires a title and optional output file." >&2
            exit 1
        fi
        export_note "$1" "${2:-}"
        ;;
    delete)
        if (( $# != 1 )); then
            echo "Error: 'delete' requires exactly one argument (title)." >&2
            exit 1
        fi
        delete_note "$1"
        ;;
    help|-h|--help)
        print_help
        ;;
    *)
        echo "Error: Unknown command '$command'." >&2
        print_help
        exit 1
        ;;
esac