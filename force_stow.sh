#!/usr/bin/env bash

set -euo pipefail

BACKUP_EXT=".bakfs"
DELETE_MODE=false
RESTORE_MODE=false

usage() {
    cat <<EOF
Usage:
  force_stow [options] package1 [package2 ...]
  force_stow [options] .

Options:
  -d    Delete conflicting files instead of backing them up
  -r    Reverse operation (unstow + restore backups)
  -h    Show this help

Examples:
  force_stow zsh
  force_stow zsh nvim tmux
  force_stow .
  force_stow -d zsh
  force_stow -r zsh
  force_stow -r .
EOF
}

########################################
# Parse options
########################################

while getopts ":drh" opt; do
    case "$opt" in
        d)
            DELETE_MODE=true
            ;;
        r)
            RESTORE_MODE=true
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

########################################
# Validation
########################################

if [[ "$DELETE_MODE" == true && "$RESTORE_MODE" == true ]]; then
    echo "Error: -d and -r cannot be used together."
    exit 1
fi

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

if ! command -v stow >/dev/null 2>&1; then
    echo "Error: GNU Stow is not installed."
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "Error: Git is not installed."
    exit 1
fi

if [[ ! -f ".stowrc" ]]; then
    echo "Warning: no .stowrc found in current directory."
fi

########################################
# We assume the classic setup:
#
#   ~/dotfiles/package/...files...
#
# and stow targets the parent directory.
########################################

DOTFILES_DIR="$(pwd)"
TARGET_DIR="$(realpath ..)"

########################################
# Read ignore rules from .stowrc
#
# Supports lines like:
#   --ignore='regex'
#   --ignore="regex"
#   --ignore=regex
########################################

IGNORE_PATTERNS=()

load_ignore_patterns() {
    [[ -f ".stowrc" ]] || return

    while IFS= read -r line; do
        [[ "$line" =~ --ignore= ]] || continue

        pattern="${line#*--ignore=}"

        # trim surrounding quotes
        pattern="${pattern%\"}"
        pattern="${pattern#\"}"
        pattern="${pattern%\'}"
        pattern="${pattern#\'}"

        IGNORE_PATTERNS+=("$pattern")
    done < .stowrc
}

########################################
# Check if relative path is ignored
########################################

is_ignored() {
    local rel="$1"

    for pattern in "${IGNORE_PATTERNS[@]}"; do
        if [[ "$rel" =~ $pattern ]]; then
            return 0
        fi
    done

    return 1
}

########################################
# Expand '.' into all package dirs
########################################

expand_packages() {
    local input=("$@")
    local output=()

    if [[ " ${input[*]} " == *" . "* ]]; then
        while IFS= read -r dir; do
            output+=("$dir")
        done < <(
            find . \
                -mindepth 1 \
                -maxdepth 1 \
                -type d \
                ! -name '.git' \
                ! -name '.stow-cache' \
                -printf '%f\n' \
                | sort
        )
    else
        output=("${input[@]}")
    fi

    printf '%s\n' "${output[@]}"
}

########################################
# Find all real files in a package
# respecting ignore rules.
########################################

package_files() {
    local pkg="$1"

    find "$pkg" -type f | while IFS= read -r file; do
        rel="${file#${pkg}/}"

        if is_ignored "$rel"; then
            continue
        fi

        printf '%s\n' "$rel"
    done
}

########################################
# Backup or delete conflicts
########################################

process_package_apply() {
    local pkg="$1"

    echo
    echo "=== Processing package: $pkg ==="

    if [[ ! -d "$pkg" ]]; then
        echo "Warning: package '$pkg' does not exist. Skipping."
        return
    fi

    while IFS= read -r relpath; do
        src="$DOTFILES_DIR/$pkg/$relpath"
        dst="$TARGET_DIR/$relpath"

        [[ -f "$src" ]] || continue

        if [[ -e "$dst" && ! -L "$dst" ]]; then
            if [[ "$DELETE_MODE" == true ]]; then
                echo "Deleting: $dst"
                rm -f "$dst"
            else
                backup="$dst$BACKUP_EXT"

                if [[ -e "$backup" ]]; then
                    echo "Backup already exists, skipping: $backup"
                    continue
                fi

                echo "Backing up: $dst -> $backup"
                mv "$dst" "$backup"
            fi
        fi
    done < <(package_files "$pkg")
}

########################################
# Restore backups
########################################

process_package_restore() {
    local pkg="$1"

    echo
    echo "=== Restoring package: $pkg ==="

    if [[ ! -d "$pkg" ]]; then
        echo "Warning: package '$pkg' does not exist. Skipping."
        return
    fi

    while IFS= read -r relpath; do
        dst="$TARGET_DIR/$relpath"
        backup="$dst$BACKUP_EXT"

        if [[ -e "$backup" ]]; then
            echo "Restoring: $backup -> $dst"
            mv "$backup" "$dst"
        fi
    done < <(package_files "$pkg")
}

########################################
# Main
########################################

load_ignore_patterns

mapfile -t PACKAGES < <(expand_packages "$@")

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    echo "No packages found."
    exit 1
fi

########################################
# Reverse mode
########################################

if [[ "$RESTORE_MODE" == true ]]; then
    echo
    echo "=== Removing stow symlinks ==="

    stow -D "${PACKAGES[@]}"

    for pkg in "${PACKAGES[@]}"; do
        process_package_restore "$pkg"
    done

    echo
    echo "Done."
    exit 0
fi

########################################
# Normal mode
########################################

for pkg in "${PACKAGES[@]}"; do
    process_package_apply "$pkg"
done

echo
echo "=== Running stow ==="
stow "${PACKAGES[@]}"

echo
echo "Done."
