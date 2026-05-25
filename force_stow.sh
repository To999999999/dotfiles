#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# force_stow
# =========================================================
#
# Usage:
#   force_stow package
#   force_stow package1 package2
#   force_stow .
#   force_stow -d package
#   force_stow -d .
#   force_stow -r package
#   force_stow -r .
#
# Examples:
#   force_stow zsh
#   force_stow zsh nvim
#   force_stow .
#   force_stow -d nvim
#   force_stow -r zsh
#   force_stow -r .
#
# Requirements:
#   - GNU stow installed and available in PATH
#   - run from inside your dotfiles root
#
# Behavior:
#   - backups conflicting targets as *.bakfs before stowing
#   - with -d: conflicting targets are deleted instead
#   - with -r: unstows package(s) and restores *.bakfs backups
#   - supports one package, many packages, or all packages via '.'
#   - ignores files matching .stowrc ignore rules
#
# =========================================================

DELETE_MODE=0
RESTORE_MODE=0

usage() {
  echo "Usage: force_stow [-d|-r] package [package2 ...] | ."
  exit 1
}

while getopts ":dr" opt; do
  case "$opt" in
    d)
      DELETE_MODE=1
      ;;
    r)
      RESTORE_MODE=1
      ;;
    *)
      usage
      ;;
  esac
done

shift $((OPTIND - 1))

PACKAGES_INPUT=("$@")

[ ${#PACKAGES_INPUT[@]} -eq 0 ] && usage

if [ "$DELETE_MODE" -eq 1 ] && [ "$RESTORE_MODE" -eq 1 ]; then
  echo "ERROR: -d and -r are mutually exclusive"
  exit 1
fi

DOTFILES_ROOT="$(pwd)"
TARGET_ROOT="$HOME"

# =========================================================
# Dependency checks
# =========================================================

if ! command -v stow >/dev/null 2>&1; then
  echo "ERROR: GNU Stow is not installed or not in PATH"
  exit 1
fi

# =========================================================
# Parse .stowrc ignore rules
# =========================================================

IGNORE_PATTERNS=()

if [ -f "$DOTFILES_ROOT/.stowrc" ]; then
  while IFS= read -r line; do

    if [[ "$line" =~ --ignore=\'(.*)\' ]]; then
      IGNORE_PATTERNS+=("${BASH_REMATCH[1]}")
    fi

  done < "$DOTFILES_ROOT/.stowrc"
fi

should_ignore() {
  local path="$1"
  local base

  base="$(basename "$path")"

  for pattern in "${IGNORE_PATTERNS[@]}"; do
    if [[ "$base" =~ $pattern ]]; then
      return 0
    fi
  done

  return 1
}

# =========================================================
# Determine package list
# =========================================================

PACKAGES=()

if printf '%s
' "${PACKAGES_INPUT[@]}" | grep -qx '\.'; then

  while IFS= read -r dir; do

    base="$(basename "$dir")"

    if should_ignore "$base"; then
      continue
    fi

    PACKAGES+=("$base")

  done < <(find "$DOTFILES_ROOT" -mindepth 1 -maxdepth 1 -type d)

else

  for PACKAGE in "${PACKAGES_INPUT[@]}"; do

    PACKAGE_PATH="$DOTFILES_ROOT/$PACKAGE"

    if [ ! -d "$PACKAGE_PATH" ]; then
      echo "ERROR: package '$PACKAGE' does not exist"
      exit 1
    fi

    PACKAGES+=("$PACKAGE")

  done

fi

# =========================================================
# Restore mode
# =========================================================

if [ "$RESTORE_MODE" -eq 1 ]; then

  for PACKAGE in "${PACKAGES[@]}"; do

    PACKAGE_PATH="$DOTFILES_ROOT/$PACKAGE"

    echo
    echo "========================================================="
    echo "Restoring package: $PACKAGE"
    echo "========================================================="

    stow -D "$PACKAGE"

    find "$PACKAGE_PATH" -mindepth 1 | while read -r source_path; do

      rel_path="${source_path#$PACKAGE_PATH/}"
      target_path="$TARGET_ROOT/$rel_path"
      backup_path="${target_path}.bakfs"

      if should_ignore "$source_path"; then
        continue
      fi

      if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
        echo "Restoring: $backup_path -> $target_path"

        rm -rf "$target_path"
        mv "$backup_path" "$target_path"
      fi

    done

  done

  echo
  echo "Done."
  exit 0
fi

# =========================================================
# Remove or backup conflicting targets
# =========================================================

for PACKAGE in "${PACKAGES[@]}"; do

  PACKAGE_PATH="$DOTFILES_ROOT/$PACKAGE"

  echo
  echo "========================================================="
  echo "Processing package: $PACKAGE"
  echo "========================================================="

  find "$PACKAGE_PATH" -mindepth 1 | while read -r source_path; do

    rel_path="${source_path#$PACKAGE_PATH/}"
    target_path="$TARGET_ROOT/$rel_path"

    if should_ignore "$source_path"; then
      echo "Ignoring: $rel_path"
      continue
    fi

    # Skip if target doesn't exist
    if [ ! -e "$target_path" ] && [ ! -L "$target_path" ]; then
      continue
    fi

    # Skip if already correct symlink
    if [ -L "$target_path" ]; then
      resolved="$(readlink "$target_path")"

      if [ "$resolved" = "$source_path" ]; then
        echo "Already linked: $target_path"
        continue
      fi
    fi

    # Delete mode
    if [ "$DELETE_MODE" -eq 1 ]; then
      echo "Removing: $target_path"
      rm -rf "$target_path"
    else
      backup_path="${target_path}.bakfs"

      echo "Backing up: $target_path -> $backup_path"

      rm -rf "$backup_path"
      mv "$target_path" "$backup_path"
    fi

  done

  echo
  echo "Running: stow $PACKAGE"

  stow "$PACKAGE"

 done

# =========================================================
# Finished
# =========================================================

echo
echo "Done."
