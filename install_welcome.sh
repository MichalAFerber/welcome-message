#!/bin/bash

set -e

REPO_URL="https://raw.githubusercontent.com/MichalAFerber/welcome-message/main"
TEMPLATE_PATH="templates"
WELCOME_SCRIPT="$HOME/welcome.sh"
SCRIPT_HASH="66b27215b4c98b28"
SHELL_NAME=$(basename "$SHELL")
LANG_CHOICE="en"

# Parse arguments
for arg in "$@"; do
  case $arg in
    --lang=*)
      LANG_CHOICE="${arg#*=}"
      shift
      ;;
  esac

done

# Detect shell rc
case "$SHELL_NAME" in
    bash) SHELL_RC="$HOME/.bashrc" ;;
    zsh) SHELL_RC="$HOME/.zshrc" ;;
    *) echo "[!] Unsupported shell: $SHELL_NAME" && exit 1 ;;
esac

# Ensure dependencies are installed
install_dependencies() {
    echo "[+] Installing required packages..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y fastfetch curl libraspberrypi-bin
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y fastfetch curl libraspberrypi-tools
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm fastfetch curl raspberrypi-firmware
    else
        echo "[!] Unsupported package manager. Install dependencies manually."
        return 1
    fi
}

# Download and install language-specific welcome script
install_or_update_welcome() {
    echo "[+] Checking welcome script for language: $LANG_CHOICE"
    TEMPLATE_URL="$REPO_URL/$TEMPLATE_PATH/welcome.sh.template.$LANG_CHOICE"
    TEMP_FILE=$(mktemp)

    if ! curl -fsSL "$TEMPLATE_URL" -o "$TEMP_FILE"; then
        echo "[!] Language template not found: $LANG_CHOICE. Falling back to English."
        curl -fsSL "$REPO_URL/$TEMPLATE_PATH/welcome.sh.template.en" -o "$TEMP_FILE"
    fi

    # Calculate checksum
    LOCAL_HASH=$(sha256sum "$TEMP_FILE" | cut -c1-16)
    if [ "$LOCAL_HASH" != "$SCRIPT_HASH" ] && [ "$LANG_CHOICE" = "en" ]; then
        echo "[!] Template hash mismatch. Possible update or corruption."
    fi

    if [ ! -f "$WELCOME_SCRIPT" ] || ! cmp -s "$TEMP_FILE" "$WELCOME_SCRIPT"; then
        echo "[+] Updating $WELCOME_SCRIPT"
        cp "$TEMP_FILE" "$WELCOME_SCRIPT"
        chmod +x "$WELCOME_SCRIPT"
    else
        echo "[-] $WELCOME_SCRIPT is already up to date."
    fi

    rm -f "$TEMP_FILE"
}

# Add to shell config if not already there
add_shell_hook() {
    echo "[+] Ensuring welcome script runs at login"
    if ! grep -q 'welcome.sh' "$SHELL_RC"; then
        echo -e "\n# Launch welcome script\nif [ -x \"$WELCOME_SCRIPT\" ]; then\n    \"$WELCOME_SCRIPT\"\nfi" >> "$SHELL_RC"
        echo "[+] Hook added to $SHELL_RC"
    else
        echo "[-] Hook already exists in $SHELL_RC"
    fi
}

# Install to /etc/profile.d/ if run as root
install_systemwide() {
    if [ "$EUID" -eq 0 ]; then
        echo "[+] Installing system-wide welcome script..."
        cp "$WELCOME_SCRIPT" /etc/profile.d/welcome.sh
        chmod +x /etc/profile.d/welcome.sh
    fi
}

install_dependencies
install_or_update_welcome
add_shell_hook
install_systemwide

echo -e "\n[✓] Welcome message installed. Open a new terminal or SSH session to see it."
exit 0
