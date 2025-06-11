#!/bin/bash

LOGFILE="/var/log/abrir_puertos.log"

# Colores ANSI
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"

# Función de ayuda
function ayuda() {
    echo -e "${BOLD}Uso:${RESET} $0 -i PUERTO_INICIO -f PUERTO_FIN -p [tcp|udp|both] [-n]"
    echo
    echo -e "  -i    ${BOLD}Puerto inicial${RESET} (obligatorio)"
    echo -e "  -f    ${BOLD}Puerto final${RESET} (obligatorio)"
    echo -e "  -p    ${BOLD}Protocolo${RESET}: tcp, udp o both (por defecto: tcp)"
    echo -e "  -n    ${BOLD}No reiniciar${RESET} el sistema al final"
    exit 1
}

# Valores por defecto
PROTOCOLO="tcp"
REINICIAR=true

# Leer opciones
while getopts ":i:f:p:n" opt; do
  case $opt in
    i) PUERTO_INICIO="$OPTARG" ;;
    f) PUERTO_FIN="$OPTARG" ;;
    p) PROTOCOLO="$OPTARG" ;;
    n) REINICIAR=false ;;
    *) ayuda ;;
  esac
done

# Validar entradas
if [[ -z "$PUERTO_INICIO" || -z "$PUERTO_FIN" ]]; then
    echo -e "${RED}❌ Error:${RESET} Debes especificar el puerto inicial y final." | tee -a "$LOGFILE"
    ayuda
fi

if (( PUERTO_INICIO > PUERTO_FIN )); then
    echo -e "${RED}❌ Error:${RESET} PUERTO_INICIO no puede ser mayor que PUERTO_FIN." | tee -a "$LOGFILE"
    exit 1
fi

# Función para registrar y mostrar mensajes con color
log() {
    local MENSAJE="$1"
    local COLOR="$2"
    echo -e "${COLOR}${MENSAJE}${RESET}"
    echo "[$(date '+%F %T')] $MENSAJE" >> "$LOGFILE"
}

# Instalar ufw si no está
if ! command -v ufw &>/dev/null; then
    log "📦 Instalando ufw..." "$BLUE"
    apt update && apt install -y ufw
fi

# Activar ufw si está inactivo
ufw status | grep -q inactive && ufw --force enable

log "🔓 Abriendo puertos del $PUERTO_INICIO al $PUERTO_FIN con protocolo $PROTOCOLO..." "$YELLOW"

# Aplicar reglas
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
        log "❌ Protocolo inválido: $PROTOCOLO. Usa tcp, udp o both." "$RED"
        exit 1
        ;;
esac

# Eliminar netfilter-persistent si está instalado
if dpkg -l | grep -q netfilter-persistent; then
    log "🧹 Eliminando netfilter-persistent..." "$BLUE"
    apt remove -y netfilter-persistent
else
    log "✅ netfilter-persistent Desinstalado Exitosamente" "$GREEN"
fi

log "📋 Estado actual de UFW:" "$YELLOW"
ufw status numbered | tee -a "$LOGFILE"

# Reinicio opcional
if [ "$REINICIAR" = true ]; then
    log "⚠️ Reiniciando el sistema en 5 segundos... Presiona Ctrl+C para cancelar." "$RED"
    sleep 5
    reboot
else
    log "ℹ️ Reinicio omitido por el usuario." "$GREEN"
fi
