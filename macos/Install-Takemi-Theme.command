#!/bin/bash

set -u

TAKEMI_ROOT="$(cd "$(dirname "$0")" && pwd -P)"
INSTALLER="$TAKEMI_ROOT/apply-takemi-runtime-macos.sh"

clear
printf '%s\n' '============================================'
printf '%s\n' ' P5R · Tae Takemi · macOS Theme Installer'
printf '%s\n' '============================================'
printf '\n'

if [ "$(/usr/bin/uname -s)" != "Darwin" ]; then
  printf '错误：此安装器只能在 macOS 上运行。\n' >&2
  status=1
elif [ ! -d "$HOME/.codex/codex-dream-skin-studio" ]; then
  printf '错误：尚未安装 Codex Dream Skin。\n' >&2
  printf '请先安装并启动 Codex Dream Skin 1.5.20，再双击本文件。\n' >&2
  status=1
elif [ ! -f "$INSTALLER" ]; then
  printf '错误：macOS 安装脚本缺失，请重新下载完整主题文件夹。\n' >&2
  status=1
else
  printf '正在安装并应用武见妙完整主题，请稍候…\n\n'
  /bin/bash "$INSTALLER"
  status=$?
fi

printf '\n'
if [ "$status" -eq 0 ]; then
  printf '✅ 安装完成：武见妙主题已应用到 Codex Dream Skin。\n'
else
  printf '❌ 安装未完成，请查看上方错误信息。\n' >&2
fi

printf '\n按回车键关闭窗口…'
IFS= read -r _
exit "$status"
