#!/usr/bin/env node

import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { Script } from "node:vm";
import { fileURLToPath } from "node:url";

const SCRIPT_ROOT = path.dirname(fileURLToPath(import.meta.url));
const EXPECTED_VERSION = "1.5.19";
const THEME_ID = "p5r-tae-takemi-ethy";
const CSS_MARKER = "/* Local Dream Skin runtime supplement for the P5R Tae Takemi theme. */";
const HOOK_START = "  /* P5R TAE TAKEMI TITLES v1.4 START */";
const HOOK_END = "  /* P5R TAE TAKEMI TITLES v1.4 END */";

const options = {
  engineRoot: path.join(os.homedir(), ".codex", "codex-dream-skin-studio"),
  stateRoot: path.join(os.homedir(), "Library", "Application Support", "CodexDreamSkinStudio"),
  themeSource: path.join(SCRIPT_ROOT, "theme"),
  overridePath: path.join(SCRIPT_ROOT, "takemi-runtime-override.css"),
  hooksPath: path.join(SCRIPT_ROOT, "renderer-takemi-hooks.js"),
  backupRoot: path.join(SCRIPT_ROOT, "runtime-backup"),
  dryRun: false,
};

for (let index = 2; index < process.argv.length; index += 1) {
  const argument = process.argv[index];
  if (argument === "--dry-run") options.dryRun = true;
  else if (argument === "--engine-root") options.engineRoot = process.argv[++index] || "";
  else if (argument === "--state-root") options.stateRoot = process.argv[++index] || "";
  else throw new Error(`Unknown argument: ${argument}`);
}

const sha256 = (value) => crypto.createHash("sha256").update(value).digest("hex");

function assertPlainDirectory(target, label, { create = false } = {}) {
  if (create && !fs.existsSync(target)) fs.mkdirSync(target, { recursive: true, mode: 0o700 });
  const stat = fs.lstatSync(target, { throwIfNoEntry: false });
  if (!stat?.isDirectory() || stat.isSymbolicLink()) {
    throw new Error(`${label} must be a plain directory: ${target}`);
  }
}

function assertRegularFile(target, label) {
  const stat = fs.lstatSync(target, { throwIfNoEntry: false });
  if (!stat?.isFile() || stat.isSymbolicLink() || stat.size <= 0) {
    throw new Error(`${label} is missing, empty, or not a regular file: ${target}`);
  }
}

function replaceUnique(text, before, after, label) {
  if (text.includes(after)) return text;
  const first = text.indexOf(before);
  if (first < 0 || text.indexOf(before, first + before.length) >= 0) {
    throw new Error(`${label} insertion point is missing or ambiguous. Reinstall unmodified Dream Skin ${EXPECTED_VERSION}.`);
  }
  return text.slice(0, first) + after + text.slice(first + before.length);
}

function atomicWrite(target, contents, mode = 0o600) {
  const temporary = `${target}.takemi-${process.pid}-${crypto.randomBytes(4).toString("hex")}`;
  fs.writeFileSync(temporary, contents, { encoding: "utf8", mode });
  fs.chmodSync(temporary, mode);
  fs.renameSync(temporary, target);
}

function atomicCopy(source, target) {
  assertRegularFile(source, "Theme payload");
  const temporary = `${target}.takemi-${process.pid}-${crypto.randomBytes(4).toString("hex")}`;
  fs.copyFileSync(source, temporary, fs.constants.COPYFILE_EXCL);
  fs.chmodSync(temporary, 0o600);
  fs.renameSync(temporary, target);
}

const assetsRoot = path.join(options.engineRoot, "assets");
const rendererPath = path.join(assetsRoot, "renderer-inject.js");
const baseCssPath = path.join(assetsRoot, "dream-skin.css");
const versionPath = path.join(options.engineRoot, "VERSION");
const safeCssValidator = path.join(assetsRoot, "safe-css-validator.mjs");
const themeJsonPath = path.join(options.themeSource, "theme.json");
const themeCssPath = path.join(options.themeSource, "theme.css");

assertPlainDirectory(options.engineRoot, "Dream Skin engine");
assertPlainDirectory(assetsRoot, "Dream Skin assets");
for (const [target, label] of [
  [versionPath, "Engine version"],
  [rendererPath, "Renderer template"],
  [baseCssPath, "Base CSS"],
  [safeCssValidator, "Safe CSS validator"],
  [options.overridePath, "Takemi runtime CSS"],
  [options.hooksPath, "Takemi renderer hooks"],
  [themeJsonPath, "Theme metadata"],
  [themeCssPath, "Theme Safe CSS"],
]) assertRegularFile(target, label);

const runtimeVersion = fs.readFileSync(versionPath, "utf8").trim();
if (runtimeVersion !== EXPECTED_VERSION) {
  throw new Error(`This patch is verified only for Dream Skin ${EXPECTED_VERSION}; found ${JSON.stringify(runtimeVersion)}.`);
}

const theme = JSON.parse(fs.readFileSync(themeJsonPath, "utf8"));
if (theme.id !== THEME_ID) throw new Error(`Unexpected theme id: ${JSON.stringify(theme.id)}`);
if (!["background.webp", "background.jpg", "background.png"].includes(theme.image)) {
  throw new Error(`Unsupported theme background: ${JSON.stringify(theme.image)}`);
}
const imagePath = path.join(options.themeSource, theme.image);
assertRegularFile(imagePath, "Theme background");
if (fs.statSync(imagePath).size > 10 * 1024 * 1024) throw new Error("Theme background exceeds 10 MiB.");

const cssValidation = spawnSync(process.execPath, [safeCssValidator, themeCssPath], {
  encoding: "utf8",
  stdio: ["ignore", "pipe", "pipe"],
});
if (cssValidation.status !== 0) {
  throw new Error(`Theme Safe CSS validation failed: ${(cssValidation.stderr || cssValidation.stdout).trim()}`);
}

const originalRenderer = fs.readFileSync(rendererPath, "utf8");
const originalCss = fs.readFileSync(baseCssPath, "utf8");
let renderer = originalRenderer.replace(/\r\n/g, "\n");
const override = fs.readFileSync(options.overridePath, "utf8").replace(/\r\n/g, "\n").trimEnd();
const hooks = fs.readFileSync(options.hooksPath, "utf8").replace(/\r\n/g, "\n");

const safeFadeSelector = ':is(.app-shell-main-content-top-fade, [data-app-shell-main-content-top-fade]:not(:has(*)), [class*="_MainContentTopFade_"])';
if (!originalCss.includes(safeFadeSelector)) {
  throw new Error(`Dream Skin ${EXPECTED_VERSION}'s safe top-fade selector is missing. Reinstall the unmodified engine.`);
}

const rootAttrsOld = '    "data-dream-skin", SHELL_ATTR, "data-dream-upload-alpha",';
const rootAttrsTheme = '    "data-dream-skin", "data-dream-skin-theme-id", SHELL_ATTR, "data-dream-upload-alpha",';
const rootAttrsProfile = '    "data-dream-skin", "data-dream-skin-theme-id", "data-takemi-profile-page", SHELL_ATTR, "data-dream-upload-alpha",';
const rootAttrsNew = '    "data-dream-skin", "data-dream-skin-theme-id", "data-takemi-profile-page", "data-takemi-settings-page", SHELL_ATTR, "data-dream-upload-alpha",';
if (!renderer.includes(rootAttrsNew)) {
  if (renderer.includes(rootAttrsProfile)) renderer = replaceUnique(renderer, rootAttrsProfile, rootAttrsNew, "Settings cleanup attribute");
  else if (renderer.includes(rootAttrsTheme)) renderer = replaceUnique(renderer, rootAttrsTheme, rootAttrsNew, "Profile cleanup attribute");
  else renderer = replaceUnique(renderer, rootAttrsOld, rootAttrsNew, "Theme cleanup attribute");
}

const rootStateOld = '    setAttribute(root, "data-dream-skin", "active");';
const rootStateNew = `${rootStateOld}\n    setAttribute(root, "data-dream-skin-theme-id", THEME.id || "custom");`;
renderer = replaceUnique(renderer, rootStateOld, rootStateNew, "Theme identity marker");

const hookStartIndex = renderer.indexOf(HOOK_START);
const hookEndIndex = renderer.indexOf(HOOK_END);
if (hookStartIndex < 0 && hookEndIndex < 0) {
  renderer = replaceUnique(renderer, "  const refreshScope = () => {", `${hooks}  const refreshScope = () => {`, "Takemi renderer hooks");
} else {
  if (hookStartIndex < 0 || hookEndIndex < hookStartIndex || renderer.indexOf(HOOK_START, hookStartIndex + 1) >= 0 || renderer.indexOf(HOOK_END, hookEndIndex + 1) >= 0) {
    throw new Error("Existing Takemi renderer hooks are incomplete or duplicated.");
  }
  renderer = renderer.slice(0, hookStartIndex) + hooks.trimEnd() + renderer.slice(hookEndIndex + HOOK_END.length);
}

const refreshOld = "      refreshParts();\n      refreshPredicates();";
const refreshTitleOnly = `${refreshOld}\n      refreshP5RTitles();`;
const refreshNew = `${refreshOld}\n      refreshP5RTitles();\n      refreshP5RSurfaceMarkers();`;
if (!renderer.includes(refreshNew)) {
  renderer = renderer.includes(refreshTitleOnly)
    ? replaceUnique(renderer, refreshTitleOnly, refreshNew, "Surface marker refresh")
    : replaceUnique(renderer, refreshOld, refreshNew, "Title and surface marker refresh");
}

const languageWatchOld = '      attributeFilter: ["class", "data-theme", "data-appearance", "data-color-mode"],';
const languageWatchNew = '      attributeFilter: ["class", "data-theme", "data-appearance", "data-color-mode", "lang"],';
renderer = replaceUnique(renderer, languageWatchOld, languageWatchNew, "Language observer");

const markerIndex = originalCss.indexOf(CSS_MARKER);
const cleanBaseCss = (markerIndex >= 0 ? originalCss.slice(0, markerIndex) : originalCss).trimEnd();
const patchedCss = `${cleanBaseCss}\n\n${override}\n`;

let rendererForCompile = renderer
  .replaceAll("__DREAM_SKIN_CSS_JSON__", '""')
  .replaceAll("__DREAM_SKIN_ART_JSON__", '"data:image/webp;base64,"')
  .replaceAll("__DREAM_SKIN_THEME_JSON__", "{}")
  .replaceAll("__DREAM_SKIN_ART_METADATA_JSON__", "null")
  .replaceAll("__DREAM_SKIN_VERSION_JSON__", `"${EXPECTED_VERSION}"`)
  .replaceAll("__DREAM_SKIN_STYLE_REVISION_JSON__", '"takemi-check"')
  .replaceAll("__DREAM_SKIN_PAYLOAD_REVISION_JSON__", '"takemi-check"');
if (/__DREAM_SKIN_[A-Z0-9_]+_JSON__/.test(rendererForCompile)) {
  throw new Error("Patched renderer still contains an unresolved payload placeholder.");
}
new Script(rendererForCompile, { filename: "takemi-renderer-check.js" });

const result = {
  mode: options.dryRun ? "dry-run" : "apply",
  version: runtimeVersion,
  themeId: theme.id,
  rendererChanged: renderer !== originalRenderer,
  cssChanged: patchedCss !== originalCss,
  rendererSha256: sha256(renderer),
  cssSha256: sha256(patchedCss),
};

if (!options.dryRun) {
  assertPlainDirectory(options.backupRoot, "Runtime backup", { create: true });
  const rendererBackup = path.join(options.backupRoot, "renderer-inject.js");
  const cssBackup = path.join(options.backupRoot, "dream-skin.css");
  if (!fs.existsSync(rendererBackup)) fs.copyFileSync(rendererPath, rendererBackup, fs.constants.COPYFILE_EXCL);
  if (!fs.existsSync(cssBackup)) fs.copyFileSync(baseCssPath, cssBackup, fs.constants.COPYFILE_EXCL);
  fs.chmodSync(rendererBackup, 0o600);
  fs.chmodSync(cssBackup, 0o600);

  const rendererMode = fs.statSync(rendererPath).mode & 0o777;
  const cssMode = fs.statSync(baseCssPath).mode & 0o777;
  try {
    atomicWrite(rendererPath, renderer, rendererMode);
    atomicWrite(baseCssPath, patchedCss, cssMode);
  } catch (error) {
    atomicWrite(rendererPath, originalRenderer, rendererMode);
    atomicWrite(baseCssPath, originalCss, cssMode);
    throw error;
  }

  const themesRoot = path.join(options.stateRoot, "themes");
  const savedTheme = path.join(themesRoot, THEME_ID);
  assertPlainDirectory(options.stateRoot, "Dream Skin state", { create: true });
  assertPlainDirectory(themesRoot, "Saved themes", { create: true });
  assertPlainDirectory(savedTheme, "Takemi saved theme", { create: true });
  for (const name of [theme.image, "theme.css", "theme.json"]) {
    atomicCopy(path.join(options.themeSource, name), path.join(savedTheme, name));
  }
  for (const staleImage of ["background.webp", "background.jpg", "background.png"]) {
    if (staleImage !== theme.image) fs.rmSync(path.join(savedTheme, staleImage), { force: true });
  }

  const metadata = {
    schema: "takemi-macos-runtime-backup/1",
    dreamSkinVersion: runtimeVersion,
    createdAt: new Date().toISOString(),
    rendererSha256: sha256(fs.readFileSync(rendererBackup)),
    cssSha256: sha256(fs.readFileSync(cssBackup)),
  };
  atomicWrite(path.join(options.backupRoot, "metadata.json"), `${JSON.stringify(metadata, null, 2)}\n`, 0o600);
}

process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
