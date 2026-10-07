@echo off
setlocal EnableExtensions
title P5R Tae Takemi Theme Installer

pushd "%~dp0"

set "PS1=%~dp0apply-takemi-runtime.ps1"
set "POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

echo.
echo ==========================================
echo   P5R Tae Takemi Theme Installer - v1.0
echo ==========================================
echo.
echo Checking installer files...

if not exist "%PS1%" goto :missing_ps1

if exist "%POWERSHELL%" goto :run_installer

where pwsh.exe >nul 2>nul
if errorlevel 1 goto :missing_powershell
set "POWERSHELL=pwsh.exe"

:run_installer
echo.
echo Installing the full Windows theme...
echo Target runtime: Codex Dream Skin 1.5.19
echo.
echo The installer will verify the runtime version and create a backup
echo before changing Dream Skin runtime files.
echo.

"%POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
set "EXITCODE=%ERRORLEVEL%"

echo.
if not "%EXITCODE%"=="0" goto :install_failed

echo ==========================================
echo   Installation complete
echo ==========================================
echo.
echo Next steps:
echo   1. Open the Dream Skin tray menu.
echo   2. Open Saved Themes.
echo   3. Select: P5R - Tae Takemi - ethy
echo   4. Restart or refresh Codex.
echo.
pause
popd
exit /b 0

:missing_ps1
echo.
echo ==========================================
echo   Installation failed
echo ==========================================
echo.
echo apply-takemi-runtime.ps1 was not found.
echo Keep this BAT file in the repository root.
echo.
pause
popd
exit /b 1

:missing_powershell
echo.
echo ==========================================
echo   Installation failed
echo ==========================================
echo.
echo Windows PowerShell and pwsh.exe were not found.
echo Install or enable PowerShell, then run this installer again.
echo.
pause
popd
exit /b 9009

:install_failed
echo ==========================================
echo   Installation failed
echo ==========================================
echo.
echo Exit code: %EXITCODE%
echo Review the error message above.
echo If Dream Skin is not version 1.5.19, the installer will stop by design.
echo.
pause
popd
exit /b %EXITCODE%
