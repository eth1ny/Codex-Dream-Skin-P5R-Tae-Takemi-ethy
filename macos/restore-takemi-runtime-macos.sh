#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
ENGINE_ROOT="${HOME}/.codex/codex-dream-skin-studio"
BACKUP_ROOT="${HOME}/Library/Application Support/CodexDreamSkinStudio/backups/p5r-tae-takemi-ethy/1.5.20"
APPLY_NOW="true"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --engine-root) ENGINE_ROOT="${2:-}"; shift 2 ;;
    --backup-root) BACKUP_ROOT="${2:-}"; shift 2 ;;
    --no-apply) APPLY_NOW="false"; shift ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; exit 1 ;;
  esac
done

RENDERER_BACKUP="$BACKUP_ROOT/renderer-inject.js"
CSS_BACKUP="$BACKUP_ROOT/dream-skin.css"
RENDERER_TARGET="$ENGINE_ROOT/assets/renderer-inject.js"
CSS_TARGET="$ENGINE_ROOT/assets/dream-skin.css"

for file in "$RENDERER_BACKUP" "$CSS_BACKUP" "$RENDERER_TARGET" "$CSS_TARGET"; do
  [ -f "$file" ] && [ ! -L "$file" ] || {
    printf 'Required restore file is missing or unsafe: %s\n' "$file" >&2
    exit 1
  }
done
[ "$(tr -d '[:space:]' < "$ENGINE_ROOT/VERSION")" = "1.5.20" ] || {
  printf 'Restore is locked to Dream Skin 1.5.20. Reinstall the current DMG instead.\n' >&2
  exit 1
}

restore_one() {
  local source="$1"
  local target="$2"
  local temporary="${target}.restore.$$"
  /bin/cp -p "$source" "$temporary"
  /bin/chmod 600 "$temporary"
  /bin/mv -f "$temporary" "$target"
}

restore_one "$RENDERER_BACKUP" "$RENDERER_TARGET"
restore_one "$CSS_BACKUP" "$CSS_TARGET"

if [ "$APPLY_NOW" = "true" ] && [ -x "$ENGINE_ROOT/scripts/switch-theme-macos.sh" ]; then
  "$ENGINE_ROOT/scripts/switch-theme-macos.sh" --id p5r-tae-takemi-ethy
  "$ENGINE_ROOT/scripts/verify-dream-skin-macos.sh"
fi

printf 'Takemi runtime supplement removed; the safe ZIP-level theme remains active.\n'

[executed on device: EthLocal (2f5dbfe9-c9cd-44fd-9aa7-77a77f7fac81)]