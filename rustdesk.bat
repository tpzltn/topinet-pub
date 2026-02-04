@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ================================
:: RustDesk Telepítő + Auto Config
:: ================================
:: HBBS/HBBR/KEY - BEÁLLÍTÁSOK
set "HBBS=home.topinet.top"
set "HBBR=home.topinet.top"
set "KEY=rawzvJVLpbLVlrR5iwNoBbAYRLXe1v8GjF0F7AObM3Q="

:: LOG HELY
set "LOGDIR=%ProgramData%\RustDesk"
set "LOGFILE=%LOGDIR%\install_fix.log"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

call :log ---- RustDesk telepítés + konfiguráció indul ----

:: --- Admin ellenőrzés ---
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    call :log Nincs admin jog - újraindítás admin módban...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: --- Letöltési útvonal ---
set "TMPFILE=%TEMP%\rustdesk-install.exe"
set "URL=https://github.com/rustdesk/rustdesk/releases/download/1.4.5/rustdesk-1.4.5-x86_64.exe"

call :log Telepítő letöltése: %URL%

:: Letöltés PowerShell-lel, ha elérhető
where powershell >nul 2>&1
if %errorlevel% EQU 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%URL%' -OutFile '%TMPFILE%' -UseBasicParsing } catch { exit 1 }"
    if %errorlevel% NEQ 0 (
        call :log HIBA: A letöltés PowerShell-lel nem sikerült.
        goto :trycurl
    ) else (
        goto :install
    )
)

:trycurl
:: Curl fallback (Win10+)
where curl >nul 2>&1
if %errorlevel% EQU 0 (
    curl -L -o "%TMPFILE%" "%URL%"
    if %errorlevel% NEQ 0 (
        call :log HIBA: A letöltés curl-lal sem sikerült.
        goto :trybits
    ) else (
        goto :install
    )
)

:trybits
:: BITSADMIN fallback (legacy)
where bitsadmin >nul 2>&1
if %errorlevel% EQU 0 (
    bitsadmin /transfer "rdl" /priority FOREGROUND "%URL%" "%TMPFILE%"
    if %errorlevel% NEQ 0 (
        call :log HIBA: A letöltés BITSADMIN-nal sem sikerült.
        call :log Megszakítva.
        exit /b 1
    )
) else (
    call :log Nincs elérhető letöltési módszer. Megszakítva.
    exit /b 1
)

:install
if not exist "%TMPFILE%" (
    call :log HIBA: A telepítő fájl nem található: %TMPFILE%
    exit /b 1
)

call :log Silent install indul...
start /wait "" "%TMPFILE%" /silent
if %errorlevel% NEQ 0 (
    call :log HIBA: A RustDesk telepítés nem sikerült. Kód: %errorlevel%
    :: Megpróbáljuk a konfigurációs javítást akkor is
) else (
    call :log RustDesk telepítés kész.
)

:: --- Registry beállítások ---
call :log Registry beállítások írása...
reg add "HKLM\SOFTWARE\RustDesk" /v "IDServer"    /t REG_SZ /d "%HBBS%" /f >nul
reg add "HKLM\SOFTWARE\RustDesk" /v "RelayServer" /t REG_SZ /d "%HBBR%" /f >nul
reg add "HKLM\SOFTWARE\RustDesk" /v "Key"         /t REG_SZ /d "%KEY%"  /f >nul

:: --- Szolgáltatás újraindítása (névtűrés) ---
call :restart_service

call :log KÉSZ: Telepítés + konfiguráció sikeresen lefutott.
echo.
echo *** KÉSZ *** A RustDesk telepítve és konfigurálva lett.
echo A napló itt: %LOGFILE%
exit /b 0

:: --------- Segédfüggvények ---------
:log
set "_now="
for /f "tokens=1-3 delims=:. " %%a in ("%time%") do set "_now=%%a:%%b:%%c"
echo [%date% %_now%] %*>> "%LOGFILE%"
echo %*
exit /b

:restart_service
call :log RustDesk szolgáltatás újraindítása...
:: Többféle néven fordul elő: "RustDesk", "rustdesk", "RustDesk Service"
for %%S in ("RustDesk" "rustdesk" "RustDesk Service") do (
    sc query "%%~S" >nul 2>&1
    if !errorlevel! EQU 0 (
        call :log Szolgáltatás megtalálva: %%~S - újraindítás...
        net stop  "%%~S" /y >nul 2>&1
        net start "%%~S"    >nul 2>&1
        if !errorlevel! EQU 0 (
            call :log Szolgáltatás újraindítva: %%~S
            exit /b
        )
    )
)
:: Ha nem szolgáltatásból fut, folyamat újraindítás
taskkill /IM rustdesk.exe /F >nul 2>&1
start "" "%ProgramFiles%\RustDesk\rustdesk.exe"
call :log Folyamat újraindítva (ha volt).
exit /b
