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

curl -L "https://github.com/rustdesk/rustdesk/releases/download/1.4.9/rustdesk-1.4.9-x86_64.exe" -o rustdesk.exe

rustdesk.exe --silent-install

timeout /t 20 /nobreak

for /f "delims=" %%i in ('rustdesk.exe --get-id ^| more') do set rustdesk_id=%%i

rustdesk.exe --config "%rustdesk_cfg%"

echo.
echo ==========================================
echo RustDesk ID: %rustdesk_id%
echo ==========================================
echo.

pause
