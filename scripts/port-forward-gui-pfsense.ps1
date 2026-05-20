# port-forward-gui-pfsense.ps1
# Crea el port forward que permite acceder al GUI de pfSense desde el navegador
# del host Windows (https://127.0.0.1:8443 -> pfSense WAN:443).
#
# Uso:
#   .\scripts\port-forward-gui-pfsense.ps1 10.0.2.4
#
# El argumento es la IP WAN actual de pfSense (sale en el menu principal de
# la consola pfSense: "WAN -> em0 -> v4/DHCP4: 10.0.2.X/24").
#
# Si pfSense reinicia y recibe otra IP por DHCP, vuelve a correr este script
# con la IP nueva. Borra el anterior y crea uno nuevo.

param(
    [Parameter(Mandatory=$true)] [string]$IPpfSense
)

$env:PATH += ";C:\Program Files\Oracle\VirtualBox"
$RED = "Red_WAN"
$REGLA = "pf-gui"

Write-Host "=== Borrando regla anterior si existe ===" -ForegroundColor Cyan
VBoxManage natnetwork modify --netname $RED --port-forward-4 delete $REGLA 2>&1 | Out-Null

Write-Host "`n=== Creando port forward $REGLA -> $IPpfSense:443 ===" -ForegroundColor Cyan
VBoxManage natnetwork modify --netname $RED --port-forward-4 "${REGLA}:tcp:[127.0.0.1]:8443:[${IPpfSense}]:443"

Write-Host "`n=== Port forwards activos en $RED ===" -ForegroundColor Green
VBoxManage natnetwork list | Select-String "Name|tcp"

Write-Host "`nListo. Abre el navegador en: https://127.0.0.1:8443" -ForegroundColor Yellow
Write-Host "Login default: admin / pfsense"
