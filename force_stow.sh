#!/usr/bin/env bash

set -eo pipefail
set -u

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
EOF
}

while getopts ":drh" opt; do
    case "$opt" in
        d) DELETE_MODE=true ;;
        r) RESTORE_MODE=true ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

if [[ "$DELETE_MODE" == true && "$RESTORE_MODE" == true ]]; then
    echo "Error: -d and -r cannot be used together."
    exit 1
fi

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

command -v stow >/dev/null 2>&1 || {
    echo "Error: GNU Stow is not installed."
    exit 1
}

command -v git >/dev/null 2>&1 || {
    echo "Error: Git is not installed."
    exit 1
}

[[ -f ".stowrc" ]] || echo "Warning: no .stowrc found in current directory."

DOTFILES_DIR="$(pwd -P)"
TARGET_DIR="$(cd .. && pwd -P)"

IGNORE_PATTERNS=()

load_ignore_patterns() {
    [[ -f ".stowrc" ]] || return 0

    local line pattern

    while IFS= read -r line; do
        [[ "$line" =~ --ignore= ]] || continue

        pattern="${line#*--ignore=}"

        pattern="${pattern%\"}"
        pattern="${pattern#\"}"
        pattern="${pattern%\'}"
        pattern="${pattern#\'}"

        IGNORE_PATTERNS+=("$pattern")
    done < .stowrc
}

is_ignored() {
    local rel="$1"
    local pattern

    for pattern in "${IGNORE_PATTERNS[@]:-}"; do
        if [[ "$rel" =~ $pattern ]]; then
            return 0
        fi
    done

    return 1
}

expand_packages() {
    local input=("$@")
    local dir

    if [[ " ${input[*]} " == *" . "* ]]; then
        find . \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            ! -name '.git' \
            ! -name '.stow-cache' \
            -exec basename {} \; \
            | sort
    else
        printf '%s\n' "$@"
    fi
}

package_files() {
    local pkg="$1"
    local file rel

    find "$pkg" -type f | while IFS= read -r file; do
        rel="${file#${pkg}/}"

        if is_ignored "$rel"; then
            continue
        fi

        printf '%s\n' "$rel"
    done
}

process_package_apply() {
    local pkg="$1"
    local relpath src dst backup

    echo
    echo "=== Processing package: $pkg ==="

    if [[ ! -d "$pkg" ]]; then
        echo "Warning: package '$pkg' does not exist. Skipping."
        return 0
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

process_package_restore() {
    local pkg="$1"
    local relpath dst backup

    echo
    echo "=== Restoring package: $pkg ==="

    if [[ ! -d "$pkg" ]]; then
        echo "Warning: package '$pkg' does not exist. Skipping."
        return 0
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

load_ignore_patterns

PACKAGES=()
while IFS= read -r pkg; do
    [[ -n "$pkg" ]] && PACKAGES+=("$pkg")
done < <(expand_packages "$@")

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    echo "No packages found."
    exit 1
fi

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

for pkg in "${PACKAGES[@]}"; do
    process_package_apply "$pkg"
done

echo
echo "=== Running stow ==="
stow "${PACKAGES[@]}"

echo
echo "Done."
