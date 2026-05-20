# crear-vms.ps1
# Ejecutar DESPUES de setup-virtualbox.ps1 y de tener las ISOs en C:\VMs\ISOs\
#
# Topologia de red que crea este script:
#
#                  NAT Network "Red_WAN" (10.0.2.0/24)
#                  /                                 \
#         pfSense WAN (em0)                        Kali (eth0)
#               |
#         pfSense LAN  (em1) <----- intnet "lan-net" -----> Servidor-LAN
#         pfSense OPT1 (em2) <----- intnet "dmz-net" -----> Servidor-Web-DMZ

$env:PATH += ";C:\Program Files\Oracle\VirtualBox"

function Crear-VM {
    param($Nombre, $OS, $RAM, $DiscoPath, $ISO, $Red, $TipoRed)
    Write-Host "`n[+] Creando VM: $Nombre" -ForegroundColor Cyan
    VBoxManage createvm --name $Nombre --ostype $OS --register
    VBoxManage modifyvm $Nombre --memory $RAM --cpus 1 --vram 16
    VBoxManage modifyvm $Nombre --boot1 dvd --boot2 disk
    VBoxManage createhd --filename $DiscoPath --size 15360 --format VDI
    VBoxManage storagectl $Nombre --name "SATA" --add sata --controller IntelAhci
    VBoxManage storageattach $Nombre --storagectl "SATA" --port 0 --device 0 --type hdd --medium $DiscoPath
    VBoxManage storagectl $Nombre --name "IDE" --add ide
    VBoxManage storageattach $Nombre --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium $ISO
    switch ($TipoRed) {
        "intnet"     { VBoxManage modifyvm $Nombre --nic1 intnet --intnet1 $Red }
        "natnetwork" { VBoxManage modifyvm $Nombre --nic1 natnetwork --nat-network1 $Red }
        default      { VBoxManage modifyvm $Nombre --nic1 nat }
    }
    Write-Host "[OK] $Nombre creada." -ForegroundColor Green
}

# pfSense (3 interfaces de red)
# - WAN  en NAT Network Red_WAN  (compartida con Kali, asi Kali puede atacarla)
# - LAN  en red interna lan-net
# - OPT1 en red interna dmz-net
VBoxManage createvm --name "pfSense-Firewall" --ostype "FreeBSD_64" --register
VBoxManage modifyvm "pfSense-Firewall" --memory 512 --cpus 1 --vram 16 --boot1 dvd --boot2 disk
VBoxManage createhd --filename "C:\VMs\Discos\pfsense.vdi" --size 10240 --format VDI
VBoxManage storagectl "pfSense-Firewall" --name "SATA" --add sata --controller IntelAhci
VBoxManage storageattach "pfSense-Firewall" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "C:\VMs\Discos\pfsense.vdi"
VBoxManage storagectl "pfSense-Firewall" --name "IDE" --add ide
VBoxManage storageattach "pfSense-Firewall" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "C:\VMs\ISOs\pfsense.iso"
VBoxManage modifyvm "pfSense-Firewall" --nic1 natnetwork --nat-network1 "Red_WAN"
VBoxManage modifyvm "pfSense-Firewall" --nic2 intnet --intnet2 "lan-net"
VBoxManage modifyvm "pfSense-Firewall" --nic3 intnet --intnet3 "dmz-net"

# Servidor Web DMZ - en red interna dmz-net
Crear-VM -Nombre "Servidor-Web-DMZ" -OS "Ubuntu_64" -RAM 1024 `
    -DiscoPath "C:\VMs\Discos\servidor-web.vdi" `
    -ISO "C:\VMs\ISOs\ubuntu-server.iso" `
    -Red "dmz-net" -TipoRed "intnet"

# Servidor LAN - en red interna lan-net
Crear-VM -Nombre "Servidor-LAN" -OS "Ubuntu_64" -RAM 1024 `
    -DiscoPath "C:\VMs\Discos\servidor-lan.vdi" `
    -ISO "C:\VMs\ISOs\ubuntu-server.iso" `
    -Red "lan-net" -TipoRed "intnet"

# Kali Atacante - en NAT Network Red_WAN (mismo segmento que WAN de pfSense)
Crear-VM -Nombre "Kali-Atacante" -OS "Debian_64" -RAM 2048 `
    -DiscoPath "C:\VMs\Discos\kali.vdi" `
    -ISO "C:\VMs\ISOs\kali.iso" `
    -Red "Red_WAN" -TipoRed "natnetwork"

Write-Host "`n=== Todas las VMs creadas ===" -ForegroundColor Green
VBoxManage list vms

Write-Host "`n=== Proximo paso: encender pfSense y completar el setup ===" -ForegroundColor Yellow
Write-Host "1. Arranca pfSense, asigna interfaces (em0=WAN, em1=LAN, em2=OPT1)"
Write-Host "2. Asigna IPs: LAN=192.168.1.1/24, OPT1=192.168.2.1/24"
Write-Host "3. Mira la IP WAN (DHCP). Sera algo como 10.0.2.X"
Write-Host "4. Corre el siguiente script con esa IP:"
Write-Host "   .\scripts\port-forward-gui-pfsense.ps1 <IP-WAN-pfSense>"
Write-Host "5. Abre el navegador: https://127.0.0.1:8443"
