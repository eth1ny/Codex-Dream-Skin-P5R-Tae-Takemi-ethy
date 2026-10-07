# Codex Dream Skin · Persona 5 Royal (P5R) · Tae Takemi Theme

[简体中文](./README.md)

**An immersive Persona 5 Royal / Tae Takemi-inspired theme for Codex.**  
P5R red, white, and black visuals · Native control restyling · Static low-overhead design · Chinese and English title support

[P5R · Tae Takemi Theme Background](./p5r-tae-takemi-ethy-theme/background.webp)

> Current theme version: `v1.0`. The full Windows runtime patch currently supports **Codex Dream Skin 1.5.19**. macOS support has been completed, with further real-device testing and fine-tuning planned.

This project is an independently maintained fork based on [Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin), focused on the Persona 5 Royal / Tae Takemi visual style, interface readability hierarchy, low-overhead static presentation, and theme localization.

The v1.0 release files are located directly in the repository root, including the base theme, full visual override styles, and the one-click Windows installer.

## Features

- Redesigns the visual presentation of the Codex Desktop home page, sidebar, composer, chat content, reasoning / thinking sections, and tool details around **Persona 5 Royal / Tae Takemi**.
- Uses a P5R-inspired red, white, and black visual hierarchy while preserving Codex's native controls and interaction logic.
- Adds dark reading overlays to Chat, Codex content, Reasoning / Thinking, and expanded tool details to improve text readability over complex backgrounds.
- Sidebar decoration is implemented primarily with CSS and follows the native sidebar's expanded / collapsed state.
- The current release uses a **static low-overhead design**. Animated character overlays, HUD animations, automatic message flashing, and other extra animated resources from earlier experiments have been removed.
- Theme titles refresh when the runtime `lang` value changes after switching languages. Other native Codex text continues to be handled by Codex's own localization system.

## Installation

### Windows: One-click full theme installation

The full theme currently supports **Codex Dream Skin 1.5.19**.

1. Install and launch Codex Dream Skin from [Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin).
2. Confirm that both Codex Desktop and Dream Skin open normally.
3. Download this repository as a ZIP and extract it anywhere.
4. **Double-click `Install-Takemi-Theme.bat` in the repository root.**
5. After installation completes, open **Saved Themes** from the Dream Skin tray menu and select **P5R · Tae Takemi · ethy**.
6. Restart or refresh Codex.

The batch file calls `apply-takemi-runtime.ps1` from the same directory. The script automatically checks the Dream Skin runtime version. If it is not `1.5.19`, installation stops to avoid modifying an unknown runtime version.

During installation, the following local Dream Skin runtime location is modified:

```text
%LOCALAPPDATA%\CodexDreamSkin\engine
```

The theme is also copied into Dream Skin's local theme directory.

Before the runtime is modified for the first time, the installer automatically creates:

```text
runtime-backup/
```

This directory stores the original runtime files.

> After Dream Skin is updated to a newer version, bypassing the version check is not recommended. Revalidate the runtime structure, DOM selectors, and visual overrides before declaring support for the new version.

### macOS: One-click full theme installation

Install and launch Codex Dream Skin 1.5.19 first, then double-click the following file inside the repository's `macos` folder:

```text
Install-Takemi-Theme.command
```

The installer automatically backs up the runtime, installs the theme, applies it immediately, and verifies the result.

Terminal installation:

```bash
./macos/apply-takemi-runtime-macos.sh --screenshot ./macos/local-evidence/takemi.png
```

Check compatibility without writing any changes:

```bash
./macos/apply-takemi-runtime-macos.sh --dry-run
```

Restore the original Dream Skin runtime while keeping the base Tae Takemi theme:

```bash
./macos/restore-takemi-runtime-macos.sh
```

## Current Compatibility

| Item | Status |
| --- | --- |
| Theme version | `v1.0` |
| Windows full runtime theme | ✅ Verified with Dream Skin `1.5.19` |
| Windows base theme ZIP | ✅ |
| macOS base theme ZIP | ✅ |
| macOS full runtime theme | ✅ Complete |

## Updates and Recovery

- Keep a copy of the current working version before updating the theme.
- On its first run, `apply-takemi-runtime.ps1` backs up the Dream Skin runtime files it modifies into `runtime-backup/`.
- After a major Dream Skin update, re-adapt and verify the theme patch instead of reusing an older runtime patch unchanged.
- If the full runtime theme encounters compatibility issues, restore or reinstall the original Dream Skin first, then use the base theme ZIP if needed.

## Technical Notes and Security

- This theme does not modify the official Codex Desktop binaries.
- It does not modify the official app signature, `WindowsApps` permissions, or `app.asar`.
- The full Windows setup modifies Dream Skin's local runtime copy under `%LOCALAPPDATA%\CodexDreamSkin`.
- The runtime patch saves backups of the original files before making changes.
- Dream Skin communicates with the Codex renderer through local loopback CDP. A loopback address should not be treated as equivalent to authentication.
- For the complete security boundary covering CDP, theme ZIPs, Safe CSS, file validation, and the local runtime, see the upstream [`SECURITY.md`](./SECURITY.md).

## Development and Maintenance

The theme currently consists of three main parts:

### Base Theme

[`p5r-tae-takemi-ethy-theme/`](./p5r-tae-takemi-ethy-theme/)

### Full P5R Visual Override

[`takemi-runtime-override.css`](./takemi-runtime-override.css)

### Windows Runtime Patch

[`apply-takemi-runtime.ps1`](./apply-takemi-runtime.ps1)

## License and Disclaimer

- This project is based on [Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin) and retains the original project's MIT license and author attribution.
- This is not an official OpenAI product. Codex and related rights belong to their respective rights holders.
- Persona 5 Royal, Tae Takemi, and all related character names, likenesses, assets, and trademarks belong to their respective rights holders.
- This theme is an unofficial fan creation. This repository does not grant commercial usage rights for any related character assets.

## Acknowledgements

- Original project: [Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin)
