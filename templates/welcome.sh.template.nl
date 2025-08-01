#!/bin/bash
clear
command -v fastfetch >/dev/null && fastfetch -c all

CYAN="\033[1;36m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"

echo -e "${CYAN}Hallo, $USER!${NC}"
echo -e "${YELLOW}Uptime: $(uptime -p) | Gemiddelde belasting: $(cut -d ' ' -f1-3 /proc/loadavg)${NC}"

PUBIP=$(curl -s ifconfig.me)
echo -e "${GREEN}Openbaar IP-adres: $PUBIP${NC}"

echo -e "${CYAN}Schijfgebruik op /:$(df -h / | awk 'NR==2 {print \" \" $3 \" gebruikt van \" $2 \" (\" $5 \")\"}')${NC}"

if command -v apt >/dev/null 2>&1; then
    UPDATES=$(apt list --upgradeable 2>/dev/null | grep -v "Listing..." | wc -l)
    if [ "$UPDATES" -gt 0 ]; then
        echo -e "${RED}Beschikbare updates: $UPDATES pakket(ten)${NC}"
    else
        echo -e "${GREEN}Je systeem is up-to-date.${NC}"
    fi
fi

if [ -f /var/run/reboot-required ]; then
    echo -e "${RED}⚠️  Opnieuw opstarten vereist!${NC}"
fi

# --- CPU Temperatuur en Beperkingen ---
TEMP=$(get_temp)
echo -e "${CYAN}CPU-temperatuur: $TEMP${NC}"

# Beperkingen: alleen als /dev/vcio bestaat en vcgencmd geldige gegevens teruggeeft
if [[ -e /dev/vcio ]] && command -v vcgencmd >/dev/null 2>&1; then
    RAW_OUTPUT=$(vcgencmd get_throttled 2>/dev/null || true)
    if [[ "$RAW_OUTPUT" == throttled=* ]]; then
        THROTTLED_RAW=$(echo "$RAW_OUTPUT" | cut -d= -f2)
        if [ "$THROTTLED_RAW" != "0x0" ]; then
            THROTTLE_STATUS="${RED}Ja ($THROTTLED_RAW)${NC}"
        else
            THROTTLE_STATUS="${GREEN}Nee${NC}"
        fi
        echo -e "${CYAN}Beperkt: $THROTTLE_STATUS${NC}"
    else
        echo -e "${CYAN}Beperkt: ${YELLOW}Overgeslagen (ongeldige uitvoer van vcgencmd)${NC}"
    fi
fi

# --- Weer ---
WEATHER=$(curl -s 'wttr.in/Lake+City?format=3')
echo -e "${YELLOW}Weer: $WEATHER${NC}"

echo -e "${YELLOW}Alles is klaar voor Whiskey, Tango, Foxtrot!${NC}"
