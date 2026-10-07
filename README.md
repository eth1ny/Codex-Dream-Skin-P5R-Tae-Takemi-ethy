# Codex Dream Skin · 女神异闻录5皇家版(P5R) · 武见妙 主题

[English](./README.en.md)

**本项目为 Codex 制作的 Persona 5 Royal / 武见妙 风格沉浸式主题。**  
P5R 红白黑视觉 · 原生控件换肤 · 静态低负载 · 中英文标题适配
<img width="1726" height="1261" alt="002" src="https://github.com/user-attachments/assets/137595f2-2225-4cfd-9ba4-19b5d312bbbc" />


[P5R · Tae Takemi 主题背景](./p5r-tae-takemi-ethy-theme/background.webp)

> 当前主题版本：`v1.0`。Windows 完整运行时补丁目前适配 **Codex Dream Skin 1.5.19**；macOS 适配已完成，后续继续进行实际设备测试与细节验证。

本项目是基于 [Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin) 持续维护的独立 fork，主要维护 Persona 5 Royal / 武见妙视觉、界面阅读层级、低负载静态表现与主题本地化。

本仓库的 v1.0 发布文件直接位于仓库根目录，包括基础主题、完整视觉覆盖样式与 Windows 一键安装脚本。

## 功能

- 以 **Persona 5 Royal / 武见妙** 为核心重新设计 Codex Desktop 首页、侧栏、输入区、聊天内容、思考过程与工具详情的视觉表现。
- 使用红、白、黑为主的 P5R 风格界面层级，同时保留 Codex 原生控件和交互逻辑。
- Chat、Codex 正文、Reasoning / Thinking 与展开的工具详情增加深色阅读蒙版，减少复杂背景对文字可读性的影响。
- 侧边栏装饰主要由 CSS 实现，并跟随原生侧边栏的展开 / 收起状态。
- 当前版本采用**静态低负载方案**，已移除早期测试中的角色动态贴图、HUD 动画、自动消息闪动和额外动态资源。
- 语言切换后主题标题可随运行时 `lang` 变化刷新；Codex 其他原生文本仍由 Codex 自身的本地化系统负责。

## 安装

### Windows ：一键安装完整主题

完整主题当前适配 **Codex Dream Skin 1.5.19**。

1. 先从 [Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin) 安装并启动 Codex Dream Skin。
2. 确认 Codex Desktop 与 Dream Skin 可以正常打开。
3. 下载本仓库 ZIP 并解压到任意位置。
4. **双击仓库根目录中的 `Install-Takemi-Theme.bat`。**
5. 等待安装完成后，在 Dream Skin 托盘菜单的 **Saved Themes / 已保存主题** 中选择 **P5R · Tae Takemi · ethy**。
6. 重启或刷新 Codex。

批处理文件会调用同目录下的 `apply-takemi-runtime.ps1`。脚本会自动检查 Dream Skin 运行时版本；如果不是 `1.5.19`，会停止安装，避免直接修改未知版本。

安装过程中会修改：

```text
%LOCALAPPDATA%\CodexDreamSkin\engine
```

中的 Dream Skin 本地运行时资源，并把主题复制到 Dream Skin 的本地主题目录。

首次修改前会自动创建：

```text
runtime-backup/
```

用于保存原始运行时文件。

> Dream Skin 更新到新版本后，不建议绕过版本检查。应先重新验证运行时结构、DOM 选择器和视觉覆盖，再提升兼容版本。

### MacOS ：一键安装完整主题

先安装并启动 Codex Dream Skin 1.5.19，然后直接双击 根目录macos文件夹内：

```text
Install-Takemi-Theme.command
```
### 🍎 macOS 安装问题解决方法

如果双击 `Install-Takemi-Theme.command` 时，提示**「没有正确的访问权限」**或 `Permission denied`，请按照以下步骤操作。

**第一步：给安装文件添加运行权限**

1. 打开 Mac 自带的「终端」（Terminal）。

2. 复制下面的命令，粘贴到终端：

   `chmod +x`

3. 在命令末尾按一次**空格键**。

4. 从 Finder 中找到 `Install-Takemi-Theme.command`，**用鼠标将它拖进终端窗口**。

5. 按下 **Enter（回车键）**。

终端没有显示任何内容或报错，就是正常现象，说明权限设置成功。

**第二步：启动安装**

返回 Finder，直接**双击 `Install-Takemi-Theme.command`**，即可启动主题安装程序。

如果希望直接从终端启动，也可以再次把该文件拖入终端，然后按回车。

✅ **只需设置一次权限，以后通常可以直接双击运行，无需重复操作。**

*注意：请仅运行从可信来源下载的安装文件。若系统出现开发者安全验证提示，则需要按照 macOS 的安全提示另行处理。*


安装器会自动备份运行时、安装主题、立即应用并验证结果。

终端方式：

```bash
./macos/apply-takemi-runtime-macos.sh --screenshot ./macos/local-evidence/takemi.png
```

只检查兼容性而不写入：

```bash
./macos/apply-takemi-runtime-macos.sh --dry-run
```

恢复 Dream Skin 原始运行时、但保留基础武见妙主题：

```bash
./macos/restore-takemi-runtime-macos.sh
```

## 当前兼容状态

| 项目 | 状态 |
| --- | --- |
| 主题版本 | `v1.0` |
| Windows 完整运行时主题 | ✅ Dream Skin `1.5.19` 已验证 |
| Windows 基础主题 ZIP | ✅ |
| macOS 基础主题 ZIP | ✅ |
| macOS 完整运行时主题 | ✅ 已完成 |


## 更新与恢复

- 更新主题前建议保留当前可用版本。
- `apply-takemi-runtime.ps1` 首次运行时会备份被修改的 Dream Skin 运行时文件至 `runtime-backup/`。
- Dream Skin 主版本更新后，应重新适配并验证主题补丁，而不是直接沿用旧版本补丁。
- 如果完整运行时主题出现兼容问题，可以先恢复 / 重装原版 Dream Skin，再使用基础主题 ZIP。

## 技术与安全

- 本主题不会修改官方 Codex Desktop 二进制文件。
- 不修改官方应用签名、`WindowsApps` 权限或 `app.asar`。
- 完整 Windows 方案修改的是 Dream Skin 位于 `%LOCALAPPDATA%\CodexDreamSkin` 下的本地运行时副本。
- 运行时补丁会在修改前保存原始文件备份。
- Dream Skin 使用本机回环 CDP 与 Codex 渲染器交互；回环地址并不等同于身份认证。
- 关于 CDP、主题 ZIP、Safe CSS、文件校验与本地运行时的完整安全边界，请参阅上游 [`SECURITY.md`](./SECURITY.md)。

## 开发与维护

主题当前主要由以下三部分组成：

### 基础主题

[`p5r-tae-takemi-ethy-theme/`](./p5r-tae-takemi-ethy-theme/)

### P5R 完整视觉覆盖

[`takemi-runtime-override.css`](./takemi-runtime-override.css)

### Windows 运行时补丁

[`apply-takemi-runtime.ps1`](./apply-takemi-runtime.ps1)

## 许可与声明

- 本项目基于 [Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin) 开发，并保留原项目的 MIT 许可证与作者信息。
- 非 OpenAI 官方产品；Codex 及相关权利归其权利人。
- 《Persona 5 Royal》、武见妙及相关角色名称、形象、素材与商标权利归其各自权利人。
- 本主题属于非官方粉丝创作，本仓库不授予对相关角色素材的商业使用权。

## 致谢

- 原始项目：[Fei-Away/Codex-Dream-Skin](https://github.com/Fei-Away/Codex-Dream-Skin)
