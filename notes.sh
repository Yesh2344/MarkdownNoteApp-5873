#!/usr/bin/env bash
# notes.sh – Core note‑taking functionality

set -euo pipefail

# Source shared modules
source "./config.sh"
source "./logger.sh"
source "./utils.sh"

# Ensure NOTE_DIR exists
mkdir -p "$NOTE_DIR"

# Create a new markdown note
create_note() {
    local title=$1
    local filename
    filename="$(sanitize_title "$title").md"
    local filepath="${NOTE_DIR}/${filename}"

    if [[ -e "$filepath" ]]; then
        log_error "Note '$title' already exists."
        echo "Error: Note with title '$title' already exists." >&2
        return 1
    fi

    log_info "Creating note: $title"
    "${DEFAULT_EDITOR}" "$filepath"
    if [[ -s "$filepath" ]]; then
        log_info "Note created successfully: $filepath"
        echo "Note '$title' created."
    else
        rm -f "$filepath"
        log_error "Empty note discarded."
        echo "Note creation aborted (empty file)." >&2
        return 1
    fi
}

# List all notes with modification date
list_notes() {
    log_info "Listing notes in $NOTE_DIR"
    if [[ ! -d "$NOTE_DIR" ]] || [[ -z "$(ls -A "$NOTE_DIR"/*.md 2>/dev/null)" ]]; then
        echo "No notes found."
        return 0
    fi

    printf "%-20s %-40s\n" "Date Modified" "Title"
    printf "%-20s %-40s\n" "-------------" "-----"
    while IFS= read -r -d '' file; do
        local mod_date
        mod_date=$(date -r "$file" '+%Y-%m-%d %H:%M')
        local base
        base=$(basename "$file" .md)
        # Reverse sanitization for display: replace dashes with spaces and capitalize
        local display_title
        display_title=$(echo "$base" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
        printf "%-20s %-40s\n" "$mod_date" "$display_title"
    done < <(find "$NOTE_DIR" -maxdepth 1 -type f -name "*.md" -print0 | sort -z)
}

# View a note using less
view_note() {
    local title=$1
    local filename
    filename="$(sanitize_title "$title").md"
    local filepath="${NOTE_DIR}/${filename}"

    if [[ ! -f "$filepath" ]]; then
        log_error "Note not found: $title"
        echo "Error: Note '$title' does not exist." >&2
        return 1
    fi

    log_info "Viewing note: $title"
    less "$filepath"
}

# Export a note to HTML via pandoc
export_note() {
    local title=$1
    local output=${2:-}
    local filename
    filename="$(sanitize_title "$title").md"
    local filepath="${NOTE_DIR}/${filename}"

    if [[ ! -f "$filepath" ]]; then
        log_error "Note not found for export: $title"
        echo "Error: Note '$title' does not exist." >&2
        return 1
    fi

    check_dependencies pandoc

    if [[ -z "$output" ]]; then
        output="${NOTE_DIR}/$(sanitize_title "$title").html"
    fi

    log_info "Exporting '$title' to HTML: $output"
    if pandoc "$filepath" -f markdown -t html -s -o "$output"; then
        log_info "Export successful."
        echo "Exported to $output"
    else
        log_error "Pandoc failed to export $title"
        echo "Error: Failed to export note." >&2
        return 1
    fi
}

# Delete a note after confirmation
delete_note() {
    local title=$1
    local filename
    filename="$(sanitize_title "$title").md"
    local filepath="${NOTE_DIR}/${filename}"

    if [[ ! -f "$filepath" ]]; then
        log_error "Attempted to delete non‑existent note: $title"
        echo "Error: Note '$title' does not exist." >&2
        return 1
    fi

    if confirm "Are you sure you want to delete '$title'?"; then
        rm -f "$filepath"
        log_info "Deleted note: $title"
        echo "Note '$title' deleted."
    else
        log_info "Deletion aborted for note: $title"
        echo "Deletion cancelled."
    fi
}