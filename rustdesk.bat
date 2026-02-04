@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ================================
:: RustDesk Telepítő + Auto Config
:: ================================
set "HBBS=home.topinet.top"
set "HBBR=home.topinet.top"
set "KEY=rawzvJVLpbLVlrR5iwNoBbAYRLXe1v8GjF0F7AObM3Q="

:: Random jelszó (12)
set "alfanum=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
set "rustdesk_pw="
for /L %%b in (1,1,12) do (
  set /A rnd_num=!RANDOM! %% 62
  for %%c in (!rnd_num!) do set "rustdesk_pw=!rustdesk_pw!!alfanum:~%%c,1!"
)

:: Log
set "LOGDIR=%ProgramData%\RustDesk"
set "LOGFILE=%LOGDIR%\install_fix.log"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
call :log ---- RustDesk telepítés + konfiguráció indul ----

:: Admin ellenőrzés
net session >nul 2>&1
if %errorlevel% NEQ 0 (
  call :log Nincs admin jog - újraindítás admin módban...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

:: Letöltés (latest x86_64 EXE; hivatalos silent kapcsoló: --silent-install)
set "URL=https://github.com/rustdesk/rustdesk/releases/download/1.4.5/rustdesk-1.4.5-x86_64.exe"
set "TMPFILE=%TEMP%\rustdesk-install.exe"
call :log Letöltés: %URL%
where powershell >nul 2>&1 && (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%URL%' -OutFile '%TMPFILE%' -UseBasicParsing } catch { exit 1 }"
  if %errorlevel% NEQ 0 call :trycurl
) || call :trycurl

if not exist "%TMPFILE%" (
  call :log HIBA: Telepítő nem található: %TMPFILE%
  exit /b 1
)

:: Silent install (HELYES kapcsoló)
call :log Silent telepítés indul...
start /wait "" "%TMPFILE%" --silent-install
if %errorlevel% NEQ 0 call :log FIGYELEM: Telepítés hibakód: %errorlevel%

:: Telepített bináris helye
set "RD_EXE=%ProgramFiles%\RustDesk\rustdesk.exe"
if not exist "%RD_EXE%" set "RD_EXE=%ProgramFiles(x86)%\RustDesk\rustdesk.exe"

if not exist "%RD_EXE%" (
  call :log HIBA: A rustdesk.exe nem található az alaphely(ek)en.
  :: megpróbáljuk mégis beállítani registry-vel és kilépünk
  goto :write_registry
)

:: Konfiguráció (dokumentált CLI módszer: host + key)
call :log Szerver beállítás alkalmazása CLI-vel...
"%RD_EXE%" --config "host=%HBBS%,key=%KEY%"

:: (Opcionális) Relay kifejezetten registry-be (stabilitás kedvéért)
:write_registry
reg add "HKLM\SOFTWARE\RustDesk" /v "IDServer"    /t REG_SZ /d "%HBBS%" /f >nul
reg add "HKLM\SOFTWARE\RustDesk" /v "RelayServer" /t REG_SZ /d "%HBBR%" /f >nul
reg add "HKLM\SOFTWARE\RustDesk" /v "Key"         /t REG_SZ /d "%KEY%"  /f >nul

:: Jelszó beállítás
if exist "%RD_EXE%" (
  call :log Unattended jelszó beállítása...
  "%RD_EXE%" --password "%rustdesk_pw%"
)

:: Szolgáltatás telepítése + újraindítás
if exist "%RD_EXE%" (
  call :log Szolgáltatás telepítése/újratelepítése...
  "%RD_EXE%" --install-service"
)
call :restart_service

:: ID kiolvasása (ha elérhető)
set "rustdesk_id="
if exist "%RD_EXE%" (
  for /f "delims=" %%i in ('"%RD_EXE%" --get-id ^| more') do set "rustdesk_id=%%i"
)

echo.
echo ...............................................
echo RustDesk ID: %rustdesk_id%
echo Password:    %rustdesk_pw%
echo ...............................................
call :log KÉSZ: Telepítés + konfiguráció befejezve.
exit /b 0

:: ------- Segédfüggvények -------
:trycurl
where curl >nul 2>&1 && (curl -L -o "%TMPFILE%" "%URL%") || (call :log HIBA: Letöltés sikertelen (nincs PowerShell/curl). & exit /b 1)
exit /b

:log
set "_now="
for /f "tokens=1-3 delims=:. " %%a in ("%time%") do set "_now=%%a:%%b:%%c"
echo [%date% %_now%] %*>> "%LOGFILE%"
echo %*
exit /b

:restart_service
call :log Szolgáltatás újraindítása...
for %%S in ("RustDesk" "rustdesk" "RustDesk Service") do (
  sc query "%%~S" >nul 2>&1
  if !errorlevel! EQU 0 (
    net stop  "%%~S" /y >nul 2>&1
    net start "%%~S"    >nul 2>&1
    if !errorlevel! EQU 0 (call :log Szolgáltatás újraindítva: %%~S & exit /b)
  )
)
:: ha nincs service, folyamat újraindítás
taskkill /IM rustdesk.exe /F >nul 2>&1
if exist "%RD_EXE%" start "" "%RD_EXE%"
call :log Folyamat indítva (ha szükséges).
exit /b
