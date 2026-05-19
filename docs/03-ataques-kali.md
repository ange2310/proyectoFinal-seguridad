# Pruebas de ataque desde Kali Linux

> **Importante**: Este proyecto es **académico**. Solo ejecuta estos comandos contra
> TUS PROPIAS VMs en tu red privada. Escanear o atacar sistemas ajenos es ilegal.

> Para evitar tipear: instala Guest Additions en Kali, activa portapapeles
> bidireccional y copia los comandos desde GitHub abriendo Firefox dentro de Kali.
> Ver [00-copiar-pegar-en-vms.md](00-copiar-pegar-en-vms.md).

---

## Conectividad previa

Kali debe ver el servidor web DMZ (porque hay NAT WAN:80 → 192.168.2.10:80) pero
**NO** debe ver la LAN. Si tu Kali está en NAT, ataca al WAN de pfSense (a la IP
del host Windows en NAT, normalmente `10.0.2.2`). Si lo conectas a una **3ra red
interna** llamada `wan-net` junto a pfSense, ataca directamente a la IP WAN de
pfSense.

Para simplificar todos los comandos usan la variable `$OBJETIVO`. Tipea **una vez**:

```
export OBJETIVO=10.0.2.2     # o la IP WAN de pfSense
echo $OBJETIVO
```

---

## ATAQUE 1: Escaneo básico con Nmap

### 1.1 Detección de host

```
nmap -sn $OBJETIVO
```

**Esperado:** host arriba.

### 1.2 Escaneo de puertos comunes

```
nmap -sS -p 1-1024 $OBJETIVO
```

**Esperado tras configurar pfSense:** solo 80 y 443 abiertos (los del NAT a la DMZ).
Cualquier otro puerto = `filtered` (firewall bloqueando) o `closed`.

📸 Captura: `nmap-puertos-comunes.png`

### 1.3 Identificación de versión del servicio web

```
nmap -sV -p 80,443 $OBJETIVO
```

**Esperado:** Apache versión X.Y.

📸 Captura: `nmap-version-apache.png`

### 1.4 Intento de escaneo agresivo (lo bloquea pfSense)

```
nmap -A -T4 $OBJETIVO
```

**Esperado:** la mayoría de probes filtrados/timeout. Esto deja muchas entradas en
los logs de pfSense → Status → System Logs → Firewall.

📸 Captura: `nmap-agresivo.png`

### 1.5 Intento de llegar a la LAN (DEBE FALLAR)

```
nmap -sS -p 22,80,445 192.168.1.10
```

**Esperado:** todo `filtered`. No hay ruta — pfSense ni siquiera reenvía.

📸 Captura: `nmap-lan-bloqueado.png`

---

## ATAQUE 2: Fuerza bruta SSH (debe ser bloqueado o rechazado)

```
hydra -l admin -P /usr/share/wordlists/rockyou.txt.gz ssh://$OBJETIVO -t 4 -f
```

**Esperado:**
- Si la regla SSH solo permite la IP admin: `Connection refused` o timeout.
- Si configuraste fail2ban en el servidor: bloqueado después de N intentos.

📸 Captura: `hydra-ssh-bloqueado.png`

> Si `rockyou.txt.gz` no está descomprimido: `sudo gunzip /usr/share/wordlists/rockyou.txt.gz`

---

## ATAQUE 3: Metasploit — exploit conocido de Apache (debe fallar)

Abre Metasploit:

```
sudo msfconsole -q
```

Dentro de msfconsole:

```
use auxiliary/scanner/http/http_version
set RHOSTS 10.0.2.2
run
```

Luego:

```
use auxiliary/scanner/http/dir_scanner
set RHOSTS 10.0.2.2
set THREADS 5
run
```

Y prueba un módulo de exploit (no comprometerá el servidor porque Apache está
parchado, pero deja huella en logs):

```
use exploit/multi/http/apache_normalize_path_rce
set RHOSTS 10.0.2.2
exploit
```

**Esperado:** `Exploit failed: The target is not vulnerable`. ✓

📸 Capturas: `metasploit-scan.png`, `metasploit-exploit-fallido.png`

---

## ATAQUE 4: DoS simulado (NO ejecutar en producción)

Solo para ver que pfSense registra el flood. Por 10 segundos máximo:

```
sudo hping3 -S -p 80 --flood $OBJETIVO
```

Presiona **Ctrl+C** a los ~10 segundos.

**Esperado:** pfSense → Status → System Logs → Firewall lleno de entradas BLOCK.

📸 Captura: `hping-flood-logs-pfsense.png`

---

## ATAQUE 5: Probar que el servidor web SÍ responde (control positivo)

```
curl -v http://$OBJETIVO
```

**Esperado:** HTTP 200 con el HTML del servidor DMZ.

📸 Captura: `curl-dmz-ok.png`

---

## Resumen de resultados esperados

| Ataque                | Resultado esperado            | Demuestra                           |
|-----------------------|-------------------------------|-------------------------------------|
| Nmap puertos comunes  | Solo 80, 443 abiertos         | Reglas WAN funcionan                |
| Nmap a 192.168.1.10   | Todo filtrado                 | LAN aislada                         |
| Nmap agresivo         | Genera logs en pfSense        | Detección de escaneo                |
| Hydra SSH             | Refused/timeout               | SSH restringido por IP              |
| Metasploit exploit    | Failed                        | Apache actualizado y firewall filtra|
| hping3 flood          | Entradas BLOCK masivas en log | Firewall mitiga flood               |
| curl al servidor web  | HTTP 200                      | DMZ accesible (control positivo)    |
