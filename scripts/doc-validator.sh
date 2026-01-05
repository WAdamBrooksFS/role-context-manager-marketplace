#!/usr/bin/env bash

# doc-validator.sh - Validate document existence and resolve paths
#
# Functions:
#   - resolve_path: Resolve document path (relative or absolute)
#   - check_document_exists: Check if document exists
#   - validate_documents: Validate list of documents
#
# Exit codes:
#   0 - Success
#   1 - Validation failed
#   2 - Error occurred

set -euo pipefail

# Find repository root (look for .git directory)
find_repo_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo "$PWD"
    return 1
}

# Find nearest .claude directory
find_claude_dir() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.claude" ]]; then
            echo "$dir/.claude"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo ""
    return 1
}

# Resolve document path
# Usage: resolve_path <path>
# Returns: Absolute path to document or empty if not found
resolve_path() {
    local doc_path="$1"
    local repo_root
    repo_root="$(find_repo_root)" || repo_root="$PWD"

    # Handle absolute paths (starting with /)
    if [[ "$doc_path" =~ ^/ ]]; then
        # Absolute path from repo root
        local abs_path="${repo_root}${doc_path}"
        if [[ -f "$abs_path" ]]; then
            echo "$abs_path"
            return 0
        fi
    else
        # Relative path - search upward from current directory
        local dir="$PWD"
        while [[ "$dir" != "/" ]]; do
            local candidate="$dir/$doc_path"
            if [[ -f "$candidate" ]]; then
                echo "$candidate"
                return 0
            fi
            dir="$(dirname "$dir")"

            # Stop at repo root if we found it
            if [[ -d "$dir/.git" ]]; then
                break
            fi
        done
    fi

    # Not found
    echo ""
    return 1
}

# Check if document exists
# Usage: check_document_exists <path>
# Returns: 0 if exists, 1 if not
check_document_exists() {
    local doc_path="$1"
    local resolved_path
    resolved_path="$(resolve_path "$doc_path")"

    if [[ -n "$resolved_path" ]]; then
        return 0
    else
        return 1
    fi
}

# Get status indicator for document
# Usage: get_status_indicator <path>
# Returns: ✓ (exists), ! (missing), ? (generate)
get_status_indicator() {
    local doc_path="$1"
    local is_standardized="${2:-false}"

    if check_document_exists "$doc_path"; then
        echo "✓"
    elif [[ "$is_standardized" == "true" ]]; then
        echo "?"
    else
        echo "!"
    fi
}

# Validate list of documents
# Usage: validate_documents <file_containing_paths>
# Format of input file: one path per line
# Output: JSON array with validation results
validate_documents() {
    local input_file="$1"
    local results="["
    local first=true

    while IFS= read -r doc_path; do
        # Skip empty lines and comments
        [[ -z "$doc_path" ]] && continue
        [[ "$doc_path" =~ ^# ]] && continue

        local resolved_path
        resolved_path="$(resolve_path "$doc_path")"

        local exists="false"
        if [[ -n "$resolved_path" ]]; then
            exists="true"
        fi

        if [[ "$first" == "true" ]]; then
            first=false
        else
            results+=","
        fi

        if command -v jq &> /dev/null; then
            results+="$(jq -n \
                --arg path "$doc_path" \
                --arg resolved "$resolved_path" \
                --arg exists "$exists" \
                '{path: $path, resolved: $resolved, exists: ($exists == "true")}')"
        else
            # Fallback without jq
            results+="{\"path\":\"$doc_path\",\"resolved\":\"$resolved_path\",\"exists\":$exists}"
        fi
    done < "$input_file"

    results+="]"
    echo "$results"
}

# Print formatted validation results
# Usage: print_validation_results <path> <exists> [is_standardized]
print_validation_results() {
    local doc_path="$1"
    local exists="$2"
    local is_standardized="${3:-false}"

    local indicator
    if [[ "$exists" == "true" ]]; then
        indicator="✓"
    elif [[ "$is_standardized" == "true" ]]; then
        indicator="?"
    else
        indicator="!"
    fi

    echo "  $indicator $doc_path"
}

# Check if document is standardized (would have a template)
is_standardized_document() {
    local doc_path="$1"
    local filename="$(basename "$doc_path")"

    # List of standardized document names
    case "$filename" in
        engineering-standards.md|\
        quality-standards.md|\
        security-policy.md|\
        contributing.md|\
        development-setup.md|\
        readme.md|README.md|\
        architecture-decision-record-*.md|\
        product-requirements-document-*.md|\
        technical-design-document.md|\
        api-documentation.md|\
        operational-runbook.md|\
        test-plan-*.md)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Main function for standalone usage
main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <document-path>" >&2
        echo "   or: $0 --validate-file <file-containing-paths>" >&2
        exit 2
    fi

    if [[ "$1" == "--validate-file" ]]; then
        if [[ $# -ne 2 ]]; then
            echo "Error: --validate-file requires a file path" >&2
            exit 2
        fi
        validate_documents "$2"
    else
        local doc_path="$1"
        local resolved_path
        resolved_path="$(resolve_path "$doc_path")"

        if [[ -n "$resolved_path" ]]; then
            echo "✓ Document exists: $resolved_path"
            exit 0
        else
            local is_std=""
            if is_standardized_document "$doc_path"; then
                is_std=" (can be generated from template)"
            fi
            echo "! Document not found: $doc_path$is_std" >&2
            exit 1
        fi
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
