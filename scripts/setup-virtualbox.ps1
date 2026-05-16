# setup-virtualbox.ps1
# Ejecutar como Administrador
# Configura VirtualBox y crea las redes necesarias

$env:PATH += ";C:\Program Files\Oracle\VirtualBox"

Write-Host "=== Instalando VirtualBox ===" -ForegroundColor Cyan
winget install Oracle.VirtualBox

Write-Host "`n=== Creando red NAT (WAN) ===" -ForegroundColor Cyan
VBoxManage natnetwork add --netname "Red_WAN" --network "10.0.2.0/24" --enable --dhcp on

Write-Host "`n=== Creando carpetas para ISOs y discos ===" -ForegroundColor Cyan
New-Item -ItemType Directory -Path "C:\VMs\ISOs"   -Force
New-Item -ItemType Directory -Path "C:\VMs\Discos" -Force

Write-Host "`nListo. Ahora descarga manualmente:" -ForegroundColor Yellow
Write-Host "  pfSense : https://www.pfsense.org/download/"
Write-Host "  Ubuntu  : https://releases.ubuntu.com/22.04/"
Write-Host "  Kali    : https://www.kali.org/get-kali/"
Write-Host "Guardalos en C:\VMs\ISOs\"
