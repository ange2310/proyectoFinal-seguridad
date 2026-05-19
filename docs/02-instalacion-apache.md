# Instalar Apache en el servidor web de la DMZ

> Si seguiste [00-copiar-pegar-en-vms.md](00-copiar-pegar-en-vms.md) y montaste la
> carpeta compartida, puedes ejecutar `sudo bash /media/sf_scripts/configurar-servidor-web.sh`
> y saltarte esta guía. Si prefieres tipear los comandos a mano (son pocos),
> sigue abajo.

---

## Paso 1 — Verificar que la VM ve a pfSense

Dentro de la VM Servidor-Web-DMZ:

```
ip a
ping -c 3 192.168.2.1
```

Debe ver:
- IP propia `192.168.2.10/24` en `enp0s3` (si no, configura abajo).
- Respuesta del gateway pfSense en `192.168.2.1`.

### Si la IP no es 192.168.2.10:

```
sudo nano /etc/netplan/00-installer-config.yaml
```

Pega (o tipea) el contenido de [configs/netplan-dmz.yaml](../configs/netplan-dmz.yaml):

```yaml
network:
  ethernets:
    enp0s3:
      addresses: [192.168.2.10/24]
      routes:
        - to: default
          via: 192.168.2.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
  version: 2
```

Guarda (Ctrl+O, Enter, Ctrl+X) y aplica:

```
sudo netplan apply
ip a
```

---

## Paso 2 — Instalar Apache (3 comandos)

```
sudo apt update
sudo apt install apache2 -y
sudo systemctl enable --now apache2
```

---

## Paso 3 — Página de prueba (1 comando)

```
sudo nano /var/www/html/index.html
```

Reemplaza el contenido por:

```html
<!DOCTYPE html>
<html>
<head><title>DMZ - Servidor Web</title></head>
<body style="font-family:Arial;background:#1a1a2e;color:#eee;text-align:center;padding:50px">
  <h1>Servidor Web - ZONA DMZ</h1>
  <p>IP: 192.168.2.10</p>
  <p style="color:#4ade80">Firewall activo y funcionando</p>
</body>
</html>
```

---

## Paso 4 — Verificar localmente

```
curl http://localhost
sudo systemctl status apache2
```

Debe imprimir el HTML y status `active (running)`.

---

## Paso 5 — Verificar desde la LAN (cruza pfSense)

Desde la VM Servidor-LAN:

```
curl http://192.168.2.10
```

⚠️ **Esto debe FALLAR** si configuraste bien las reglas LAN (solo permite HTTP a `any`,
pero la DMZ está detrás del firewall). Si funciona, revisa que la regla
"bloquear lo demás" en LAN esté activa.

Desde el host Windows (si configuraste port forward NAT en pfSense): abre Firefox en
`http://127.0.0.1` y debe mostrar la página.

---

## Capturas para el informe

- [ ] Salida de `curl http://localhost` desde la DMZ → `apache-curl-local.png`
- [ ] `systemctl status apache2` → `apache-status.png`
- [ ] Página web abierta en el navegador del host → `apache-navegador.png`
