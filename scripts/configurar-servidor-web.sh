#!/bin/bash
# configurar-servidor-web.sh
# Ejecutar dentro de la VM Servidor-Web-DMZ (Ubuntu)

set -e

echo "=== Actualizando paquetes ==="
sudo apt update && sudo apt upgrade -y

echo "=== Instalando Apache ==="
sudo apt install apache2 openssh-server -y
sudo systemctl enable apache2 ssh

echo "=== Creando pagina de prueba ==="
sudo bash -c 'cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head><title>DMZ - Servidor Web</title></head>
<body style="font-family:Arial;background:#1a1a2e;color:#eee;text-align:center;padding:50px">
  <h1>Servidor Web - ZONA DMZ</h1>
  <p>IP: 192.168.2.10</p>
  <p style="color:#4ade80">Firewall activo y funcionando</p>
</body>
</html>
EOF'

echo "=== Configurando IP estatica ==="
sudo bash -c 'cat > /etc/netplan/00-installer-config.yaml << EOF
network:
  ethernets:
    enp0s3:
      addresses:
        - 192.168.2.10/24
      routes:
        - to: default
          via: 192.168.2.1
      nameservers:
        addresses: [8.8.8.8]
  version: 2
EOF'

sudo netplan apply
echo "=== Servidor web DMZ listo ==="
ip addr show enp0s3
