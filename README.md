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

```
proyectoFinal-seguridad/
├── README.md
├── docs/
│   ├── 00-copiar-pegar-en-vms.md      ← cómo no tipear todo a mano
│   ├── 01-guia-pfsense.md             ← reglas paso a paso en la GUI
│   ├── 02-instalacion-apache.md       ← Apache en la DMZ
│   ├── 03-ataques-kali.md             ← nmap, hydra, metasploit, hping3
│   ├── 04-capturas-wireshark.md       ← capturas de tráfico
│   ├── 05-checklist-evidencias.md     ← qué capturas necesitas
│   ├── topologia-red.md               ← diagrama y flujos
│   └── informe-final.md               ← plantilla del informe
├── scripts/
│   ├── setup-virtualbox.ps1
│   ├── crear-vms.ps1
│   ├── configurar-servidor-web.sh
│   ├── configurar-servidor-lan.sh
│   ├── ataques-desde-kali.sh
│   └── paste-a-vm.ps1                 ← helper para pegar texto en consolas VBox
├── configs/
│   ├── netplan-dmz.yaml
│   ├── netplan-lan.yaml
│   ├── reglas-firewall.md
│   └── pfsense-config.xml             ← config completa exportada de pfSense
└── capturas/
    └── README.md
```

---

## Cómo reproducir este proyecto (para el equipo)

Como las VMs son demasiado grandes para git, este repo contiene **todo lo
necesario para reconstruir el laboratorio desde cero**. Sigue estos pasos:

### 1. Requisitos previos
- Windows 10/11 con al menos **16 GB de RAM** y **80 GB libres en disco**.
- VirtualBox 7.x instalado ([descargar](https://www.virtualbox.org/wiki/Downloads)).
- ISOs descargadas en `C:\VMs\ISOs\`:
  - `pfsense.iso` ([descarga](https://www.pfsense.org/download/))
  - `ubuntu-server.iso` (Ubuntu 22.04 LTS Server)
  - `kali.iso` (Kali Linux Live)

### 2. Clonar el repo
```powershell
git clone https://github.com/<usuario>/proyectoFinal-seguridad.git
cd proyectoFinal-seguridad
```

### 3. Crear las VMs (≈ 5 min)
Ejecuta como **administrador**:
```powershell
.\scripts\setup-virtualbox.ps1
.\scripts\crear-vms.ps1
```

### 4. Instalar los sistemas operativos en cada VM
Sigue las guías en orden:
1. [docs/00-copiar-pegar-en-vms.md](docs/00-copiar-pegar-en-vms.md) — cómo no tipear todo a mano
2. [docs/01-guia-pfsense.md](docs/01-guia-pfsense.md) — configurar pfSense
3. [docs/02-instalacion-apache.md](docs/02-instalacion-apache.md) — Apache en DMZ

### 5. Importar la configuración de pfSense (≈ 30 segundos) ⚡
Esto te ahorra crear todas las reglas a mano:
1. En el navegador, entra al GUI de pfSense (`https://<ip-de-pfsense>`)
2. **Diagnostics → Backup & Restore**
3. En "Restore Configuration":
   - **Restore area:** All
   - **Configuration file:** seleccionar [`configs/pfsense-config.xml`](configs/pfsense-config.xml)
   - Clic en **Restore Configuration**
4. pfSense se reinicia → ya tienes todas las reglas, NAT, alias, etc.

> ⚠️ **Importante sobre la contraseña admin:** la del XML está sanitizada (el hash
> original se reemplazó por el default de pfSense para no exponer credenciales en
> un repo público). Después de importar, entra con:
> - Usuario: `admin`
> - Contraseña: `pfsense`
>
> Y **cámbiala inmediatamente** desde **System → User Manager → admin → Edit**.
> Si el login default no funciona en tu versión de pfSense, resetea desde la consola:
> opción **3 (Reset webConfigurator password)** → vuelves a tener `admin`/`pfsense`.

### 6. Pruebas y documentación
1. Lanza los ataques con [docs/03-ataques-kali.md](docs/03-ataques-kali.md)
   (o ejecuta `scripts/ataques-desde-kali.sh` dentro de Kali).
2. Toma capturas siguiendo [docs/04-capturas-wireshark.md](docs/04-capturas-wireshark.md).
3. Marca evidencias con [docs/05-checklist-evidencias.md](docs/05-checklist-evidencias.md).
4. Rellena [docs/informe-final.md](docs/informe-final.md) y haz `git push`.

---

## Cómo continuar el proyecto (orden sugerido) — para quien ya lo configuró

1. Lee primero [docs/00-copiar-pegar-en-vms.md](docs/00-copiar-pegar-en-vms.md).
2. Configura pfSense con [docs/01-guia-pfsense.md](docs/01-guia-pfsense.md).
3. Instala Apache con [docs/02-instalacion-apache.md](docs/02-instalacion-apache.md).
4. Lanza los ataques con [docs/03-ataques-kali.md](docs/03-ataques-kali.md).
5. Toma capturas siguiendo [docs/04-capturas-wireshark.md](docs/04-capturas-wireshark.md).
6. Marca evidencias con [docs/05-checklist-evidencias.md](docs/05-checklist-evidencias.md).
7. Rellena [docs/informe-final.md](docs/informe-final.md) y haz `git push`.

## Integrantes

* Angelica Maria Marcillo Alba
* Samuel Arredondo Delgado
* Jose Daniel Arango Reina
* Juan Jose Santacruz Ferraro
* Daniel Sanchez Collazos

## Fecha

2026

