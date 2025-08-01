#!/bin/bash
#
# -----------------------------------------------------------------------------
# install_welcome.sh
# Custom Linux Welcome Message Installer
#
# - Auto-installs the custom welcome message script (~welcome.sh) with multi-language support.
# - Detects system language, installs required dependencies (Fastfetch, curl, Raspberry Pi packages),
# - Updates or installs the welcome message script, and ensures it runs at shell startup.
#
# Usage:
#   curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash
#
# -----------------------------------------------------------------------------
# GitHub Repo:   https://github.com/MichalAFerber/welcome-message
# License:       MIT
# Author:        Michal Ferber
# Last Updated:  2025-08-01
# -----------------------------------------------------------------------------

set -e

DEFAULT_LANG="en"
LANG_CODE=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1 | sed 's/C/en/')
TEMPLATE_PATH="https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/templates/welcome.sh.template.${LANG_CODE}"

# Fallback if specific language template is not found
if ! curl --silent --fail --output /dev/null "${TEMPLATE_PATH}"; then
    echo "[!] Language-specific template not found for '${LANG_CODE}', falling back to English..."
    echo "[i] Checking available templates in the repository..."
    AVAILABLE=$(curl -s https://api.github.com/repos/MichalAFerber/welcome-message/contents/templates \
        | grep -oE 'welcome\.sh\.template\.[a-z]+' \
        | sed 's/welcome.sh.template.//' | sort | uniq)
    echo "[i] Available templates: ${AVAILABLE}"
    LANG_CODE="$DEFAULT_LANG"
    TEMPLATE_PATH="https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/templates/welcome.sh.template.${DEFAULT_LANG}"
fi

echo "[+] Detected system language: ${LANG_CODE}"
echo "[+] Installing required packages..."

# Install curl if missing
sudo apt-get update -y
sudo apt-get install -y curl

# Optionally install Raspberry Pi tools
if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "armv7l" ]]; then
    if grep -qi "raspberrypi" /proc/cpuinfo; then
        sudo apt-get install -y libraspberrypi-bin
    else
        echo "[i] Not a Raspberry Pi system, skipping libraspberrypi-bin"
    fi
else
    echo "[i] Not a Raspberry Pi system, skipping libraspberrypi-bin"
fi

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install fastfetch with fallback to PPA
install_fastfetch() {
    if command_exists fastfetch; then
        echo "[i] fastfetch already installed."
        return
    fi

    echo "[+] Attempting to install fastfetch..."

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" && "${VERSION_ID%%.*}" -ge 22 ]]; then
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

install_fastfetch

# Download the template
echo "[+] Checking welcome script for language: ${LANG_CODE}"
TEMP_FILE=$(mktemp)
curl -sSL "${TEMPLATE_PATH}" -o "${TEMP_FILE}"

# Compare with existing ~/welcome.sh and replace only if changed
if [[ -f ~/welcome.sh ]]; then
    if cmp -s "$TEMP_FILE" ~/welcome.sh; then
        echo "[-] ~/welcome.sh is already up to date."
        rm "$TEMP_FILE"
    else
        echo "[+] Updating ~/welcome.sh"
        mv "$TEMP_FILE" ~/welcome.sh
        chmod +x ~/welcome.sh
    fi
else
    echo "[+] Installing new ~/welcome.sh"
    mv "$TEMP_FILE" ~/welcome.sh
    chmod +x ~/welcome.sh
fi

# Ensure script is hooked into ~/.bashrc
echo "[+] Ensuring welcome script runs at login"
if ! grep -q "~/welcome.sh" ~/.bashrc; then
    echo "~/welcome.sh" >> ~/.bashrc
else
    echo "[-] Hook already exists in ~/.bashrc"
fi

echo ""
echo "[✓] Welcome message installed. Open a new terminal or SSH session to see it."
