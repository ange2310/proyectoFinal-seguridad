# crear-vms.ps1
# Ejecutar DESPUES de setup-virtualbox.ps1 y de tener las ISOs en C:\VMs\ISOs\

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
    if ($TipoRed -eq "intnet") {
        VBoxManage modifyvm $Nombre --nic1 intnet --intnet1 $Red
    } else {
        VBoxManage modifyvm $Nombre --nic1 nat
    }
    Write-Host "[OK] $Nombre creada." -ForegroundColor Green
}

# pfSense (3 interfaces de red)
VBoxManage createvm --name "pfSense-Firewall" --ostype "FreeBSD_64" --register
VBoxManage modifyvm "pfSense-Firewall" --memory 512 --cpus 1 --vram 16 --boot1 dvd --boot2 disk
VBoxManage createhd --filename "C:\VMs\Discos\pfsense.vdi" --size 10240 --format VDI
VBoxManage storagectl "pfSense-Firewall" --name "SATA" --add sata --controller IntelAhci
VBoxManage storageattach "pfSense-Firewall" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "C:\VMs\Discos\pfsense.vdi"
VBoxManage storagectl "pfSense-Firewall" --name "IDE" --add ide
VBoxManage storageattach "pfSense-Firewall" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "C:\VMs\ISOs\pfsense.iso"
VBoxManage modifyvm "pfSense-Firewall" --nic1 nat
VBoxManage modifyvm "pfSense-Firewall" --nic2 intnet --intnet2 "lan-net"
VBoxManage modifyvm "pfSense-Firewall" --nic3 intnet --intnet3 "dmz-net"

# Servidor Web DMZ
Crear-VM -Nombre "Servidor-Web-DMZ" -OS "Ubuntu_64" -RAM 1024 `
    -DiscoPath "C:\VMs\Discos\servidor-web.vdi" `
    -ISO "C:\VMs\ISOs\ubuntu-server.iso" `
    -Red "dmz-net" -TipoRed "intnet"

# Servidor LAN
Crear-VM -Nombre "Servidor-LAN" -OS "Ubuntu_64" -RAM 1024 `
    -DiscoPath "C:\VMs\Discos\servidor-lan.vdi" `
    -ISO "C:\VMs\ISOs\ubuntu-server.iso" `
    -Red "lan-net" -TipoRed "intnet"

# Kali Atacante
Crear-VM -Nombre "Kali-Atacante" -OS "Debian_64" -RAM 2048 `
    -DiscoPath "C:\VMs\Discos\kali.vdi" `
    -ISO "C:\VMs\ISOs\kali.iso" `
    -Red "nat" -TipoRed "nat"

Write-Host "`n=== Todas las VMs creadas ===" -ForegroundColor Green
VBoxManage list vms
