@echo off
setlocal

echo.
set /p rustdesk_cfg=Masold be a RustDesk konfiguracios kodot:
echo.

if "%rustdesk_cfg%"=="" (
    echo Nem adtal meg konfiguracios kodot.
    pause
    exit /b 1
)

if not exist C:\Temp md C:\Temp
cd /d C:\Temp

echo Legujabb RustDesk verzio lekerese...

for /f "delims=" %%i in ('powershell -command "(Invoke-RestMethod https://api.github.com/repos/rustdesk/rustdesk/releases/latest).tag_name"') do set VERSION=%%i

if "%VERSION%"=="" (
    echo Nem sikerult lekerdezni a legujabb verziot.
    pause
    exit /b 1
)

echo Letoltes: %VERSION%

curl -L "https://github.com/rustdesk/rustdesk/releases/download/%VERSION%/rustdesk-%VERSION%-x86_64.exe" -o rustdesk.exe

if errorlevel 1 (
    echo Hiba a letoltes soran.
    pause
    exit /b 1
)

echo Konfiguracio alkalmazasa...

start "" rustdesk.exe --config "%rustdesk_cfg%"

timeout /t 5 /nobreak >nul

for /f "delims=" %%i in ('rustdesk.exe --get-id') do set rustdesk_id=%%i

start "" rustdesk.exe

echo.
echo ==========================================
echo RustDesk verzio: %VERSION%
echo RustDesk ID: %rustdesk_id%
echo ==========================================
echo.

pause
