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

