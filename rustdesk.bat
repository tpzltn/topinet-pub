@echo off


REM Get your config string from your Web portal and Fill Below
set rustdesk_cfg="0nIw9GduQXZulGcvRnLl12boJiOikXYsVmciwiIiojIpBXYiwiI9E1MNJ2TBdjRwYkaHhjdxUGWMJVWBJmQv50dpVjUyxmVMJGcMZlS2p3dhJnI6ISeltmIsICcvRnL0VmbpB3b05SZt9GaiojI0N3boJye"

REM ############################### Please Do Not Edit Below This Line #########################################

if not exist C:\Temp\ md C:\Temp\
cd C:\Temp\

curl -L "https://github.com/rustdesk/rustdesk/releases/download/1.4.9/rustdesk-1.4.9-x86_64.exe" -o rustdesk.exe

rustdesk.exe --silent-install
timeout /t 20


for /f "delims=" %%i in ('rustdesk.exe --get-id ^| more') do set rustdesk_id=%%i

rustdesk.exe --config %rustdesk_cfg%

echo ...............................................
REM Show the value of the ID Variable
echo RustDesk ID: %rustdesk_id%

echo ...............................................
