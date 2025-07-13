#!/bin/bash
#
# -----------------------------------------------------------------------------
# install_welcome.sh
# Custom Linux Welcome Message Installer
#
# - Auto-installs the custom welcome message script (~welcome.sh) with multi-language support.
# - Detects system language, installs required dependencies (Fastfetch, curl, Raspberry Pi packages),
# - updates or installs the welcome message script, and ensures it runs at shell startup.
#
# Usage:
#   curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash
#   Optionally specify language:
#   curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash -s -- --lang=es
#
# -----------------------------------------------------------------------------
# GitHub Repo:   https://github.com/MichalAFerber/welcome-message
# License:       MIT
# Author:        Michal Ferber
# Last Updated:  2025-07-12
# -----------------------------------------------------------------------------

SCRIPT_HASH="b647444e6325b669"

set -e

LANG_CODE=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1)
TEMPLATE_PATH="https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/templates/welcome.sh.template.${LANG_CODE}"

echo "[+] Detected system language: ${LANG_CODE}"
echo "[+] Installing required packages..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install fastfetch if not present
install_fastfetch() {
    if command_exists fastfetch; then
        echo "[i] fastfetch already installed."
        return
    fi

    echo "[+] Attempting to install fastfetch..."

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" && "${VERSION_ID%%.*}" -ge 22 ]]; then
            sudo apt-get update -y

            if ! sudo apt-get install -y fastfetch; then
                echo "[!] fastfetch not found in default repos, trying PPA..."

                sudo apt-get install -y software-properties-common
                sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
                sudo apt-get update

                if ! sudo apt-get install -y fastfetch; then
                    echo "[!] Failed to install fastfetch even with PPA."
                else
                    echo "[✓] fastfetch installed from PPA."
                fi
            else
                echo "[✓] fastfetch installed from official repo."
            fi
        else
            echo "[!] Unsupported OS or Ubuntu version < 22.04 — skipping fastfetch install."
        fi
    else
        echo "[!] Could not determine OS info — skipping fastfetch install."
    fi
}

# Install curl
sudo apt-get install -y curl

# Try to install libraspberrypi-bin if on RPi
if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "armv7l" ]]; then
    if grep -qi "raspberrypi" /proc/cpuinfo; then
        sudo apt-get install -y libraspberrypi-bin
    else
        echo "[i] Not a Raspberry Pi system, skipping libraspberrypi-bin"
    fi
else
    echo "[i] Not a Raspberry Pi system, skipping libraspberrypi-bin"
fi

install_fastfetch

echo "[+] Checking welcome script for language: ${LANG_CODE}"
TEMP_FILE=$(mktemp)
curl -sSL "${TEMPLATE_PATH}" -o "${TEMP_FILE}"

# Compute hash
DOWNLOADED_HASH=$(sha256sum "${TEMP_FILE}" | cut -c1-16)

if [[ "$DOWNLOADED_HASH" != "$SCRIPT_HASH" ]]; then
    echo "[!] Template hash mismatch. Possible update or corruption."
    echo "[+] Updating ~/welcome.sh"
    mv "${TEMP_FILE}" ~/welcome.sh
    chmod +x ~/welcome.sh
else
    echo "[-] ~/welcome.sh is already up to date."
    rm "${TEMP_FILE}"
fi

# Hook into ~/.bashrc
echo "[+] Ensuring welcome script runs at login"
if ! grep -q "~/welcome.sh" ~/.bashrc; then
    echo "~/welcome.sh" >> ~/.bashrc
else
    echo "[-] Hook already exists in ~/.bashrc"
fi

echo ""
echo "[✓] Welcome message installed. Open a new terminal or SSH session to see it."
