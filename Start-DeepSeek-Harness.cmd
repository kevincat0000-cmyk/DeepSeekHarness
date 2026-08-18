@echo off
setlocal EnableExtensions

rem ============================================================
rem  DeepSeek Harness launcher
rem  Starts the dsh web server (if not already running) and then
rem  opens http://127.0.0.1:3080/ in the default browser.
rem ============================================================

set "URL=http://127.0.0.1:3080/"
set "NODE=D:\node.exe"
set "NPX_CLI=D:\node_modules\npm\bin\npx-cli.js"
set "DSH_BIN=C:\Users\Kevincat\AppData\Local\npm-cache\_npx\1e7f6d9597241db0\node_modules\@deepseek-ai\dsh\lib\bin.js"

rem -- 1) Already running? Just open the browser. --
netstat -ano | findstr /R /C:":3080 .*LISTENING" >nul 2>&1
if not errorlevel 1 goto open

rem -- 2) Start the server in its own minimized window. --
if exist "%DSH_BIN%" (
  start "DeepSeek Harness Server" /min /D "%USERPROFILE%" "%NODE%" "%DSH_BIN%" web
) else (
  start "DeepSeek Harness Server" /min /D "%USERPROFILE%" "%NODE%" "%NPX_CLI%" --yes @deepseek-ai/dsh web
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
