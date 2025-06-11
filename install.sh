#!/bin/bash

# Colores
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
NC='\e[0m' # Sin color

# Encabezado
echo -e "${BLUE}=== Configuración de UFW y eliminación de netfilter-persistent ===${NC}"

# Verificar permisos de root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Este script debe ejecutarse como root.${NC}"
  exit 1
fi

# Verificar si UFW está instalado
if ! command -v ufw &> /dev/null; then
  echo -e "${YELLOW}UFW no está instalado. Instalando...${NC}"
  apt update && apt install -y ufw
else
  echo -e "${GREEN}UFW ya está instalado.${NC}"
fi

# Solicitar el rango de puertos
read -p "$(echo -e ${YELLOW}'Ingrese el rango de puertos a abrir (ej. 8000:9000): '${NC})" PORT_RANGE

# Validar formato básico del rango
if ! [[ "$PORT_RANGE" =~ ^[0-9]+:[0-9]+$ ]]; then
  echo -e "${RED}Formato de rango inválido. Use el formato inicio:fin (ej. 8000:9000).${NC}"
  exit 1
fi

# Abrir el rango en UFW para TCP y UDP
echo -e "${GREEN}Abriendo puertos $PORT_RANGE en TCP y UDP...${NC}"
ufw allow "$PORT_RANGE"/tcp
ufw allow "$PORT_RANGE"/udp

# Activar UFW si está inactivo
if ! ufw status | grep -q "Status: active"; then
  echo -e "${YELLOW}UFW no está activo. Activándolo...${NC}"
  ufw enable
fi

# Eliminar netfilter-persistent
echo -e "${GREEN}Eliminando netfilter-persistent...${NC}"
apt remove -y netfilter-persistent

# Preguntar si desea reiniciar
read -p "$(echo -e ${YELLOW}'¿Desea reiniciar el sistema ahora? (s/n): '${NC})" REINICIAR

if [[ "$REINICIAR" =~ ^[sS]$ ]]; then
  echo -e "${YELLOW}Reiniciando el sistema en 10 segundos...${NC}"
  sleep 10
  reboot
else
  echo -e "${GREEN}Proceso completado sin reinicio.${NC}"
fi
