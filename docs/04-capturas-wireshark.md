# Capturas de tráfico (Wireshark / tcpdump)

Objetivo: tener evidencia visual de que el firewall está bloqueando lo correcto.

---

## Opción A: Wireshark en Kali (GUI)

Wireshark ya viene instalado en Kali.

### Pasos:

1. Abrir Wireshark: menú Aplicaciones → Sniffing → Wireshark (o `sudo wireshark`)
2. Doble clic en la interfaz `eth0`
3. En la barra de filtro escribir:

   ```
   ip.addr == 10.0.2.2 and (tcp.port == 80 or tcp.port == 443 or tcp.port == 22)
   ```

4. Empezar captura (▶️).
5. Dejar correr y en **otra terminal** lanzar el script de ataques o un nmap.
6. Detener captura (■) cuando termine.
7. **File → Save As** → `capturas/wireshark-ataque.pcapng`

### Capturas de pantalla a tomar
- [ ] Wireshark con tráfico HTTP exitoso al servidor web → `wireshark-http-ok.png`
- [ ] Wireshark con SYN sin respuesta (puerto bloqueado) → `wireshark-syn-bloqueado.png`
- [ ] Wireshark con intento a 192.168.1.10 sin tráfico de respuesta → `wireshark-lan-sin-respuesta.png`

---

## Opción B: tcpdump (terminal, más ligero, mismo resultado)

Útil si no quieres abrir Wireshark cada vez. Ejecutar en la **VM atacante (Kali)** o
incluso en pfSense (Diagnostics → Packet Capture).

```
sudo tcpdump -i eth0 -w /tmp/captura.pcap host 10.0.2.2
```

Detener con **Ctrl+C** después de hacer el ataque. Luego:

```
sudo tcpdump -r /tmp/captura.pcap -n
```

Para abrir el .pcap con Wireshark más tarde:

```
wireshark /tmp/captura.pcap
```

---

## Opción C: Packet Capture en pfSense (sin instalar nada)

La más cómoda para evidenciar bloqueos del firewall.

1. GUI pfSense → **Diagnostics → Packet Capture**
2. Interface: **WAN**
3. Host Address: (la IP de Kali, ej. 10.0.2.15)
4. Count: 200
5. **Start**
6. En otra ventana: ejecutar el ataque desde Kali
7. **Stop** → **Download Capture**
8. Guardar como `capturas/pfsense-pcap-wan.pcap`

📸 Captura de la pantalla del Packet Capture: `pfsense-packet-capture.png`

---

## Logs del firewall (sin pcap, también vale como evidencia)

GUI pfSense → **Status → System Logs → Firewall**

Filtros útiles:
- **Action:** Block
- **Source IP:** (la IP de Kali)

📸 Captura: `pfsense-logs-bloqueados.png`

---

## Resumen de evidencias para entregar

| Archivo                              | Cómo obtenerlo                          |
|--------------------------------------|-----------------------------------------|
| `wireshark-ataque.pcapng`            | Wireshark en Kali durante el ataque     |
| `wireshark-http-ok.png`              | Filtro `tcp.port==80 && http`           |
| `wireshark-syn-bloqueado.png`        | Filtro `tcp.flags.syn==1 && tcp.flags.ack==0` y ver los que no tienen respuesta |
| `pfsense-pcap-wan.pcap`              | pfSense → Diagnostics → Packet Capture  |
| `pfsense-logs-bloqueados.png`        | pfSense → Status → System Logs → Firewall (filter: Action=Block) |
