#!/bin/bash

set -euo pipefail

TAKEMI_ROOT="$(cd "$(dirname "$0")" && pwd -P)"
LIVE_ENGINE="${HOME}/.codex/codex-dream-skin-studio"
TEST_ROOT="$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/takemi-macos-test.XXXXXX")"
ENGINE_COPY="$TEST_ROOT/engine"
STATE_COPY="$TEST_ROOT/state"

cleanup() {
  case "$TEST_ROOT" in "${TMPDIR:-/tmp}"/takemi-macos-test.*|/tmp/takemi-macos-test.*) /bin/rm -rf "$TEST_ROOT" ;; esac
}
trap cleanup EXIT

. "$LIVE_ENGINE/scripts/common-macos.sh"
discover_codex_app
require_macos_runtime quick

/bin/mkdir -p "$ENGINE_COPY" "$STATE_COPY"
/bin/cp "$LIVE_ENGINE/VERSION" "$ENGINE_COPY/VERSION"
/bin/cp -R "$LIVE_ENGINE/assets" "$ENGINE_COPY/assets"

first="$($NODE "$TAKEMI_ROOT/patch-takemi-runtime.mjs" --engine-root "$ENGINE_COPY" --state-root "$STATE_COPY")"
second="$($NODE "$TAKEMI_ROOT/patch-takemi-runtime.mjs" --engine-root "$ENGINE_COPY" --state-root "$STATE_COPY" --dry-run)"

printf '%s' "$first" | /usr/bin/grep -q '"mode": "apply"'
printf '%s' "$second" | /usr/bin/grep -q '"rendererChanged": false'
printf '%s' "$second" | /usr/bin/grep -q '"cssChanged": false'
[ "$(/usr/bin/grep -c 'P5R TAE TAKEMI TITLES v1.4 START' "$ENGINE_COPY/assets/renderer-inject.js")" -eq 1 ]
[ "$(/usr/bin/grep -c 'Local Dream Skin runtime supplement for the P5R Tae Takemi theme' "$ENGINE_COPY/assets/dream-skin.css")" -eq 1 ]
[ -f "$STATE_COPY/themes/p5r-tae-takemi-ethy/theme.json" ]
[ -f "$STATE_COPY/themes/p5r-tae-takemi-ethy/theme.css" ]
[ -f "$STATE_COPY/themes/p5r-tae-takemi-ethy/background.webp" ]

printf 'Takemi macOS patch test passed.\n'
