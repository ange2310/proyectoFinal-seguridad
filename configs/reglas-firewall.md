# Reglas de Firewall - pfSense

## Interfaz WAN (tráfico entrante desde internet)

| N° | Acción  | Protocolo | Origen   | Destino       | Puerto   | Descripción                    |
|----|---------|-----------|----------|---------------|----------|--------------------------------|
| 1  | PASS    | TCP       | Any      | 192.168.2.10  | 80       | HTTP hacia servidor web DMZ    |
| 2  | PASS    | TCP       | Any      | 192.168.2.10  | 443      | HTTPS hacia servidor web DMZ   |
| 3  | PASS    | TCP       | IP_ADMIN | 192.168.1.10  | 22       | SSH solo desde IP administrativa|
| 4  | BLOCK   | Any       | Any      | Any           | Any      | Bloquear todo lo demás (log ON)|

## Interfaz DMZ (OPT1)

| N° | Acción  | Protocolo | Origen          | Destino         | Puerto   | Descripción                  |
|----|---------|-----------|-----------------|-----------------|----------|------------------------------|
| 1  | BLOCK   | Any       | 192.168.2.0/24  | 192.168.1.0/24  | Any      | DMZ no puede acceder a LAN   |
| 2  | PASS    | TCP       | 192.168.2.0/24  | Any             | 80, 443  | DMZ puede salir a internet   |

## Interfaz LAN

| N° | Acción  | Protocolo | Origen          | Destino | Puerto      | Descripción                    |
|----|---------|-----------|-----------------|---------|-------------|--------------------------------|
| 1  | PASS    | TCP       | 192.168.1.0/24  | Any     | 80, 443, 22 | Solo TCP necesario             |
| 2  | BLOCK   | UDP       | Any             | Any     | Any         | Bloquear UDP no necesario      |

## NAT - Port Forwarding

| Puerto WAN | IP Destino    | Puerto Destino | Descripción        |
|------------|---------------|----------------|--------------------|
| 80         | 192.168.2.10  | 80             | HTTP hacia DMZ     |
| 443        | 192.168.2.10  | 443            | HTTPS hacia DMZ    |
