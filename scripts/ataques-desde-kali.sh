#!/bin/bash
# ataques-desde-kali.sh
# Ejecutar DENTRO de Kali Linux.
# Pasa la IP objetivo como argumento o exporta OBJETIVO antes de correrlo.
#
# Uso:
#   ./ataques-desde-kali.sh 10.0.2.2
#   OBJETIVO=10.0.2.2 ./ataques-desde-kali.sh
#
# Genera resultados en ./resultados-ataques/ para adjuntar al informe.

set -u

OBJETIVO="${1:-${OBJETIVO:-}}"
if [[ -z "$OBJETIVO" ]]; then
  echo "ERROR: define OBJETIVO o pásalo como argumento."
  echo "Ejemplo: $0 10.0.2.2"
  exit 1
fi

OUT="./resultados-ataques"
mkdir -p "$OUT"
LAN_IP="192.168.1.10"

echo "=== [1/6] Nmap escaneo de host ==="
nmap -sn "$OBJETIVO" | tee "$OUT/01-nmap-host.txt"

echo "=== [2/6] Nmap puertos 1-1024 ==="
nmap -sS -p 1-1024 "$OBJETIVO" | tee "$OUT/02-nmap-puertos.txt"

echo "=== [3/6] Nmap detección de versión ==="
nmap -sV -p 80,443 "$OBJETIVO" | tee "$OUT/03-nmap-version.txt"

echo "=== [4/6] Nmap intento a LAN (debe fallar) ==="
nmap -sS -p 22,80,445 "$LAN_IP" | tee "$OUT/04-nmap-lan-bloqueada.txt"

echo "=== [5/6] curl al servidor web (control positivo) ==="
curl -v "http://$OBJETIVO" 2>&1 | tee "$OUT/05-curl-dmz.txt"

echo "=== [6/6] hping3 flood 5 segundos (Ctrl+C si quieres cortar antes) ==="
if command -v hping3 >/dev/null; then
  timeout 5 sudo hping3 -S -p 80 --flood "$OBJETIVO" 2>&1 | tail -20 | tee "$OUT/06-hping-flood.txt" || true
else
  echo "hping3 no instalado; omitido. Instala: sudo apt install hping3 -y"
fi

echo
echo "================================="
echo "Resultados guardados en $OUT/"
echo "Copialos al repo en capturas/ y referencialos en el informe."
echo "================================="
