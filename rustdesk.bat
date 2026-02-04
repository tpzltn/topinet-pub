@echo off

REM ############################### Please Do Not Edit Below This Line #########################################

if not exist C:\Temp\ md C:\Temp\
cd /d C:\Temp\

:: 1) Letöltés (verzió-pinnelt)
curl -L "https://github.com/rustdesk/rustdesk/releases/download/1.4.5/rustdesk-1.4.5-x86_64.exe" -o rustdesk.raw.exe

:: 2) ÁTNEVEZÉS a generált, kódolt fájlnévre
set "RD_NAM=rustdesk--0nIw9GduQXZulGcvRnLl12boJiOikXYsVmciwiIiojIpBXYiwiI9E1MNJ2TBdjRwYkaHhjdxUGWMJVWBJmQv50dpVjUyxmVMJGcMZlS2p3dhJnI6ISeltmIsICcvRnL0VmbpB3b05SZt9GaiojI0N3boJye--.exe"
ren "rustdesk.raw.exe" "%RD_NAM%"

:: 3) Csendes telepítés (helyes kapcsoló)
start /wait "" "%RD_NAM%" --silent-install

echo KÉSZ.
