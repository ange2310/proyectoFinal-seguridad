# Cómo evitar tipear todo a mano en las VMs

La consola de VirtualBox no acepta pegar por defecto. Tienes 3 opciones, de mejor a peor.

---

## Opción A (RECOMENDADA): SSH desde Windows hacia las VMs Linux

Una vez tengas red, te conectas por SSH desde PowerShell y ahí **sí** puedes pegar
(clic derecho = pegar en PowerShell).

### Paso 1 — En cada VM Linux (Servidor-Web-DMZ y Servidor-LAN), tipear UNA sola vez:

```
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
ip a
```

Anota la IP que aparece en `enp0s3` (debería ser 192.168.2.10 o 192.168.1.10).

### Paso 2 — Habilitar Port Forwarding temporal en VirtualBox para llegar por SSH:

En cada VM Linux:
- VirtualBox → la VM → **Configuración** → **Red** → adaptador 1 → **Avanzadas**
  → **Reenvío de puertos** → añadir regla:

| Nombre     | Protocolo | IP host  | Puerto host | IP invitado    | Puerto invitado |
|------------|-----------|----------|-------------|----------------|-----------------|
| ssh-dmz    | TCP       | 127.0.0.1| 2222        | (vacío)        | 22              |
| ssh-lan    | TCP       | 127.0.0.1| 2223        | (vacío)        | 22              |

> Nota: esto solo funciona si el adaptador es NAT. Si el adaptador es "Red interna"
> (intnet), salta a la **Opción B**.

### Paso 3 — Desde PowerShell en Windows:

```powershell
ssh usuario@127.0.0.1 -p 2222   # servidor web DMZ
ssh usuario@127.0.0.1 -p 2223   # servidor LAN
```

Ahora puedes **pegar** comandos largos con clic derecho.

---

## Opción B: Carpeta compartida + ejecutar el script

Permite que la VM lea archivos del host directamente.

### Paso 1 — Instalar Guest Additions en la VM:
- VM corriendo → menú **Dispositivos** → **Insertar imagen de CD de Guest Additions**
- Dentro de la VM tipear:

```
sudo mount /dev/cdrom /mnt
sudo /mnt/VBoxLinuxAdditions.run
sudo reboot
```

### Paso 2 — Configurar carpeta compartida:
- VirtualBox → la VM → **Configuración** → **Carpetas compartidas** → añadir:
  - **Ruta del host:** `D:\proyectoFinal-seguridad\scripts`
  - **Nombre:** `scripts`
  - Marcar **Automontar** y **Permanente**

### Paso 3 — Dentro de la VM:

```
sudo usermod -aG vboxsf $USER
# cerrar sesión y volver a entrar
ls /media/sf_scripts
sudo bash /media/sf_scripts/configurar-servidor-web.sh
```

Listo — el script corre completo sin tipear una sola línea.

---

## Opción C: Portapapeles bidireccional (solo Guest Additions)

Si ya instalaste Guest Additions (paso 1 de Opción B):

- VirtualBox → la VM → **Configuración** → **General** → **Avanzado**
  - **Portapapeles compartido:** Bidireccional
  - **Arrastrar y soltar:** Bidireccional
- Reiniciar la VM

Ahora copiar en Windows y pegar dentro de la VM funciona normal (Ctrl+Shift+V en
terminal Linux).

---

## ¿Y pfSense?

pfSense **NO necesita** nada de esto: toda la configuración se hace por la **GUI web**
desde tu navegador en Windows en `https://192.168.1.1` (después del setup inicial
por consola). Ver [01-guia-pfsense.md](01-guia-pfsense.md).

---

## ¿Y Kali?

Kali tiene Firefox y soporta Guest Additions. La opción más cómoda:

1. Instalar Guest Additions en Kali (mismo procedimiento de la Opción B paso 1).
2. Activar portapapeles bidireccional (Opción C).
3. Abrir Firefox dentro de Kali y leer este repo desde
   `https://github.com/<tu-usuario>/proyectoFinal-seguridad`
4. Copiar comandos directo desde GitHub y pegarlos en la terminal de Kali.
