param(
  [string]$EngineRoot = '',
  [string]$StateRoot = ''
)

$ErrorActionPreference = 'Stop'

if (-not $StateRoot) {
  if (-not $env:LOCALAPPDATA) { throw 'LOCALAPPDATA is unavailable. Pass -StateRoot explicitly.' }
  $StateRoot = Join-Path $env:LOCALAPPDATA 'CodexDreamSkin'
}
if (-not $EngineRoot) { $EngineRoot = Join-Path $StateRoot 'engine' }

$themeSource = Join-Path $PSScriptRoot 'p5r-tae-takemi-ethy-theme'
$overridePath = Join-Path $PSScriptRoot 'takemi-runtime-override.css'
$assetsRoot = Join-Path $EngineRoot 'assets'
$rendererPath = Join-Path $assetsRoot 'renderer-inject.js'
$baseCssPath = Join-Path $assetsRoot 'dream-skin.css'
$versionPath = Join-Path $EngineRoot 'VERSION'
$safeCssValidator = Join-Path $EngineRoot 'scripts\validate-safe-css-file.mjs'
$bundledNode = Join-Path $EngineRoot 'runtime\node\node.exe'
$savedTheme = Join-Path $StateRoot 'themes\p5r-tae-takemi-ethy'
$backupRoot = Join-Path $PSScriptRoot 'runtime-backup'

function Assert-PlainDirectory([string]$Path, [string]$Label) {
  if (-not (Test-Path -LiteralPath $Path -PathType Container)) { throw "Missing $Label directory: $Path" }
  $item = Get-Item -LiteralPath $Path -Force
  if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
    throw "$Label directory must not be a link or reparse point: $Path"
  }
}

function Replace-Unique([string]$Text, [string]$Old, [string]$New, [string]$Label) {
  if ($Text.Contains($New)) { return $Text }
  if ($Text.Split(@($Old), [System.StringSplitOptions]::None).Length -ne 2) {
    throw "$Label insertion point is missing or ambiguous. Reinstall Dream Skin 1.5.19 before retrying."
  }
  return $Text.Replace($Old, $New)
}

Assert-PlainDirectory $EngineRoot 'Dream Skin engine'
Assert-PlainDirectory $assetsRoot 'Dream Skin assets'

$requiredFiles = @(
  $versionPath, $rendererPath, $baseCssPath, $safeCssValidator, $bundledNode,
  $overridePath, (Join-Path $themeSource 'theme.json'), (Join-Path $themeSource 'theme.css')
)
foreach ($path in $requiredFiles) {
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing required file: $path" }
  if ((Get-Item -LiteralPath $path).Length -le 0) { throw "Required file is empty: $path" }
}

$runtimeVersion = ([System.IO.File]::ReadAllText($versionPath)).Trim()
if ($runtimeVersion -cne '1.5.19') {
  throw "This runtime patch is verified only for Dream Skin 1.5.19; found '$runtimeVersion'."
}

$themeConfig = Get-Content -LiteralPath (Join-Path $themeSource 'theme.json') -Raw | ConvertFrom-Json
if ([string]$themeConfig.id -cne 'p5r-tae-takemi-ethy') { throw 'Unexpected theme id.' }
$imageName = [string]$themeConfig.image
if ($imageName -notin @('background.webp', 'background.jpg', 'background.png')) {
  throw 'Unsupported theme background file.'
}
$imagePath = Join-Path $themeSource $imageName
if (-not (Test-Path -LiteralPath $imagePath -PathType Leaf) -or (Get-Item -LiteralPath $imagePath).Length -le 0) {
  throw 'Theme background is missing or empty.'
}

& $bundledNode $safeCssValidator (Join-Path $themeSource 'theme.css') | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Theme Safe CSS validation failed.' }

$renderer = [System.IO.File]::ReadAllText($rendererPath).Replace("`r`n", "`n")
$baseCss = [System.IO.File]::ReadAllText($baseCssPath)
$override = [System.IO.File]::ReadAllText($overridePath)

# The 1.5.18 bare attribute selector blanks 26.924+ conversation routes.
$safeFadeSelector = ':is(.app-shell-main-content-top-fade, [data-app-shell-main-content-top-fade]:not(:has(*)), [class*="_MainContentTopFade_"])'
if (-not $baseCss.Contains($safeFadeSelector)) {
  throw 'The Dream Skin 1.5.19 safe top-fade selector is missing. Reinstall the unmodified 1.5.19 runtime.'
}

$rootAttrsOld = '    "data-dream-skin", SHELL_ATTR, "data-dream-upload-alpha",'
$rootAttrsPrevious = '    "data-dream-skin", "data-dream-skin-theme-id", SHELL_ATTR, "data-dream-upload-alpha",'
$rootAttrsProfile = '    "data-dream-skin", "data-dream-skin-theme-id", "data-takemi-profile-page", SHELL_ATTR, "data-dream-upload-alpha",'
$rootAttrsNew = '    "data-dream-skin", "data-dream-skin-theme-id", "data-takemi-profile-page", "data-takemi-settings-page", SHELL_ATTR, "data-dream-upload-alpha",'
if (-not $renderer.Contains($rootAttrsNew)) {
  if ($renderer.Contains($rootAttrsProfile)) {
    $renderer = Replace-Unique $renderer $rootAttrsProfile $rootAttrsNew 'Settings cleanup attribute upgrade'
  } elseif ($renderer.Contains($rootAttrsPrevious)) {
    $renderer = Replace-Unique $renderer $rootAttrsPrevious $rootAttrsNew 'Theme cleanup attribute upgrade'
  } else {
    $renderer = Replace-Unique $renderer $rootAttrsOld $rootAttrsNew 'Theme cleanup attribute'
  }
}
$rootStateOld = '    setAttribute(root, "data-dream-skin", "active");'
$rootStateNew = $rootStateOld + "`n" + '    setAttribute(root, "data-dream-skin-theme-id", THEME.id || "custom");'
$renderer = Replace-Unique $renderer $rootStateOld $rootStateNew 'Theme id'

$titleMarkerStart = '  /* P5R TAE TAKEMI TITLES v1.4 START */'
$titleMarkerEnd = '  /* P5R TAE TAKEMI TITLES v1.4 END */'
$titleBlock = @'
  /* P5R TAE TAKEMI TITLES v1.4 START */
  const refreshP5RTitles = () => {
    if ((THEME.id || "custom") !== "p5r-tae-takemi-ethy") return;
    const p5rChinese = /^zh(?:-|$)/i.test(document.documentElement.lang || navigator.language || "en");
    const p5rBefore = p5rChinese ? "\u6211\u4eec\u8981\u5728 " : "What shall we build in ";
    const p5rAfter = p5rChinese
      ? " \u6784\u5efa\u4ec0\u4e48\uff1f\u5c0f\u767d\u9f20~"
      : " today, my little guinea pig~?";
    const p5rHomePrompt = document.querySelector(
      '[data-ds-part="home-hero"] > [class~="group/title"]',
    );
    const p5rProjectButton = p5rHomePrompt?.querySelector('button[data-slot="popover-trigger"]');
    if (p5rHomePrompt && p5rProjectButton) {
      const p5rChildren = [...p5rHomePrompt.childNodes];
      const p5rProjectIndex = p5rChildren.indexOf(p5rProjectButton);
      const p5rBeforeNodes = p5rChildren.slice(0, p5rProjectIndex).filter((node) => node.nodeType === 3);
      const p5rAfterNodes = p5rChildren.slice(p5rProjectIndex + 1).filter((node) => node.nodeType === 3);
      if (p5rBeforeNodes.length) {
        if (p5rBeforeNodes[0].nodeValue !== p5rBefore) p5rBeforeNodes[0].nodeValue = p5rBefore;
        for (const node of p5rBeforeNodes.slice(1)) if (node.nodeValue) node.nodeValue = "";
      } else p5rHomePrompt.insertBefore(document.createTextNode(p5rBefore), p5rProjectButton);
      if (p5rAfterNodes.length) {
        if (p5rAfterNodes[0].nodeValue !== p5rAfter) p5rAfterNodes[0].nodeValue = p5rAfter;
        for (const node of p5rAfterNodes.slice(1)) if (node.nodeValue) node.nodeValue = "";
      } else p5rHomePrompt.appendChild(document.createTextNode(p5rAfter));
    }
    const p5rChatTitle = p5rChinese
      ? "\u4eca\u5929\u60f3\u804a\u70b9\u4ec0\u4e48\uff1f\u5c0f\u767d\u9f20~"
      : "What would you like to talk about today, my little guinea pig~?";
    const p5rWorkTitle = p5rChinese
      ? "\u6211\u4eec\u8981\u505a\u70b9\u4ec0\u4e48\uff1f\u5c0f\u767d\u9f20~"
      : "What shall we work on, my little guinea pig~?";
    const p5rWorkTitleNode = document.querySelector(
      'main[data-ds-part="main"] [data-feature="game-source"] > [class~="group/title"]',
    );
    if (p5rWorkTitleNode && p5rWorkTitleNode.textContent !== p5rWorkTitle) {
      p5rWorkTitleNode.textContent = p5rWorkTitle;
    }
    document.querySelectorAll('main[data-ds-part="main"] h1 [data-headline]').forEach((node) => {
      if (node.textContent !== p5rChatTitle) node.textContent = p5rChatTitle;
    });
  };

  const refreshP5RSurfaceMarkers = () => {
    if ((THEME.id || "custom") !== "p5r-tae-takemi-ethy") return;
    const p5rRoot = document.documentElement;
    const p5rMain = document.querySelector('main[data-ds-part="main"]');
    const p5rProfilePage = p5rMain?.querySelector(
      '[class*="_page_1eppv_"]:has(> [class*="_content_1eppv_"]), ' +
      '[class*="_page_"]:has([data-profile-share-card-preview-hover-target]), ' +
      '[class*="_page_"]:has([data-showcase-card-id])',
    );
    if (p5rProfilePage) {
      if (p5rRoot.getAttribute("data-takemi-profile-page") !== "true") {
        p5rRoot.setAttribute("data-takemi-profile-page", "true");
      }
    } else if (p5rRoot.hasAttribute("data-takemi-profile-page")) {
      p5rRoot.removeAttribute("data-takemi-profile-page");
    }
    const p5rSettingsTitle = p5rMain?.querySelector('[class*="_shell_"] h1.heading-xl, h1.heading-xl');
    const p5rSettingsTitleText = (p5rSettingsTitle?.textContent || "").trim().toLocaleLowerCase();
    const p5rSettingsPages = new Map([
      ["\u5e94\u7528\u5feb\u7167", "appshots"],
      ["app snapshot", "appshots"],
      ["app snapshots", "appshots"],
      ["\u63d2\u4ef6", "plugins"],
      ["plugin", "plugins"],
      ["plugins", "plugins"],
      ["\u4f7f\u7528\u60c5\u51b5", "usage"],
      ["usage", "usage"],
      ["\u952e\u76d8\u5feb\u6377\u952e", "shortcuts"],
      ["keyboard shortcuts", "shortcuts"],
      ["\u865a\u62df\u5ba0\u7269", "pets"],
      ["\u6211\u7684\u865a\u62df\u5ba0\u7269", "pets"],
      ["virtual pets", "pets"],
      ["my virtual pets", "pets"],
      ["pets", "pets"],
      ["\u6dfb\u52a0\u5bb6\u5ead\u6210\u5458", "family"],
      ["add family member", "family"],
    ]);
    const p5rSettingsPage = p5rSettingsPages.get(p5rSettingsTitleText) || "";
    if (p5rSettingsPage) {
      if (p5rRoot.getAttribute("data-takemi-settings-page") !== p5rSettingsPage) {
        p5rRoot.setAttribute("data-takemi-settings-page", p5rSettingsPage);
      }
    } else if (p5rRoot.hasAttribute("data-takemi-settings-page")) {
      p5rRoot.removeAttribute("data-takemi-settings-page");
    }
  };
  /* P5R TAE TAKEMI TITLES v1.4 END */

'@
$titleBlock = $titleBlock.Replace("`r`n", "`n")
if (-not $renderer.Contains($titleMarkerStart)) {
  $titleAnchor = '  const refreshScope = () => {'
  if ($renderer.Split(@($titleAnchor), [System.StringSplitOptions]::None).Length -ne 2) {
    throw 'The title helper insertion point is missing or ambiguous.'
  }
  $renderer = $renderer.Replace($titleAnchor, $titleBlock + $titleAnchor)
} elseif (-not $renderer.Contains($titleMarkerEnd)) {
  throw 'The existing P5R title block is incomplete.'
} else {
  if ($renderer.Split(@($titleMarkerStart), [System.StringSplitOptions]::None).Length -ne 2 -or
      $renderer.Split(@($titleMarkerEnd), [System.StringSplitOptions]::None).Length -ne 2) {
    throw 'The existing P5R title block is duplicated.'
  }
  $titleStartIndex = $renderer.IndexOf($titleMarkerStart, [System.StringComparison]::Ordinal)
  $titleEndIndex = $renderer.IndexOf($titleMarkerEnd, $titleStartIndex, [System.StringComparison]::Ordinal)
  $titleEndIndex += $titleMarkerEnd.Length
  $renderer = $renderer.Substring(0, $titleStartIndex) + $titleBlock.TrimEnd() + $renderer.Substring($titleEndIndex)
}

$refreshOld = "      refreshParts();`n      refreshPredicates();"
$refreshPrevious = $refreshOld + "`n      refreshP5RTitles();"
$refreshNew = $refreshOld + "`n      refreshP5RTitles();`n      refreshP5RSurfaceMarkers();"
if (-not $renderer.Contains($refreshNew)) {
  if ($renderer.Contains($refreshPrevious)) {
    $renderer = Replace-Unique $renderer $refreshPrevious $refreshNew 'Surface marker refresh upgrade'
  } else {
    $renderer = Replace-Unique $renderer $refreshOld $refreshNew 'Title and surface marker refresh'
  }
}
$languageWatchOld = '      attributeFilter: ["class", "data-theme", "data-appearance", "data-color-mode"],'
$languageWatchNew = '      attributeFilter: ["class", "data-theme", "data-appearance", "data-color-mode", "lang"],'
$renderer = Replace-Unique $renderer $languageWatchOld $languageWatchNew 'Language observer'

$marker = '/* Local Dream Skin runtime supplement for the P5R Tae Takemi theme. */'
$markerIndex = $baseCss.IndexOf($marker, [System.StringComparison]::Ordinal)
if ($markerIndex -ge 0) { $baseCss = $baseCss.Substring(0, $markerIndex) }
$baseCss = $baseCss.TrimEnd() + "`r`n`r`n" + $override.TrimEnd() + "`r`n"

$rendererForCompile = $renderer.Replace('__DREAM_SKIN_CSS_JSON__', '""')
$rendererForCompile = $rendererForCompile.Replace('__DREAM_SKIN_ART_JSON__', '"data:image/webp;base64,"')
$rendererForCompile = $rendererForCompile.Replace('__DREAM_SKIN_THEME_JSON__', '{}')
$rendererForCompile = $rendererForCompile.Replace('__DREAM_SKIN_ART_METADATA_JSON__', 'null')
$rendererForCompile = $rendererForCompile.Replace('__DREAM_SKIN_VERSION_JSON__', '"1.5.19"')
$rendererForCompile = $rendererForCompile.Replace('__DREAM_SKIN_STYLE_REVISION_JSON__', '"takemi-check"')
$rendererForCompile = $rendererForCompile.Replace('__DREAM_SKIN_PAYLOAD_REVISION_JSON__', '"takemi-check"')
$compilePath = Join-Path ([System.IO.Path]::GetTempPath()) ("takemi-renderer-{0}.js" -f [guid]::NewGuid().ToString('N'))
try {
  [System.IO.File]::WriteAllText($compilePath, $rendererForCompile, (New-Object System.Text.UTF8Encoding($false)))
  & $bundledNode --check $compilePath | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'The patched renderer failed JavaScript syntax validation.' }
} finally {
  if (Test-Path -LiteralPath $compilePath -PathType Leaf) { Remove-Item -LiteralPath $compilePath -Force }
}

New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
New-Item -ItemType Directory -Path $savedTheme -Force | Out-Null
foreach ($name in @('renderer-inject.js', 'dream-skin.css')) {
  $backup = Join-Path $backupRoot $name
  if (-not (Test-Path -LiteralPath $backup)) {
    Copy-Item -LiteralPath (Join-Path $assetsRoot $name) -Destination $backup
  }
}

$utf8 = New-Object System.Text.UTF8Encoding($false)
$originalRenderer = [System.IO.File]::ReadAllText($rendererPath)
$originalCss = [System.IO.File]::ReadAllText($baseCssPath)
try {
  [System.IO.File]::WriteAllText($rendererPath, $renderer, $utf8)
  [System.IO.File]::WriteAllText($baseCssPath, $baseCss, $utf8)
} catch {
  [System.IO.File]::WriteAllText($rendererPath, $originalRenderer, $utf8)
  [System.IO.File]::WriteAllText($baseCssPath, $originalCss, $utf8)
  throw
}

foreach ($destination in @($savedTheme)) {
  foreach ($name in @($imageName, 'theme.css', 'theme.json')) {
    Copy-Item -LiteralPath (Join-Path $themeSource $name) -Destination (Join-Path $destination $name) -Force
  }
  foreach ($staleImage in @('background.webp', 'background.jpg', 'background.png')) {
    if ($staleImage -ceq $imageName) { continue }
    $stalePath = Join-Path $destination $staleImage
    if (Test-Path -LiteralPath $stalePath -PathType Leaf) { Remove-Item -LiteralPath $stalePath -Force }
  }
}

Write-Output 'Takemi v1.4 runtime supplement installed for Dream Skin 1.5.19. Select the saved theme from the tray, then restart or refresh Codex.'
