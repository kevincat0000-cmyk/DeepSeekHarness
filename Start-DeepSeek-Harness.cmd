@echo off
setlocal EnableExtensions

rem ============================================================
rem  DeepSeek Harness launcher
rem  Starts the dsh web server (if not already running) and then
rem  opens http://127.0.0.1:3080/ in the default browser.
rem ============================================================

set "URL=http://127.0.0.1:3080/"
set "DIR=%~dp0"

rem -- Locate Node.js: PATH first, then common install locations. --
set "NODE="
for /f "delims=" %%I in ('where node.exe 2^>nul') do if not defined NODE set "NODE=%%I"
if not defined NODE if exist "%ProgramFiles%\nodejs\node.exe" set "NODE=%ProgramFiles%\nodejs\node.exe"
if not defined NODE if exist "%ProgramFiles(x86)%\nodejs\node.exe" set "NODE=%ProgramFiles(x86)%\nodejs\node.exe"
if not defined NODE if exist "%LOCALAPPDATA%\Programs\nodejs\node.exe" set "NODE=%LOCALAPPDATA%\Programs\nodejs\node.exe"
if not defined NODE (
  echo Node.js was not found. Install it from https://nodejs.org/ first.
  pause
  exit /b 1
)

rem -- Locate npx (fallback when dsh is not deployed locally). --
set "NPX="
for /f "delims=" %%I in ('where npx.cmd 2^>nul') do if not defined NPX set "NPX=%%I"
if not defined NPX if exist "%NODE:~0,-8%node_modules\npm\bin\npx-cli.js" set "NPX=%NODE:~0,-8%node_modules\npm\bin\npx-cli.js"

rem -- Prefer the locally deployed package (see install.cmd). --
set "DSH_BIN=%DIR%node_modules\@deepseek-ai\dsh\lib\bin.js"
if not exist "%DSH_BIN%" set "DSH_BIN="

rem -- 1) Already running? Just open the browser. --
netstat -ano | findstr /R /C:":3080 .*LISTENING" >nul 2>&1
if not errorlevel 1 goto open

rem -- 2) Start the server in its own minimized window. --
if defined DSH_BIN (
  start "DeepSeek Harness Server" /min /D "%DIR%" "%NODE%" "%DSH_BIN%" web
) else if defined NPX (
  start "DeepSeek Harness Server" /min /D "%DIR%" "%NPX%" --yes @deepseek-ai/dsh web
) else (
  echo Neither the local dsh package nor npx was found.
  echo Re-run install.cmd, or install npm and try again.
  pause
  exit /b 1
)

rem -- 3) Wait for the port to come up (max 90 s). --
set tries=0
:wait
timeout /t 1 /nobreak >nul
netstat -ano | findstr /R /C:":3080 .*LISTENING" >nul 2>&1
if not errorlevel 1 goto open
set /a tries+=1
if %tries% lss 90 goto wait
echo DeepSeek Harness did not come up within 90 seconds.
echo Check the "DeepSeek Harness Server" window for details.

:open
start "" "%URL%"
exit /b 0
