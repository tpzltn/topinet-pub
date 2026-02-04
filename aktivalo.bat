echo "Windows 11 aktiválás"
slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
slmgr /skms kms.topinet.top:16880
slmgr /ato
echo "Kérem várjon amíg aktiválódik a Windows..."
pause

echo "Office 2024 aktiválás"
set /p nev="Kérem adja meg a számítógép nevét: "

cd C:\Program Files\Microsoft Office\Office16
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /inpkey:XJ2XN-FW8RK-P4HMP-DKDBV-GCVGB %nev%
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /sethst:kms.topinet.top
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /setprt:16880
cscript "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act
Echo "Az aktiválás sikeres volt"
Pause
