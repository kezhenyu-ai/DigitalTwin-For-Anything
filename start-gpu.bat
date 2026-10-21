@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "EDGE=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"

echo [Binhe Digital Twin] Checking local server on port 5173...
powershell -NoProfile -Command "try { $c = New-Object Net.Sockets.TcpClient; $c.Connect('127.0.0.1',5173); $c.Close(); exit 0 } catch { exit 1 }"
if errorlevel 1 (
  echo [Binhe Digital Twin] Starting Vite dev server...
  start "Binhe Digital Twin Server" cmd /k "npm run dev"
  timeout /t 4 /nobreak >nul
)

set "BROWSER=%~1"
if /i "%BROWSER%"=="chrome" goto :chrome
if /i "%BROWSER%"=="edge" goto :edge

for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice' -ErrorAction SilentlyContinue).ProgId"`) do set "DEFAULT_PROGID=%%I"
if /i "%DEFAULT_PROGID%"=="ChromeHTML" goto :chrome
goto :edge

:chrome
if exist "%CHROME%" (
  echo [Binhe Digital Twin] Launching Chrome with Vulkan hardware rendering...
  start "" "%CHROME%" --use-angle=vulkan --enable-gpu --ignore-gpu-blocklist --force_high_performance_gpu --enable-gpu-rasterization --disable-gpu-sandbox --no-first-run --no-default-browser-check --user-data-dir="%LOCALAPPDATA%\BinheTwinChrome" --new-window "http://127.0.0.1:5173/"
  goto :end
)
echo [Binhe Digital Twin] Chrome not found, falling back to Edge.
goto :edge

:edge
if exist "%EDGE%" (
  echo [Binhe Digital Twin] Launching Edge with Vulkan hardware rendering...
  start "" "%EDGE%" --use-angle=vulkan --enable-gpu --ignore-gpu-blocklist --force_high_performance_gpu --enable-gpu-rasterization --disable-gpu-sandbox --no-first-run --no-default-browser-check --user-data-dir="%LOCALAPPDATA%\BinheTwinEdge" --new-window "http://127.0.0.1:5173/"
  goto :end
)

echo [Binhe Digital Twin] Edge/Chrome not found, opening the default browser.
start "" "http://127.0.0.1:5173/"

:end
endlocal
