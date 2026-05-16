# Proyecto Final - Aseguramiento de Redes con Firewalls

## Descripción

Implementación de un firewall para proteger una red interna, controlando
tráfico entrante y saliente mediante políticas de seguridad definidas.

## Topología de red

\[Internet / Kali Atacante]

|

\[pfSense Firewall]

/           

\[DMZ]          \[LAN]

Servidor Web   Servidor Interno

192.168.2.10   192.168.1.10

## Segmentos de red

|Segmento|Rango|Descripción|
|-|-|-|
|WAN|DHCP (NAT)|Conexión a internet / zona externa|
|LAN|192.168.1.0/24|Red interna con recursos críticos|
|DMZ|192.168.2.0/24|Zona pública con servidor web|

## Máquinas virtuales

|VM|OS|IP|Rol|
|-|-|-|-|
|pfSense-Firewall|pfSense|192.168.1.1|Firewall|
|Servidor-Web-DMZ|Ubuntu 22.04|192.168.2.10|Apache HTTP/HTTPS|
|Servidor-LAN|Ubuntu 22.04|192.168.1.10|Archivos / SSH|
|Kali-Atacante|Kali Linux|NAT|Pruebas de ataque|

## Herramientas utilizadas

* **Virtualización**: VirtualBox
* **Firewall**: pfSense
* **Escaneo**: Nmap, Metasploit
* **Monitoreo**: Wireshark, tcpdump

## Reglas de firewall implementadas

|Regla|Acción|Puerto|
|-|-|-|
|HTTP/HTTPS hacia DMZ|PERMITIR|80, 443|
|SSH solo desde IP administrativa|PERMITIR|22|
|DMZ → LAN|BLOQUEAR|Todos|
|Todo lo demás desde WAN|BLOQUEAR|Todos|

## Estructura del repositorio

proyectoFinal-seguridad/
├── README.md
├── docs/
│   ├── informe-final.md
│   └── topologia-red.md
├── scripts/
│   ├── setup-virtualbox.ps1
│   ├── crear-vms.ps1
│   ├── configurar-servidor-web.sh
│   └── configurar-servidor-lan.sh
├── configs/
│   ├── netplan-dmz.yaml
│   ├── netplan-lan.yaml
│   └── reglas-firewall.md
└── capturas/
└── README.md

## Integrantes

* Angelica Maria Marcillo Alba
* Samuel Arredondo Delgado
* Jose Daniel Arango Reina
* Juan Jose Santacruz Ferraro
* Daniel Sanchez Collazos

## Fecha

2026

