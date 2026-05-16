#!/bin/bash
# configurar-servidor-lan.sh
# Ejecutar dentro de la VM Servidor-LAN (Ubuntu)

set -e

echo "=== Actualizando paquetes ==="
sudo apt update && sudo apt upgrade -y

echo "=== Instalando servicios ==="
sudo apt install openssh-server samba -y
sudo systemctl enable ssh

echo "=== Configurando IP estatica ==="
sudo bash -c 'cat > /etc/netplan/00-installer-config.yaml << EOF
network:
  ethernets:
    enp0s3:
      addresses:
        - 192.168.1.10/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8]
  version: 2
EOF'

sudo netplan apply
echo "=== Servidor LAN listo ==="
ping -c 3 192.168.1.1
