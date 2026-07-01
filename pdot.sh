#!/usr/bin/env bash

set -eo pipefail
set -u

# -----------------------------
# Config
# -----------------------------

BACKUP_EXT=".bakpdot"
IGNORE_FILE=".pdotignore"

DELETE_MODE=false
RESTORE_MODE=false
AUTO_YES=false

DOTFILES_DIR="$(pwd -P)"
TARGET_DIR="$(cd .. && pwd -P)"

# List of what .pdotignore wants us to ignore
IGNORE_PATTERNS=()

# List of packages
PACKAGES=()

# -----------------------------
# Utilities
# -----------------------------

usage() {
    cat <<EOF
Usage:
  pdot [options] package1 [package2 ...]
  pdot [options]

Options:
  -d    Delete conflicting files/directories instead of backing them up
  -r    Reverse operation: remove links, restore backups, remove empty dirs
  -y    Auto-confirm
  -h    Show this help
EOF
}

ask_yes_no() {
    local prompt="$1"
    local answer

    printf '\n%s [y/N]: ' "$prompt" > /dev/tty
    read -r answer < /dev/tty

    case "$answer" in
        y|Y|yes|YES) return 0 ;;
        *) return 1 ;;
    esac
}

confirm_action() {
    echo

    if [[ "$RESTORE_MODE" == true ]]; then
        echo "Restore packages:"
    else
        echo "Force link packages:"
    fi

    printf '  - %s\n' "${PACKAGES[@]}"

    echo

    if [[ "$RESTORE_MODE" == true ]]; then
        echo "Package file symlinks will be removed."
        echo "Backups ending with '$BACKUP_EXT' will be restored."
        echo "Empty directories from the package structure will be removed."
    elif [[ "$DELETE_MODE" == true ]]; then
        echo "WARNING: existing conflicting files/directories will be deleted."
    else
        echo "Existing conflicting files/directories will be backed up with '$BACKUP_EXT'."
    fi

    if [[ "$AUTO_YES" == true ]]; then
        echo "Auto-confirmed (-y)."
        return 0
    fi

    ask_yes_no "Continue?"
}

# Load ignore patterns from .pdotignore.
#
# Example .pdotignore:
#   --ignore='^\.DS_Store$'
#   --ignore='(^|/)\.git(/|$)'
#   --ignore='^\.pdotignore$'
#   --ignore='^pdot(\.sh)?$'
#   --ignore='^README\.md$'
load_ignore_patterns() {
    [[ -f "$IGNORE_FILE" ]] || return 0

    local line pattern

    while IFS= read -r line; do
        [[ "$line" =~ --ignore= ]] || continue

        pattern="${line#*--ignore=}"

        pattern="${pattern%\"}"
        pattern="${pattern#\"}"
        pattern="${pattern%\'}"
        pattern="${pattern#\'}"

        IGNORE_PATTERNS+=("$pattern")
    done < "$IGNORE_FILE"
}

# Check if a relative path should be ignored.
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

# List selected packages.
# If no package is given, use all first-level directories.
expand_packages() {
    if (($# == 0)); then
        find . \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            -exec basename {} \; \
            | sort \
            | while IFS= read -r pkg; do
                if is_ignored "$pkg" || is_ignored "$pkg/"; then
                    continue
                fi

                printf '%s\n' "$pkg"
            done
    else
        local pkg

        for pkg in "$@"; do
            pkg="${pkg%/}"

            if is_ignored "$pkg" || is_ignored "$pkg/"; then
                echo "Warning: package '$pkg' is ignored. Skipping." >&2
                continue
            fi

            printf '%s\n' "$pkg"
        done
    fi
}

# List all files for a package.
# The package directory itself is only used for organization.
#
# Example:
#   nvim/.config/nvim/init.lua
#
# becomes:
#   .config/nvim/init.lua
package_files() {
    local pkg="$1"
    local file rel full_rel

    find "$pkg" -type f | while IFS= read -r file; do
        rel="${file#${pkg}/}"
        full_rel="$pkg/$rel"

        if is_ignored "$rel" || is_ignored "$full_rel"; then
            continue
        fi

        printf '%s\n' "$rel"
    done
}

# List parent directories needed by a package, deepest first.
#
# Example:
#   .config/nvim/init.lua
#
# gives:
#   .config/nvim
#   .config
package_dirs_deepest_first() {
    local pkg="$1"
    local rel dir

    package_files "$pkg" | while IFS= read -r rel; do
        dir="$(dirname "$rel")"

        while [[ "$dir" != "." && "$dir" != "/" ]]; do
            if ! is_ignored "$dir" && ! is_ignored "$pkg/$dir"; then
                printf '%s\n' "$dir"
            fi

            dir="$(dirname "$dir")"
        done
    done | awk '!seen[$0]++' | awk '{ print length, $0 }' | sort -rn | cut -d' ' -f2-
}

# List parent directories needed by a package, shallowest first.
package_dirs_shallowest_first() {
    local pkg="$1"

    package_dirs_deepest_first "$pkg" | awk '{ print length, $0 }' | sort -n | cut -d' ' -f2-
}

# Backup or delete an existing conflicting path.
handle_conflicting_path() {
    local path="$1"
    local backup

    if [[ "$DELETE_MODE" == true ]]; then
        echo "Deleting conflicting path: $path"
        rm -rf "$path"
    else
        backup="$path$BACKUP_EXT"

        if [[ -e "$backup" || -L "$backup" ]]; then
            echo "Backup already exists, cannot replace: $backup"
            return 1
        fi

        echo "Backing up conflicting path: $path -> $backup"
        mv "$path" "$backup"
    fi
}

# Make sure all parent directories exist as real directories.
ensure_parent_dirs() {
    local relpath="$1"
    local dir current part
    local parts

    dir="$(dirname "$relpath")"

    [[ "$dir" == "." ]] && return 0

    current="$TARGET_DIR"

    IFS='/' read -ra parts <<< "$dir"

    for part in "${parts[@]}"; do
        [[ -z "$part" ]] && continue

        current="$current/$part"

        if [[ -d "$current" && ! -L "$current" ]]; then
            continue
        fi

        if [[ -e "$current" || -L "$current" ]]; then
            handle_conflicting_path "$current"
        fi

        echo "Creating directory: $current"
        mkdir "$current"
    done
}

# Backup or delete an existing destination file if needed.
# Returns 1 when no new link should be created.
handle_existing_destination() {
    local src="$1"
    local dst="$2"
    local link_target

    if [[ -L "$dst" ]]; then
        link_target="$(readlink "$dst")"

        if [[ "$link_target" == "$src" ]]; then
            echo "Already linked: $dst"
            return 1
        fi

        handle_conflicting_path "$dst"
        return 0
    fi

    if [[ -e "$dst" ]]; then
        handle_conflicting_path "$dst"
    fi

    return 0
}

# Process a package:
# create real directories and symlink only files.
process_package_apply() {
    local pkg="$1"
    local relpath src dst

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

        ensure_parent_dirs "$relpath"

        if ! handle_existing_destination "$src" "$dst"; then
            continue
        fi

        echo "Linking: $dst -> $src"
        ln -s "$src" "$dst"
    done < <(package_files "$pkg")
}

# Process a package in reverse:
# remove package symlinks and restore file backups.
process_package_restore_files() {
    local pkg="$1"
    local relpath src dst backup link_target

    echo
    echo "=== Restoring files for package: $pkg ==="

    if [[ ! -d "$pkg" ]]; then
        echo "Warning: package '$pkg' does not exist. Skipping."
        return 0
    fi

    while IFS= read -r relpath; do
        src="$DOTFILES_DIR/$pkg/$relpath"
        dst="$TARGET_DIR/$relpath"
        backup="$dst$BACKUP_EXT"

        if [[ -L "$dst" ]]; then
            link_target="$(readlink "$dst")"

            if [[ "$link_target" == "$src" ]]; then
                echo "Removing link: $dst"
                rm -f "$dst"
            fi
        fi

        if [[ -e "$backup" || -L "$backup" ]]; then
            echo "Restoring file backup: $backup -> $dst"
            mv "$backup" "$dst"
        fi
    done < <(package_files "$pkg")
}

# Remove empty directories from the package structure.
# Only empty directories are removed.
cleanup_empty_dirs() {
    local pkg="$1"
    local rel_dir dst_dir

    echo
    echo "=== Removing empty directories for package: $pkg ==="

    if [[ ! -d "$pkg" ]]; then
        echo "Warning: package '$pkg' does not exist. Skipping."
        return 0
    fi

    while IFS= read -r rel_dir; do
        dst_dir="$TARGET_DIR/$rel_dir"

        if [[ -d "$dst_dir" && ! -L "$dst_dir" ]]; then
            echo "Trying to remove empty directory: $dst_dir"
            rmdir "$dst_dir" 2>/dev/null || true
        fi
    done < <(package_dirs_deepest_first "$pkg")
}

# Restore directory backups.
# This runs after empty directories have been removed.
restore_directory_backups() {
    local pkg="$1"
    local rel_dir dst_dir backup

    echo
    echo "=== Restoring directory backups for package: $pkg ==="

    if [[ ! -d "$pkg" ]]; then
        echo "Warning: package '$pkg' does not exist. Skipping."
        return 0
    fi

    while IFS= read -r rel_dir; do
        dst_dir="$TARGET_DIR/$rel_dir"
        backup="$dst_dir$BACKUP_EXT"

        if [[ -e "$backup" || -L "$backup" ]]; then
            if [[ -e "$dst_dir" || -L "$dst_dir" ]]; then
                echo "Cannot restore directory backup, path still exists: $dst_dir"
                continue
            fi

            echo "Restoring directory backup: $backup -> $dst_dir"
            mv "$backup" "$dst_dir"
        fi
    done < <(package_dirs_shallowest_first "$pkg")
}

# -----------------------------
# Options, arguments and dependencies
# -----------------------------

while getopts ":dryh" opt; do
    case "$opt" in
        d) DELETE_MODE=true ;;
        r) RESTORE_MODE=true ;;
        y) AUTO_YES=true ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

# Shift so $1 etc starts with the package name, not the options.
shift $((OPTIND - 1))

# Need Git.
command -v git >/dev/null 2>&1 || {
    echo "Error: Git is not installed."
    exit 1
}

# Quit if both -r and -d are set.
if [[ "$DELETE_MODE" == true && "$RESTORE_MODE" == true ]]; then
    echo "Error: -d and -r cannot be used together."
    exit 1
fi

# -----------------------------
# Process the packages
# -----------------------------

load_ignore_patterns

while IFS= read -r pkg; do
    [[ -n "$pkg" ]] && PACKAGES+=("$pkg")
done < <(expand_packages "$@")

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    echo "No packages found."
    exit 1
fi

if ! confirm_action; then
    echo "Aborted."
    exit 0
fi

if [[ "$RESTORE_MODE" == true ]]; then
    for pkg in "${PACKAGES[@]}"; do
        process_package_restore_files "$pkg"
    done

    for pkg in "${PACKAGES[@]}"; do
        cleanup_empty_dirs "$pkg"
    done

    for pkg in "${PACKAGES[@]}"; do
        restore_directory_backups "$pkg"
    done

    echo
    echo "Done."
    exit 0
fi

for pkg in "${PACKAGES[@]}"; do
    process_package_apply "$pkg"
done

echo
echo "Done."
