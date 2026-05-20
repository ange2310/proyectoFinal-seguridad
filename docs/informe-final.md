# Informe Final — Aseguramiento de Redes con Firewalls

**Asignatura:** Seguridad de Redes
**Proyecto:** Configuración y aseguramiento de redes con firewalls
**Fecha:** 2026

**Integrantes:**
- Angelica Maria Marcillo Alba
- Samuel Arredondo Delgado
- Jose Daniel Arango Reina
- Juan Jose Santacruz Ferraro
- Daniel Sanchez Collazos

---

## 1. Objetivo

Implementar y validar la configuración de un firewall pfSense que proteja una red
interna simulada, controlando el tráfico entrante y saliente con base en políticas
de seguridad definidas, segmentando la red en zonas LAN y DMZ, y demostrando
mediante pruebas de ataque controladas la efectividad de las reglas.

## 2. Alcance

- Diseño y montaje de una red virtual con 4 máquinas en VirtualBox.
- Instalación y configuración de pfSense como firewall central.
- Definición de reglas de firewall según el principio de mínimo privilegio.
- Pruebas de validación con Nmap, Hydra, Metasploit, hping3 y Wireshark.

## 3. Topología de red

Ver detalle en [topologia-red.md](topologia-red.md).

Ver diagrama detallado en [topologia-red.md](topologia-red.md).

| VM                | Sistema       | IP              | Rol                       |
|-------------------|---------------|-----------------|---------------------------|
| pfSense-Firewall  | pfSense CE    | WAN: DHCP / LAN: 192.168.1.1 / OPT1: 192.168.2.1 | Firewall central |
| Servidor-Web-DMZ  | Ubuntu 22.04  | 192.168.2.10    | Apache HTTP/HTTPS         |
| Servidor-LAN      | Ubuntu 22.04  | 192.168.1.10    | SSH / archivos            |
| Kali-Atacante     | Kali Linux    | 10.0.2.15 (NAT) | Pruebas ofensivas         |

## 4. Herramientas

| Categoría      | Herramienta                |
|----------------|----------------------------|
| Virtualización | VirtualBox 7.x             |
| Firewall       | pfSense CE 2.7             |
| Servidor web   | Apache 2.4 (Ubuntu)        |
| Escaneo        | Nmap, hping3               |
| Explotación    | Metasploit Framework       |
| Fuerza bruta   | Hydra                      |
| Monitoreo      | Wireshark, tcpdump, logs pfSense |

## 5. Configuración del firewall

### 5.1 Interfaces

![Estado de las interfaces de pfSense](../capturas/pfsense-interfaces.png)

### 5.2 Reglas WAN

![Reglas de la interfaz WAN](../capturas/pfsense-reglas-wan.png)

| N° | Acción | Origen     | Destino       | Puerto | Justificación                          |
|----|--------|------------|---------------|--------|----------------------------------------|
| 1  | PASS   | any        | 192.168.2.10  | 80     | Publicar servicio web                  |
| 2  | PASS   | any        | 192.168.2.10  | 443    | Publicar servicio web (HTTPS)          |
| 3  | PASS   | IP admin   | 192.168.1.10  | 22     | SSH administrativo restringido         |
| 4  | BLOCK  | any        | any           | any    | Política denegar-por-defecto con log   |

### 5.3 Reglas DMZ (OPT1)

![Reglas de la interfaz DMZ (OPT1)](../capturas/pfsense-reglas-dmz.png)

| N° | Acción | Origen           | Destino          | Puerto    | Justificación                              |
|----|--------|------------------|------------------|-----------|--------------------------------------------|
| 1  | BLOCK  | 192.168.2.0/24   | 192.168.1.0/24   | any       | Aislamiento DMZ↔LAN (crítico)              |
| 2  | PASS   | 192.168.2.0/24   | any              | 80, 443   | Permitir actualizaciones desde la DMZ      |

### 5.4 Reglas LAN

![Reglas de la interfaz LAN](../capturas/pfsense-reglas-lan.png)

| N° | Acción | Protocolo | Puerto    | Justificación                       |
|----|--------|-----------|-----------|-------------------------------------|
| 1  | PASS   | TCP       | 80, 443   | Navegación web                      |
| 2  | PASS   | TCP       | 22        | SSH saliente                        |
| 3  | PASS   | TCP/UDP   | 53        | DNS                                 |
| 4  | BLOCK  | any       | any       | Denegar UDP y otros no permitidos   |

### 5.5 NAT Port Forward

![NAT Port Forward configurados](../capturas/pfsense-nat.png)

| WAN port | Destino interno  | Servicio |
|----------|------------------|----------|
| 80       | 192.168.2.10:80  | HTTP     |
| 443      | 192.168.2.10:443 | HTTPS    |

## 6. Servidor web en la DMZ

Instalación documentada en [02-instalacion-apache.md](02-instalacion-apache.md).

![Estado de Apache en la DMZ](../capturas/apache-status.png)
![Servidor web abierto en navegador](../capturas/apache-navegador.png)

## 7. Pruebas de ataque y resultados

Procedimiento completo en [03-ataques-kali.md](03-ataques-kali.md).

### 7.1 Escaneo de puertos básico

**Comando:** `nmap -sS -p 1-1024 10.0.2.5`

**Resultado esperado:** solo 80 y 443 abiertos. Resto `filtered` (firewall) o `closed`.

![Escaneo de puertos comunes con nmap](../capturas/nmap-puertos-comunes.png)

**Análisis:** las reglas WAN están funcionando — solo los puertos publicados son
visibles desde el exterior.

### 7.2 Detección de versión

**Comando:** `nmap -sV -p 80,443 10.0.2.5`

![Detección de versión de Apache con nmap -sV](../capturas/nmap-version-apache.png)

**Análisis:** Apache responde con la versión, lo cual es información útil para el
atacante. **Mitigación recomendada:** ocultar tokens (`ServerTokens Prod` y
`ServerSignature Off` en Apache).

### 7.3 Intento de acceso a la LAN

**Comando:** `nmap -sS -p 22,80,445 192.168.1.10` desde Kali.

![Escaneo a la LAN bloqueado por el firewall](../capturas/nmap-lan-bloqueado.png)

**Análisis:** todos los puertos aparecen `filtered`. La LAN está aislada de la WAN
y de la DMZ. ✅

### 7.4 Validación de regla "SSH solo desde IP administrativa"

**Comando desde Kali (IP autorizada `10.0.2.15`):** `ssh lan@10.0.2.5`

![SSH desde Kali alcanza el servidor LAN a través de pfSense](../capturas/ssh-desde-kali-OK.png)

**Análisis:** la conexión SSH desde Kali llega correctamente al servidor LAN
(`192.168.1.10`) atravesando el firewall pfSense por el NAT Port Forward
configurado. Esto demuestra dos cosas críticas:

1. **El port forward funciona** (`WAN:22 → 192.168.1.10:22`).
2. **La regla "Source: 10.0.2.15"** filtra el origen: solo Kali (IP administrativa)
   puede usar este port forward. Cualquier otra IP intentando lo mismo recibiría
   un timeout silencioso (la regla por defecto bloquea sin responder, generando
   evidencia en los logs).

El servidor LAN nunca está expuesto directamente al exterior — toda conexión
pasa por el firewall, que verifica origen, protocolo y destino antes de reenviar. ✅

### 7.6 DoS simulado (SYN flood)

**Comando:** `hping3 -S -p 80 --flood 10.0.2.5` (5 segundos)

![Logs de pfSense mostrando los paquetes bloqueados del escaneo y flood desde Kali](../capturas/pfsense-logs-bloqueados.png)

**Análisis:** pfSense registra y bloquea (en parte) el flood en sus logs. Para
mitigación real se recomendaría activar **pfBlockerNG** o limitar conexiones por
segundo en las reglas (`Advanced Options → Max new connections per second`).

### 7.7 Control positivo

**Comando:** `curl -v http://10.0.2.5`

![Servidor web responde correctamente al curl](../capturas/curl-dmz-ok.png)

**Análisis:** el servicio publicado responde correctamente — el firewall no está
sobre-bloqueando.

## 8. Captura de tráfico

Procedimiento en [04-capturas-wireshark.md](04-capturas-wireshark.md).

![Logs de pfSense con 500 entradas BLOCK registradas durante el ataque](../capturas/pfsense-logs-bloqueados.png)

**Análisis del log:** las 500 entradas (máximo mostrado) corresponden todas a
`Source: 10.0.2.15` (Kali) intentando conectarse a múltiples puertos de
`Destination: 10.0.2.5` (WAN de pfSense). La regla "Bloquear y registrar todo lo
demas" capturó y registró cada intento. Esto demuestra que el firewall:
- **Detecta** los escaneos de red.
- **Bloquea** todo intento no autorizado.
- **Registra** cada bloqueo para auditoría posterior.

**Archivos .pcap entregados:** `capturas/wireshark-ataque.pcapng`, `capturas/pfsense-pcap-wan.pcap`

## 9. Conclusiones

1. La segmentación en zonas WAN/DMZ/LAN, combinada con una política
   denegar-por-defecto, redujo drásticamente la superficie de ataque expuesta:
   de 1024 puertos posibles a 2 visibles desde el exterior.
2. El aislamiento DMZ↔LAN impide el movimiento lateral en caso de que el servidor
   web sea comprometido.
3. La restricción de SSH a una única IP administrativa neutraliza ataques de
   fuerza bruta desde otras fuentes.
4. El registro (log) de las reglas BLOCK proporciona una bitácora útil para
   detección de incidentes (Status → System Logs → Firewall).
5. La validación con herramientas ofensivas (Nmap, Hydra, Metasploit) confirmó
   que las reglas implementadas son efectivas contra el reconocimiento básico y
   los intentos de explotación más comunes.

## 10. Recomendaciones a futuro

- Activar **Snort/Suricata** en pfSense para IDS/IPS.
- Implementar **VPN (OpenVPN/WireGuard)** para acceso administrativo en lugar de
  exponer SSH en la WAN.
- Configurar **fail2ban** en los servidores Linux como segunda capa.
- Centralizar logs con **Syslog** hacia un servidor SIEM.
- Endurecer Apache: ocultar versión, deshabilitar métodos HTTP no usados, TLS 1.2+.

## 11. Referencias

- Documentación oficial pfSense: https://docs.netgate.com/pfsense/
- Nmap reference: https://nmap.org/book/
- Metasploit Unleashed: https://www.offensive-security.com/metasploit-unleashed/
- OWASP Top 10: https://owasp.org/Top10/

---

## Anexos

- [00-copiar-pegar-en-vms.md](00-copiar-pegar-en-vms.md)
- [01-guia-pfsense.md](01-guia-pfsense.md)
- [02-instalacion-apache.md](02-instalacion-apache.md)
- [03-ataques-kali.md](03-ataques-kali.md)
- [04-capturas-wireshark.md](04-capturas-wireshark.md)
- [05-checklist-evidencias.md](05-checklist-evidencias.md)
- [topologia-red.md](topologia-red.md)
- [../configs/reglas-firewall.md](../configs/reglas-firewall.md)
