#!/bin/bash

CONFIG_DIR="$HOME/.config/welcome.sh"
CONFIG_FILE="$CONFIG_DIR/config"
CACHE_DIR="$HOME/.cache/welcome.sh"

SHOW_FASTFETCH=true
SHOW_WEATHER=true
SHOW_PUBLIC_IP=true
SHOW_SYSTEM_METRICS=true
SHOW_ASCII_ART=false
QUIET_MODE=false
WEATHER_LOCATION=""
CACHE_TIMEOUT=3600
REQUEST_TIMEOUT=3

[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
mkdir -p "$CACHE_DIR"

CYAN="\033[1;36m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
NC="\033[0m"

if [[ "$SHOW_ASCII_ART" == "true" ]]; then
    echo -e "${CYAN}"
    cat << "EOF"
 ██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗
 ██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝
 ██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗  
 ██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝  
 ╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗
  ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
EOF
    echo -e "${NC}"
fi

get_temp() {
    if [[ -r /sys/class/thermal/thermal_zone0/temp ]]; then
        temp_millidegree=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
        if [[ -n "$temp_millidegree" && "$temp_millidegree" != "0" ]]; then
            echo "$((temp_millidegree/1000))°C"
            return
        fi
    fi
    
    # Fallback to sensors
    if command -v sensors >/dev/null 2>&1; then
        sensors 2>/dev/null | grep -i "Package id 0\|Core 0\|temp1" | head -n 1 | awk '{print $2}' | sed 's/+//'
        return
    fi
    
    echo "N/A"
}

get_cached() {
    local cache_file="$1"
    local max_age="$2"
    if [[ -f "$cache_file" ]]; then
        local file_age=$(($(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null)))
        if [[ $file_age -lt $max_age ]]; then
            cat "$cache_file"
            return 0
        fi
    fi
    return 1
}

set_cached() {
    echo "$2" > "$1"
}

OS_TYPE="$(uname -s)"
IS_MACOS=false
[[ "$OS_TYPE" == "Darwin" ]] && IS_MACOS=true

get_uptime() {
    if [[ "$IS_MACOS" == "true" ]]; then
        uptime | sed 's/.*up \(.*\), [0-9]* users.*/\1/' | sed 's/ *$//' || echo "N/A"
    else
        uptime -p 2>/dev/null || echo "N/A"
    fi
}

get_load_average() {
    if [[ "$IS_MACOS" == "true" ]]; then
        uptime | awk -F'load averages?:' '{print $2}' | sed 's/^ *//' || echo "N/A"
    else
        cut -d ' ' -f1-3 /proc/loadavg 2>/dev/null || echo "N/A"
    fi
}

get_top_cpu() {
    if [[ "$IS_MACOS" == "true" ]]; then
        ps -A -o %cpu=,comm= 2>/dev/null | sort -rn | head -n1 | awk '{printf "%s (%.1f%%)", $2, $1}' || echo ""
    else
        ps aux --sort=-%cpu 2>/dev/null | awk 'NR==2 {printf "%s (%.1f%%)", $11, $3}' || echo ""
    fi
}

[[ "$SHOW_FASTFETCH" == "true" ]] && command -v fastfetch >/dev/null && fastfetch

echo -e "${CYAN}¡Hola, $USER!${NC}"
echo -e "${YELLOW}Tiempo de actividad: $(get_uptime) | Promedio de carga: $(get_load_average)${NC}"

if [[ "$SHOW_PUBLIC_IP" == "true" ]]; then
    PUBIP_CACHE="$CACHE_DIR/public_ip"
    PUBIP=$(get_cached "$PUBIP_CACHE" "$CACHE_TIMEOUT")
    if [[ $? -ne 0 ]]; then
        PUBIP=$(timeout "$REQUEST_TIMEOUT" curl -s ifconfig.me 2>/dev/null || echo "N/A")
        [[ "$PUBIP" != "N/A" ]] && set_cached "$PUBIP_CACHE" "$PUBIP"
    fi
    echo -e "${GREEN}IP Pública: $PUBIP${NC}"
fi

if [[ "$SHOW_SYSTEM_METRICS" == "true" ]]; then
    echo -e "${CYAN}Uso de disco en /:$(df -h / | awk 'NR==2 {print " " $3 " usados de " $2 " (" $5 ")"}')${NC}"
    if command -v free >/dev/null 2>&1; then
        MEM_INFO=$(free -b | awk 'NR==2 {used=$3; total=$2; printf "Usado: %.2f GiB / %.2f GiB (%.0f%%)", used/1073741824, total/1073741824, (used/total)*100}')
        echo -e "${BLUE}Memoria: $MEM_INFO${NC}"
    elif [[ "$IS_MACOS" == "true" ]]; then
        TOTAL_MEM_BYTES=$(sysctl -n hw.memsize 2>/dev/null)
        PAGE_SIZE=$(sysctl -n hw.pagesize 2>/dev/null)
        MEM_INFO=$(vm_stat 2>/dev/null | awk -v total_bytes="$TOTAL_MEM_BYTES" -v page="$PAGE_SIZE" '/^Pages active:/ {active=$3+0} /^Pages wired down:/ {wired=$4+0} /^Pages occupied by compressor:/ {comp=$5+0} END {used_bytes=(active+wired+comp)*page; total_gib=total_bytes/1024/1024/1024; used_gib=used_bytes/1024/1024/1024; printf "Usado: %.2f GiB / %.2f GiB (%.0f%%)", used_gib, total_gib, (used_gib/total_gib)*100}')
        echo -e "${BLUE}Memoria: $MEM_INFO${NC}"
    fi
    if [[ "$QUIET_MODE" != "true" ]]; then
        TOP_CPU=$(get_top_cpu)
        [[ -n "$TOP_CPU" ]] && echo -e "${MAGENTA}Top CPU: $TOP_CPU${NC}"
    fi
fi

if command -v apt >/dev/null 2>&1; then
    UPDATES=$(apt list --upgradeable 2>/dev/null | grep -v "Listing..." | wc -l)
    [ "$UPDATES" -gt 0 ] && echo -e "${RED}Actualizaciones disponibles: $UPDATES paquete(s)${NC}" || echo -e "${GREEN}Tu sistema está actualizado.${NC}"
elif command -v dnf >/dev/null 2>&1; then
    UPDATES=$(dnf check-update -q 2>/dev/null | grep -v "^$" | wc -l)
    [[ "$UPDATES" -gt 0 ]] && echo -e "${RED}Actualizaciones disponibles: $UPDATES paquete(s)${NC}" || echo -e "${GREEN}Tu sistema está actualizado.${NC}"
elif command -v pacman >/dev/null 2>&1; then
    UPDATES=$(pacman -Qu 2>/dev/null | wc -l)
    [[ "$UPDATES" -gt 0 ]] && echo -e "${RED}Actualizaciones disponibles: $UPDATES paquete(s)${NC}" || echo -e "${GREEN}Tu sistema está actualizado.${NC}"
fi

if [ -f /var/run/reboot-required ]; then
    echo -e "${RED}⚠️  ¡Reinicio requerido!${NC}"
fi

# --- CPU Temperature and Throttling ---
if [[ "$SHOW_SYSTEM_METRICS" == "true" ]]; then
    TEMP=$(get_temp)
    echo -e "${CYAN}Temperatura de CPU: $TEMP${NC}"
fi

IS_RPI=false
if [[ -f /proc/device-tree/model ]] && grep -qi "raspberry pi" /proc/device-tree/model 2>/dev/null; then
    IS_RPI=true
elif [[ -f /boot/config.txt ]] || [[ -f /boot/firmware/config.txt ]]; then
    IS_RPI=true
fi

if [[ "$IS_RPI" == "true" ]] && command -v vcgencmd >/dev/null 2>&1; then
    RAW_OUTPUT=$(vcgencmd get_throttled 2>/dev/null || true)
    if [[ "$RAW_OUTPUT" == throttled=* ]]; then
        THROTTLED_RAW=$(echo "$RAW_OUTPUT" | cut -d= -f2)
        if [ "$THROTTLED_RAW" != "0x0" ]; then
            THROTTLE_STATUS="${RED}Sí ($THROTTLED_RAW)${NC}"
        else
            THROTTLE_STATUS="${GREEN}No${NC}"
        fi
        echo -e "${CYAN}Limitado: $THROTTLE_STATUS${NC}"
    fi
fi

if [[ "$SHOW_WEATHER" == "true" ]]; then
    WEATHER_CACHE="$CACHE_DIR/weather"
    WEATHER=$(get_cached "$WEATHER_CACHE" "$CACHE_TIMEOUT")
    if [[ $? -ne 0 ]]; then
        LOCATION="${WEATHER_LOCATION:-Lake+City}"
        WEATHER=$(timeout "$REQUEST_TIMEOUT" curl -s "wttr.in/${LOCATION}?format=3" 2>/dev/null || echo "N/A")
        [[ "$WEATHER" != "N/A" ]] && set_cached "$WEATHER_CACHE" "$WEATHER"
    fi
    echo -e "${YELLOW}Clima: $WEATHER${NC}"
fi

echo -e "${YELLOW}¡Todo listo para Whiskey, Tango, Foxtrot!${NC}"
