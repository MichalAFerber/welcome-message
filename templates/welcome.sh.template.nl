#!/bin/bash
clear
command -v fastfetch >/dev/null && fastfetch -c all

CYAN="\033[1;36m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"

echo -e "${CYAN}Hallo, $USER!${NC}"
echo -e "${YELLOW}Uptime: $(uptime -p) | Loadgemiddelde: $(cut -d ' ' -f1-3 /proc/loadavg)${NC}"

PUBIP=$(curl -s ifconfig.me)
echo -e "${GREEN}Publiek IP-adres: $PUBIP${NC}"

echo -e "${CYAN}Schijfgebruik op /:$(df -h / | awk 'NR==2 {print \" \" $3 \" gebruikt van \" $2 \" (\" $5 \")\"}')${NC}"

if command -v apt >/dev/null 2>&1; then
    UPDATES=$(apt list --upgradeable 2>/dev/null | grep -v "Listing..." | wc -l)
    if [ "$UPDATES" -gt 0 ]; then
        echo -e "${RED}Beschikbare updates: $UPDATES pakket(ten)${NC}"
    else
        echo -e "${GREEN}Je systeem is up-to-date.${NC}"
    fi
fi

[ -f /var/run/reboot-required ] && echo -e "${RED}⚠️  Herstart vereist!${NC}"

if command -v vcgencmd &>/dev/null; then
    TEMP=$(vcgencmd measure_temp | cut -d= -f2)
    THROTTLED_RAW=$(vcgencmd get_throttled | cut -d= -f2)
    if [ "$THROTTLED_RAW" != "0x0" ]; then
        THROTTLE_STATUS="${RED}Ja ($THROTTLED_RAW)${NC}"
    else
        THROTTLE_STATUS="${GREEN}Nee${NC}"
    fi
    echo -e "${CYAN}CPU Temperatuur: $TEMP | Beperkt: $THROTTLE_STATUS${NC}"
fi

WEATHER=$(curl -s 'wttr.in/Lake+City?format=3')
echo -e "${YELLOW}Weer: $WEATHER${NC}"

echo -e "${YELLOW}Klaar voor Whiskey, Tango, Foxtrot!${NC}"
