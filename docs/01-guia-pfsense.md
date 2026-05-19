# Guía paso a paso: configurar pfSense

Todo lo que sigue se hace **desde el navegador en Windows** una vez termines el
asignamiento inicial de interfaces. Solo la primera parte (asignar interfaces)
necesita la consola de la VM pfSense.

---

## Parte 1 — Configuración inicial en la consola de la VM (UNA sola vez)

Al arrancar pfSense te muestra un menú. Tipea los números, no hay que pegar nada.

### 1.1 Asignar interfaces

```
1   (Assign Interfaces)
```

Cuando pregunte:
- `Do VLANs need to be set up first?` → **n**
- `Enter the WAN interface name`  → **em0**  (la que tiene NAT)
- `Enter the LAN interface name`  → **em1**  (la conectada a lan-net)
- `Enter the Optional 1 interface name` → **em2** (la conectada a dmz-net)
- `Do you want to proceed?` → **y**

> Si los nombres son diferentes (vtnet0, re0...) usa los que aparezcan. El orden
> debe coincidir con cómo creaste los adaptadores en `crear-vms.ps1`:
> nic1=WAN(NAT), nic2=LAN, nic3=DMZ.

### 1.2 Asignar IPs a LAN y OPT1

```
2   (Set interface(s) IP address)
```

**LAN:**
- Interface: **2** (LAN)
- Configure IPv4 via DHCP? → **n**
- Nueva IP IPv4 LAN: **192.168.1.1**
- Subnet bits: **24**
- Gateway IPv4 LAN: (enter, vacío)
- Configure IPv6? → **n**
- Enable DHCP server on LAN? → **y**
- Rango: **192.168.1.100** → **192.168.1.200**
- Revert to HTTP webConfigurator? → **n**

**OPT1 (DMZ):**
- Repetir `2`
- Interface: **3** (OPT1)
- IP: **192.168.2.1** / **24**
- Gateway: (vacío)
- IPv6: **n**
- DHCP server OPT1: **y**
- Rango: **192.168.2.100** → **192.168.2.200**

Listo. Ya no toques la consola.

---

## Parte 2 — Acceso a la GUI web

### 2.1 Desde una VM Linux en la LAN

Lo más limpio: arranca la VM Servidor-LAN, abre Firefox y entra a:

```
https://192.168.1.1
```

Usuario: `admin`  /  Contraseña: `pfsense`

Acepta el certificado autofirmado.

### 2.2 Desde Windows host (alternativa)

Habilita port forwarding del WAN de pfSense:
- VM pfSense → Configuración → Red → Adaptador 1 (NAT) → Avanzadas → Reenvío de puertos:

| Nombre | Protocolo | Puerto host | Puerto invitado |
|--------|-----------|-------------|-----------------|
| pf-gui | TCP       | 8443        | 443             |

Y **permitir el acceso WAN al webConfigurator temporalmente** (Setup Wizard pregunta esto).

Desde Windows: `https://127.0.0.1:8443`

> Recomendación: usa la **2.1**. Acceso WAN al webConfigurator es mala práctica en producción.

### 2.3 Setup Wizard

Te aparece al primer login. Acepta los defaults excepto:
- **Hostname:** pfsense
- **Domain:** local
- **Primary DNS:** 8.8.8.8
- Cambia la **contraseña de admin**.
- En **WAN**: deja DHCP, **desmarca** "Block private networks" si pregunta (estamos en NAT).
- Reinicia cuando lo pida.

---

## Parte 3 — Crear las reglas del firewall

### 3.1 Reglas en la interfaz WAN

**Firewall → Rules → WAN → Add (flecha arriba)**

**Regla 1: Permitir HTTP hacia el servidor web DMZ**

| Campo                  | Valor                                    |
|------------------------|------------------------------------------|
| Action                 | Pass                                     |
| Interface              | WAN                                      |
| Address Family         | IPv4                                     |
| Protocol               | TCP                                      |
| Source                 | any                                      |
| Destination            | Single host or alias → `192.168.2.10`    |
| Destination port range | HTTP (80) - HTTP (80)                    |
| Log                    | ✓ Log packets that are handled           |
| Description            | Permitir HTTP hacia DMZ                  |

**Save** → **Apply Changes**

**Regla 2: Permitir HTTPS hacia DMZ** (igual que la anterior pero puerto HTTPS 443)

**Regla 3: Permitir SSH solo desde IP administrativa**

| Action      | Pass                                       |
| Protocol    | TCP                                        |
| Source      | Single host → `<IP_DE_TU_KALI_O_ADMIN>`    |
| Destination | Single host → `192.168.1.10`               |
| Dest port   | SSH (22)                                   |
| Log         | ✓                                          |
| Description | SSH solo desde admin                       |

> Reemplaza `<IP_DE_TU_KALI_O_ADMIN>` con la IP NAT de Kali. Si Kali está en NAT
> normal, sale como `10.0.2.15`. Si quieres probar el bloqueo, usa otra IP cualquiera
> que no sea la de Kali — así verás el SSH bloqueado.

**Regla 4: Bloquear todo lo demás (explícita, con log)**

| Action      | Block                  |
| Protocol    | any                    |
| Source      | any                    |
| Destination | any                    |
| Log         | ✓                      |
| Description | Bloquear y registrar   |

> pfSense ya bloquea por defecto en WAN, pero esta regla EXPLÍCITA con LOG es
> indispensable para que los intentos bloqueados aparezcan en
> **Status → System Logs → Firewall** (tu evidencia para el informe).

### 3.2 Reglas en la interfaz DMZ (OPT1)

**Firewall → Rules → OPT1 → Add**

**Regla 1: Bloquear DMZ → LAN (lo más importante)**

| Action      | Block                                |
| Protocol    | any                                  |
| Source      | Network → `192.168.2.0` / 24         |
| Destination | Network → `192.168.1.0` / 24         |
| Log         | ✓                                    |
| Description | DMZ no puede acceder a LAN           |

**Regla 2: Permitir DMZ → Internet (HTTP/HTTPS para actualizaciones)**

| Action      | Pass                                  |
| Protocol    | TCP                                   |
| Source      | Network → `192.168.2.0` / 24          |
| Destination | any                                   |
| Dest port   | other → 80, repetir para 443          |
| Description | DMZ puede salir a internet (web)      |

> En pfSense para abrir varios puertos crea una **alias** (Firewall → Aliases →
> Ports → Add → Name: `WebPorts`, Values: 80, 443) y úsala como destino.

### 3.3 Reglas en la interfaz LAN

La LAN trae por defecto una regla "Default allow LAN to any". **Bórrala** y crea estas:

**Regla 1: LAN puede salir solo por TCP necesario**

| Action | Pass | TCP | source: LAN net | dest: any | port: WebPorts (80,443) | Solo HTTP/HTTPS |
| Action | Pass | TCP | source: LAN net | dest: any | port: 22 (SSH)           | SSH saliente    |
| Action | Pass | TCP | source: LAN net | dest: any | port: 53                 | DNS TCP         |
| Action | Pass | UDP | source: LAN net | dest: any | port: 53                 | DNS UDP         |

**Regla final (LAN): bloquear lo demás con log**

| Action: Block | any | any → any | Log ✓ | Bloquear UDP y otros no necesarios |

---

## Parte 4 — NAT Port Forwarding (publicar el servidor web)

**Firewall → NAT → Port Forward → Add**

**Regla 1: WAN:80 → DMZ:80**

| Interface     | WAN                       |
| Protocol      | TCP                       |
| Destination   | WAN address               |
| Dest port     | HTTP (80)                 |
| Redirect target IP | Single host → 192.168.2.10 |
| Redirect target port | HTTP (80)            |
| Description   | HTTP a servidor web DMZ   |
| Filter rule association | Add associated filter rule |

**Regla 2: WAN:443 → DMZ:443** (igual con puerto HTTPS)

> "Add associated filter rule" crea automáticamente la regla en WAN — si lo usas,
> puedes saltarte las reglas 1 y 2 de la sección 3.1.

---

## Parte 5 — Verificación

1. **Status → Interfaces** — todas las IPs deben coincidir:
   - WAN: DHCP de 10.0.2.x
   - LAN: 192.168.1.1
   - OPT1: 192.168.2.1
2. **Status → System Logs → Firewall** — debe estar vacío de errores.
3. **Diagnostics → Ping** — desde pfSense:
   - Ping a 192.168.2.10 (DMZ) ✓
   - Ping a 192.168.1.10 (LAN) ✓
   - Ping a 8.8.8.8       (Internet) ✓

Si los 3 pings funcionan, pasa a [02-instalacion-apache.md](02-instalacion-apache.md).

---

## Capturas que debes tomar para el informe

Mientras configuras, toma screenshots de:
- [ ] Listado completo de reglas WAN (`pfsense-reglas-wan.png`)
- [ ] Listado completo de reglas DMZ (`pfsense-reglas-dmz.png`)
- [ ] Listado completo de reglas LAN (`pfsense-reglas-lan.png`)
- [ ] NAT Port Forward (`pfsense-nat.png`)
- [ ] Status → Interfaces (`pfsense-interfaces.png`)

Guárdalas en `capturas/` con esos nombres.
