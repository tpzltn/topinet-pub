echo "Windows 11 aktiválás"
slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
slmgr /skms 192.168.1.10:16880
slmgr /ato
echo "Kérem várjon amíg aktiválódik a Windows..."
pause
slmgr /skms topinet.top:16880

echo "Office 2024 aktiválás"
set /p nev="Kérem adja meg a számítógép nevét: "

cd C:\Program Files\Microsoft Office\Office16
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /inpkey:XJ2XN-FW8RK-P4HMP-DKDBV-GCVGB %nev%
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /sethst:192.168.1.10
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /setprt:16880
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /sethst:topinet.top
Echo "Az aktiválás sikeres volt"
Pause
