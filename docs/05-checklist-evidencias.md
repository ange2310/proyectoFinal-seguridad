# Checklist de evidencias para el informe

Marca cada cuadro cuando tengas la captura/archivo en `capturas/`. Cuando todo
esté ✅, el informe está completo.

---

## Bloque 1 — pfSense configurado

- [ ] `pfsense-interfaces.png` — Status → Interfaces (WAN, LAN, OPT1 con IPs)
- [ ] `pfsense-reglas-wan.png` — Firewall → Rules → WAN (las 4 reglas)
- [ ] `pfsense-reglas-dmz.png` — Firewall → Rules → OPT1
- [ ] `pfsense-reglas-lan.png` — Firewall → Rules → LAN
- [ ] `pfsense-nat.png` — Firewall → NAT → Port Forward

## Bloque 2 — Servidor web DMZ funcionando

- [ ] `apache-status.png` — `systemctl status apache2` mostrando `active (running)`
- [ ] `apache-curl-local.png` — `curl http://localhost` desde la DMZ
- [ ] `apache-navegador.png` — Página abierta en el navegador

## Bloque 3 — Pruebas de ataque desde Kali

- [ ] `nmap-puertos-comunes.png` — Solo 80, 443 abiertos
- [ ] `nmap-version-apache.png` — Versión detectada de Apache
- [ ] `nmap-agresivo.png` — Escaneo `-A -T4` con muchos `filtered`
- [ ] `nmap-lan-bloqueado.png` — Escaneo a 192.168.1.10 (todo filtered)
- [ ] `hydra-ssh-bloqueado.png` — Hydra rechazado/timeout
- [ ] `metasploit-scan.png` — Resultado de los auxiliary scanners
- [ ] `metasploit-exploit-fallido.png` — `Exploit failed`
- [ ] `hping-flood-logs-pfsense.png` — pfSense con muchos BLOCK durante el flood
- [ ] `curl-dmz-ok.png` — Control positivo: el servidor web SÍ responde

## Bloque 4 — Capturas de tráfico

- [ ] `wireshark-ataque.pcapng` — Captura .pcap completa del ataque
- [ ] `wireshark-http-ok.png` — Tráfico HTTP exitoso visible
- [ ] `wireshark-syn-bloqueado.png` — SYN sin SYN/ACK de respuesta
- [ ] `pfsense-pcap-wan.pcap` — Captura desde pfSense
- [ ] `pfsense-logs-bloqueados.png` — Logs con Action=Block

## Bloque 5 — Resultados del script

- [ ] Carpeta `resultados-ataques/` copiada al repo (salida del script)

## Bloque 6 — Documento final

- [ ] [docs/informe-final.md](informe-final.md) — Todas las secciones rellenadas
      y todas las `[INSERTAR CAPTURA: ...]` reemplazadas

---

## Cómo copiar capturas desde las VMs al host Windows

### Si usaste Guest Additions + Carpeta compartida:
Simplemente guarda las capturas dentro de la carpeta compartida desde la VM.

### Si tienes SSH habilitado:
Desde PowerShell en Windows:
```powershell
scp -P 2222 usuario@127.0.0.1:~/captura.png D:\proyectoFinal-seguridad\capturas\
```

### Desde la GUI de Kali / Ubuntu:
Toma la captura con **PrtSc** o **gnome-screenshot**, guarda en `~/Pictures/`,
luego usa `scp` o copia por la carpeta compartida.

### Desde pfSense (Packet Capture, logs):
La GUI tiene botón **Download** — descarga directo al host.
