@echo off
setlocal EnableExtensions

rem ============================================================
rem  DeepSeek Harness one-command installer
rem
rem  1) Downloads the launcher and icon into %USERPROFILE%\DeepSeekHarness
rem  2) Deploys @deepseek-ai/dsh there with npm (local, fast startup)
rem  3) Creates the "DeepSeek Harness" desktop shortcut
rem
rem  Usage (single line, in cmd.exe):
rem    curl -fsSL "https://raw.githubusercontent.com/kevincat0000-cmyk/DeepSeekHarness/main/install.cmd" -o "%TEMP%\dsh-install.cmd" && call "%TEMP%\dsh-install.cmd"
rem ============================================================

set "BASE=https://raw.githubusercontent.com/kevincat0000-cmyk/DeepSeekHarness/main"
set "DIR=%USERPROFILE%\DeepSeekHarness"

rem -- 0) Node.js and npm are required. --
set "NODE="
for /f "delims=" %%I in ('where node.exe 2^>nul') do if not defined NODE set "NODE=%%I"
if not defined NODE if exist "%ProgramFiles%\nodejs\node.exe" set "NODE=%ProgramFiles%\nodejs\node.exe"
if not defined NODE if exist "%ProgramFiles(x86)%\nodejs\node.exe" set "NODE=%ProgramFiles(x86)%\nodejs\node.exe"
if not defined NODE if exist "%LOCALAPPDATA%\Programs\nodejs\node.exe" set "NODE=%LOCALAPPDATA%\Programs\nodejs\node.exe"
if not defined NODE (
  echo [error] Node.js was not found.
  echo         Install it from https://nodejs.org/ and try again.
  pause
  exit /b 1
)
set "NPM="
for /f "delims=" %%I in ('where npm.cmd 2^>nul') do if not defined NPM set "NPM=%%I"
if not defined NPM if not exist "%NODE:~0,-8%node_modules\npm\bin\npm-cli.js" (
  echo [error] npm was not found. Reinstall Node.js and try again.
  pause
  exit /b 1
)

rem -- 1) Download launcher + icon. --
if not exist "%DIR%" mkdir "%DIR%"
echo [1/3] Downloading launcher and icon...
call :download "%BASE%/Start-DeepSeek-Harness.cmd" "%DIR%\Start-DeepSeek-Harness.cmd"
if errorlevel 1 goto :dlfail
call :download "%BASE%/DeepSeek-Harness.ico" "%DIR%\DeepSeek-Harness.ico"
if errorlevel 1 goto :dlfail

rem -- 2) Deploy @deepseek-ai/dsh locally. --
echo [2/3] Deploying @deepseek-ai/dsh...
if defined NPM (
  call "%NPM%" install --prefix "%DIR%" @deepseek-ai/dsh --no-audit --no-fund
) else (
  "%NODE%" "%NODE:~0,-8%node_modules\npm\bin\npm-cli.js" install --prefix "%DIR%" @deepseek-ai/dsh --no-audit --no-fund
)
if errorlevel 1 (
  echo [error] npm install failed. Check your network and try again.
  pause
  exit /b 1
)

rem -- 3) Desktop shortcut (keep a custom icon if present). --
echo [3/3] Creating desktop shortcut...
set "ICON=%DIR%\DeepSeek-Harness.ico"
if exist "%DIR%\DeepSeek-Harness-custom.ico" set "ICON=%DIR%\DeepSeek-Harness-custom.ico"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Desktop')+'\DeepSeek Harness.lnk'); $s.TargetPath='%DIR%\Start-DeepSeek-Harness.cmd'; $s.WorkingDirectory='%DIR%'; $s.IconLocation='%ICON%,0'; $s.Description='DeepSeek Harness'; $s.Save()"
if errorlevel 1 (
  echo [error] Failed to create the desktop shortcut.
  pause
  exit /b 1
)

echo.
echo Done. Double-click "DeepSeek Harness" on your desktop to start.
echo Installed in: %DIR%
exit /b 0

:dlfail
echo [error] Download failed. Check your network and try again.
pause
exit /b 1

:download
rem %1 = URL, %2 = output file
where curl.exe >nul 2>&1
if errorlevel 1 goto :dl_ps
curl -fsSL "%~1" -o "%~2"
exit /b %errorlevel%

:dl_ps
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing '%~1' -OutFile '%~2'"
exit /b %errorlevel%
