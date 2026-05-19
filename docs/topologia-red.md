# Topología de red del proyecto

## Diagrama

```
                       INTERNET
                          │
                          │  (NAT VirtualBox 10.0.2.0/24)
                          │
                ┌─────────┴───────────┐
                │   Kali Atacante     │
                │   nic1: NAT         │
                │   IP: 10.0.2.15     │
                └─────────────────────┘
                          │
                          │  ataques entran por la WAN del firewall
                          ▼
        ┌─────────────────────────────────────────┐
        │           pfSense Firewall              │
        │                                         │
        │  WAN  (em0/NAT)        DHCP 10.0.2.x    │
        │  LAN  (em1/lan-net)    192.168.1.1/24   │
        │  OPT1 (em2/dmz-net)    192.168.2.1/24   │
        └────────┬──────────────────────┬─────────┘
                 │                      │
        lan-net  │                      │  dmz-net
   (intnet)      │                      │  (intnet)
                 │                      │
                 ▼                      ▼
       ┌──────────────────┐   ┌──────────────────────┐
       │  Servidor-LAN    │   │  Servidor-Web-DMZ    │
       │  Ubuntu 22.04    │   │  Ubuntu 22.04        │
       │  192.168.1.10/24 │   │  192.168.2.10/24     │
       │  SSH (22) admin  │   │  Apache HTTP/HTTPS   │
       │  Samba           │   │  80, 443             │
       └──────────────────┘   └──────────────────────┘
```

## Segmentos

| Segmento | CIDR             | Tipo            | Propósito                          |
|----------|------------------|-----------------|------------------------------------|
| WAN      | 10.0.2.0/24      | NAT VirtualBox  | Salida a internet / zona externa   |
| DMZ      | 192.168.2.0/24   | Red interna     | Servicios públicos (Apache)        |
| LAN      | 192.168.1.0/24   | Red interna     | Recursos privados (archivos, admin)|

## Flujos permitidos (por diseño)

```
Internet  ──HTTP/HTTPS──►  DMZ (NAT al servidor web)        ✅
Internet  ────SSH─────►   LAN (solo desde IP administrativa) ✅
LAN       ──HTTP/HTTPS──► Internet                          ✅
DMZ       ──HTTP/HTTPS──► Internet                          ✅
```

## Flujos bloqueados (por diseño)

```
Internet  ──cualquiera──► LAN                ❌ (excepto SSH desde IP admin)
DMZ       ──cualquiera──► LAN                ❌ (aislamiento crítico)
LAN       ──UDP─────────► cualquiera         ❌ (solo TCP necesario)
Cualquier ──escaneo─────► firewall           ❌ (registrado en logs)
```

## Adaptadores VirtualBox por VM

| VM                | nic1            | nic2          | nic3           |
|-------------------|-----------------|---------------|----------------|
| pfSense-Firewall  | NAT (WAN)       | intnet lan-net| intnet dmz-net |
| Servidor-Web-DMZ  | intnet dmz-net  | -             | -              |
| Servidor-LAN      | intnet lan-net  | -             | -              |
| Kali-Atacante     | NAT             | -             | -              |

## Principio de mínimo privilegio aplicado

- **DMZ**: solo expone 80 y 443. No tiene visibilidad de la LAN.
- **LAN**: no acepta tráfico desde fuera salvo SSH desde IP autorizada. Sale solo
  por puertos que el negocio realmente usa (web, DNS, SSH outbound).
- **Firewall**: bloquea por defecto y registra todo lo bloqueado para auditoría.
