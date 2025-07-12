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

[ -f /var/run/reboot-required ] && echo -e "${RED}⚠️  ¡Reinicio requerido!${NC}"

if command -v vcgencmd &>/dev/null; then
    TEMP=$(vcgencmd measure_temp | cut -d= -f2)
    THROTTLED_RAW=$(vcgencmd get_throttled | cut -d= -f2)
    if [ "$THROTTLED_RAW" != "0x0" ]; then
        THROTTLE_STATUS="${RED}Sí ($THROTTLED_RAW)${NC}"
    else
        THROTTLE_STATUS="${GREEN}No${NC}"
    fi
    echo -e "${CYAN}Temperatura de CPU: $TEMP | Limitado: $THROTTLE_STATUS${NC}"
fi

WEATHER=$(curl -s 'wttr.in/Lake+City?format=3')
echo -e "${YELLOW}Clima: $WEATHER${NC}"

echo -e "${YELLOW}¡Todo listo para Whiskey, Tango, Foxtrot!${NC}"
