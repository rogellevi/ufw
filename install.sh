#!/bin/bash

# Función de ayuda
function ayuda() {
    echo "Uso: $0 -i PUERTO_INICIO -f PUERTO_FIN -p [tcp|udp|both]"
    echo
    echo "  -i    Puerto inicial (obligatorio)"
    echo "  -f    Puerto final (obligatorio)"
    echo "  -p    Protocolo: tcp, udp o both (por defecto: tcp)"
    exit 1
}

# Valores por defecto
PROTOCOLO="tcp"

# Leer opciones
while getopts ":i:f:p:" opt; do
  case $opt in
    i) PUERTO_INICIO="$OPTARG" ;;
    f) PUERTO_FIN="$OPTARG" ;;
    p) PROTOCOLO="$OPTARG" ;;
    *) ayuda ;;
  esac
done

# Validar entradas
if [[ -z "$PUERTO_INICIO" || -z "$PUERTO_FIN" ]]; then
    echo "❌ Error: Debes especificar el puerto inicial y final."
    ayuda
fi

# Verificar que el rango es válido
if (( PUERTO_INICIO > PUERTO_FIN )); then
    echo "❌ Error: PUERTO_INICIO no puede ser mayor que PUERTO_FIN."
    exit 1
fi

# Instalar ufw si no está
if ! command -v ufw &>/dev/null; then
    echo "📦 Instalando ufw..."
    apt update && apt install -y ufw
fi

# Activar ufw si está inactivo
ufw status | grep -q inactive && ufw --force enable

# Aplicar reglas según protocolo
echo "🔓 Abriendo puertos $PUERTO_INICIO-$PUERTO_FIN con protocolo $PROTOCOLO..."

case "$PROTOCOLO" in
    tcp)
        ufw allow ${PUERTO_INICIO}:${PUERTO_FIN}/tcp
        ;;
    udp)
        ufw allow ${PUERTO_INICIO}:${PUERTO_FIN}/udp
        ;;
    both)
        ufw allow ${PUERTO_INICIO}:${PUERTO_FIN}/tcp
        ufw allow ${PUERTO_INICIO}:${PUERTO_FIN}/udp
        ;;
    *)
        echo "❌ Protocolo inválido: $PROTOCOLO. Usa tcp, udp o both."
        exit 1
        ;;
esac

# Eliminar netfilter-persistent si está instalado
if dpkg -l | grep -q netfilter-persistent; then
    echo "🧹 Eliminando netfilter-persistent..."
    apt remove -y netfilter-persistent
else
    echo "✅ netfilter-persistent Desinstalado Exitosamente."
fi

# Mostrar reglas actuales
echo "📋 Estado de UFW:"
ufw status numbered

# Reiniciar el sistema
echo "⚠️ Reiniciando el sistema en 5 segundos... Presiona Ctrl+C para cancelar."
sleep 5
reboot
