#!/bin/bash

set -euo pipefail

TAKEMI_ROOT="$(cd "$(dirname "$0")" && pwd -P)"
ENGINE_ROOT="${HOME}/.codex/codex-dream-skin-studio"
STATE_ROOT="${HOME}/Library/Application Support/CodexDreamSkinStudio"
DRY_RUN="false"
APPLY_NOW="true"
SCREENSHOT=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN="true"; APPLY_NOW="false"; shift ;;
    --no-apply) APPLY_NOW="false"; shift ;;
    --screenshot) SCREENSHOT="${2:-}"; shift 2 ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; exit 1 ;;
  esac
done

[ -d "$ENGINE_ROOT" ] || {
  printf 'Dream Skin engine is not installed at %s\n' "$ENGINE_ROOT" >&2
  exit 1
}

. "$ENGINE_ROOT/scripts/common-macos.sh"
discover_codex_app
require_macos_runtime quick

patch_args=(
  --engine-root "$ENGINE_ROOT"
  --state-root "$STATE_ROOT"
)
[ "$DRY_RUN" = "false" ] || patch_args+=(--dry-run)
"$NODE" "$TAKEMI_ROOT/patch-takemi-runtime.mjs" "${patch_args[@]}"

[ "$APPLY_NOW" = "true" ] || exit 0

"$ENGINE_ROOT/scripts/switch-theme-macos.sh" --id p5r-tae-takemi-ethy
if [ -n "$SCREENSHOT" ]; then
  /bin/mkdir -p "$(/usr/bin/dirname "$SCREENSHOT")"
  "$ENGINE_ROOT/scripts/verify-dream-skin-macos.sh" --screenshot "$SCREENSHOT"
else
  "$ENGINE_ROOT/scripts/verify-dream-skin-macos.sh"
fi

printf 'Takemi full macOS runtime theme is active and verified.\n'
