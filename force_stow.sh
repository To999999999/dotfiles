#!/usr/bin/env bash

set -eo pipefail
set -u

# -----------------------------
# Config
# -----------------------------
#
BACKUP_EXT=".bakfs"

DELETE_MODE=false
RESTORE_MODE=false
AUTO_YES=false

DOTFILES_DIR="$(pwd -P)"
TARGET_DIR="$(cd .. && pwd -P)"

# List of what .stowrc wants us to ignore
IGNORE_PATTERNS=()

# List of packages
PACKAGES=()

# -----------------------------
# Utilities
# -----------------------------

usage() {
    cat <<EOF
Usage:
  force_stow [options] package1 [package2 ...]
  force_stow [options]

Options:
  -d    Delete conflicting files instead of backing them up
  -r    Reverse operation (unstow + restore backups)
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
        echo "Restore stow packages:"
    else
        echo "Force stow on:"
    fi

    printf '  - %s\n' "${PACKAGES[@]}"

    echo

    if [[ "$RESTORE_MODE" == true ]]; then
        echo "Stow symlinks will be removed."
        echo "Backups ending with '$BACKUP_EXT' will be restored."
    elif [[ "$DELETE_MODE" == true ]]; then
        echo "WARNING: existing configs will be deleted."
    else
        echo "Existing configs will be backed up with '$BACKUP_EXT'."
    fi

    if [[ "$AUTO_YES" == true ]]; then
        echo "Auto-confirmed (-y)."
        return 0
    fi

    ask_yes_no "Continue?"
}

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

# List all the packages selected (all of the if the argument is empty)
expand_packages() {
    if (($# == 0)); then
        find . \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            ! -name '.git' \
            ! -name '.stow-cache' \
            -exec basename {} \; \
            | sort
    else
        local pkg

        for pkg in "$@"; do
            pkg="${pkg%/}"
            printf '%s\n' "$pkg"
        done
    fi
}

# List all files for the package (wihtout those ignored) 
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

# Process a package -> delete or create backup if a target package file already exist 
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

# Process a pacakge -> restore a backup file if target package's backup exists (removes the extension)
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

# -----------------------------
# Options, arguments and dependencies
# -----------------------------

# Get the options
while getopts ":dryh" opt; do
    case "$opt" in
        d) DELETE_MODE=true ;;
        r) RESTORE_MODE=true ;;
        y) AUTO_YES=true ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

# Shift so $1 etc starts witht the package we want to stow (ex zsh, and not -r)
shift $((OPTIND - 1))

# Need stow
command -v stow >/dev/null 2>&1 || {
    echo "Error: GNU Stow is not installed."
    exit 1
}

# Need Git
command -v git >/dev/null 2>&1 || {
    echo "Error: Git is not installed."
    exit 1
}

# Quit if both -r and -d are set
if [[ "$DELETE_MODE" == true && "$RESTORE_MODE" == true ]]; then
    echo "Error: -d and -r cannot be used together."
    exit 1
fi

# -----------------------------
# Process the packages
# -----------------------------

# Get the list of all file's patterns we should ignore
load_ignore_patterns

# Get the list of packages  
while IFS= read -r pkg; do
    [[ -n "$pkg" ]] && PACKAGES+=("$pkg")
done < <(expand_packages "$@")

# If no packages found, quit
if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    echo "No packages found."
    exit 1
fi

# Prompt the user if he wants to continue
if ! confirm_action; then
    echo "Aborted."
    exit 0
fi

# If the restore mode is set, restore the backups and removes the links left with stow
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

# If the restore mode is not set, process every packages and use stow for all of them
for pkg in "${PACKAGES[@]}"; do
    process_package_apply "$pkg"
done

echo
echo "=== Running stow ==="
stow "${PACKAGES[@]}"

echo
echo "Done."
#
# -----------------------------
# -----------------------------
