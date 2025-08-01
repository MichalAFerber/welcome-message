#!/bin/bash
clear
command -v fastfetch >/dev/null && fastfetch -c all

CYAN="\033[1;36m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"

echo -e "${CYAN}¡Hola, $USER!${NC}"
echo -e "${YELLOW}Tiempo de actividad: $(uptime -p) | Promedio de carga: $(cut -d ' ' -f1-3 /proc/loadavg)${NC}"

PUBIP=$(curl -s ifconfig.me)
echo -e "${GREEN}IP Pública: $PUBIP${NC}"

echo -e "${CYAN}Uso de disco en /:$(df -h / | awk 'NR==2 {print \" \" $3 \" usados de \" $2 \" (\" $5 \")\"}')${NC}"

if command -v apt >/dev/null 2>&1; then
    UPDATES=$(apt list --upgradeable 2>/dev/null | grep -v "Listing..." | wc -l)
    if [ "$UPDATES" -gt 0 ]; then
        echo -e "${RED}Actualizaciones disponibles: $UPDATES paquete(s)${NC}"
    else
        echo -e "${GREEN}Tu sistema está actualizado.${NC}"
    fi
fi

if [ -f /var/run/reboot-required ]; then
    echo -e "${RED}⚠️  ¡Reinicio requerido!${NC}"
fi
 
# --- CPU Temperature and Throttling ---
TEMP=$(get_temp)
echo -e "${CYAN}Temperatura de CPU: $TEMP${NC}"
# Throttling: only if /dev/vcio exists and vcgencmd returns usable data
if [[ -e /dev/vcio ]] && command -v vcgencmd >/dev/null 2>&1; then
    RAW_OUTPUT=$(vcgencmd get_throttled 2>/dev/null || true)
    if [[ "$RAW_OUTPUT" == throttled=* ]]; then
        THROTTLED_RAW=$(echo "$RAW_OUTPUT" | cut -d= -f2)
        if [ "$THROTTLED_RAW" != "0x0" ]; then
            THROTTLE_STATUS="${RED}Sí ($THROTTLED_RAW)${NC}"
        else
            THROTTLE_STATUS="${GREEN}No${NC}"
        fi
        echo -e "${CYAN}Limitado: $THROTTLE_STATUS${NC}"
    else
        echo -e "${CYAN}Limitado: ${YELLOW}Omitido (salida inválida de vcgencmd)${NC}"
    fi
fi

# --- Weather ---
WEATHER=$(curl -s 'wttr.in/Lake+City?format=3')
echo -e "${YELLOW}Clima: $WEATHER${NC}"

echo -e "${YELLOW}¡Todo listo para Whiskey, Tango, Foxtrot!${NC}"
