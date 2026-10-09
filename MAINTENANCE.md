# v1.3 maintenance map

## Canonical sources

- `takemi-runtime-override.css` is the only cross-platform full-theme CSS source.
- `p5r-tae-takemi-ethy-theme/` is the only base-theme asset source.
- `apply-takemi-runtime.ps1` owns Windows runtime patching.
- `macos/patch-takemi-runtime.mjs` and `macos/renderer-takemi-hooks.js` own macOS runtime patching and platform hooks.
- Runtime backups are generated under the Dream Skin state directory. They are not repository sources and must not be committed or copied into a release.

## Floating surface contracts

| Surface | Preferred selector contract | CSS primitive |
| --- | --- | --- |
| Tooltip and history hover card | `overlay-tooltip` → `[role="tooltip"]` | `[data-ds-part="tooltip"], [role="tooltip"]` |
| Menu, including profile menu | `overlay-menu` → `[role="menu"]` | `[data-ds-part="menu"], [data-radix-menu-content]` |
| Other Radix popper | `overlay-popper` → `[data-radix-popper-content-wrapper]` | component-specific rule only when semantics are insufficient |
| Dialog | `overlay-dialog` → `[role="dialog"]` | existing dialog rules |

Do not add selectors based on translated UI text. Prefer stable `data-*`, test IDs, roles, and Radix attributes in that order. Class fragments are compatibility fallbacks only.

## Update checklist

1. Reinstall the unmodified target Dream Skin runtime.
2. Confirm the version guard before changing it.
3. Re-run the Windows patch against a copied engine and the macOS patch test.
4. Inspect the live Codex DOM for each selector contract.
5. Verify tooltip, history hover card, profile menu, reasoning expanded/collapsed states, and terminal focus/resize.
6. Test both Chinese and English without adding text-dependent selectors.
7. Confirm the runtime supplement marker and renderer hook block occur exactly once after a second install.
8. Build releases from the canonical root CSS and base-theme directory only.
