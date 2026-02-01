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
#   With flags:
#     --uninstall     Remove welcome.sh and hooks
#     --test          Test mode (no actual installation)
#     --no-deps       Skip dependency installation
#     --help          Show help message
#
# -----------------------------------------------------------------------------
# GitHub Repo:   https://github.com/MichalAFerber/welcome-message
# License:       MIT
# Author:        Michal Ferber
# Last Updated:  2026-01-31
# -----------------------------------------------------------------------------

set -e

# Parse command line arguments
UNINSTALL=false
TEST_MODE=false
NO_DEPS=false

for arg in "$@"; do
    case $arg in
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        --test)
            TEST_MODE=true
            shift
            ;;
        --no-deps)
            NO_DEPS=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --uninstall    Remove welcome.sh and shell hooks"
            echo "  --test         Test mode - show what would be done"
            echo "  --no-deps      Skip dependency installation"
            echo "  --help         Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Normal installation"
            echo "  $0 --test             # Test without installing"
            echo "  $0 --uninstall        # Remove installation"
            exit 0
            ;;
        *)
            ;;
    esac
done

# Uninstall function
uninstall_welcome() {
    echo "[+] Uninstalling welcome message..."
    
    # Remove the script
    if [[ -f ~/welcome.sh ]]; then
        rm ~/welcome.sh
        echo "[✓] Removed ~/welcome.sh"
    fi
    
    # Remove hooks from .bashrc
    if [[ -f ~/.bashrc ]]; then
        sed -i.bak '/~\/welcome\.sh/d' ~/.bashrc
        echo "[✓] Removed hook from ~/.bashrc"
    fi
    
    # Remove hooks from .zshrc
    if [[ -f ~/.zshrc ]]; then
        sed -i.bak '/~\/welcome\.sh/d' ~/.zshrc
        echo "[✓] Removed hook from ~/.zshrc"
    fi
    
    # Remove config and cache
    if [[ -d ~/.config/welcome.sh ]]; then
        rm -rf ~/.config/welcome.sh
        echo "[✓] Removed configuration"
    fi
    
    if [[ -d ~/.cache/welcome.sh ]]; then
        rm -rf ~/.cache/welcome.sh
        echo "[✓] Removed cache"
    fi
    
    echo ""
    echo "[✓] Welcome message uninstalled successfully."
    exit 0
}

# Handle uninstall
if [[ "$UNINSTALL" == "true" ]]; then
    uninstall_welcome
fi

DEFAULT_LANG="en"
# Extract language code, handling quotes and special characters
LANG_CODE=$(locale 2>/dev/null | grep LANG= | cut -d= -f2 | tr -d '"' | cut -d_ -f1 | sed 's/C/en/' | tr -d ' ')
# Fallback to en if extraction failed
[[ -z "$LANG_CODE" ]] && LANG_CODE="$DEFAULT_LANG"
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

# Detect operating system
OS_TYPE="$(uname -s)"
IS_MACOS=false
[[ "$OS_TYPE" == "Darwin" ]] && IS_MACOS=true

if [[ "$NO_DEPS" == "false" ]]; then
    echo "[+] Installing required packages..."

    # Skip package manager installation on macOS - users should use Homebrew
    if [[ "$IS_MACOS" == "true" ]]; then
        echo "[i] macOS detected - skipping package manager install"
        echo "[i] Please ensure curl and fastfetch are installed:"
        echo "[i]   brew install curl fastfetch"
    # Detect package manager and install dependencies on Linux
    elif command -v apt-get >/dev/null 2>&1; then
        if [[ "$TEST_MODE" == "false" ]]; then
            # Allow apt update to continue even if third-party repos have signature issues
            # Suppress warnings from third-party repos with signature verification failures
            if ! sudo apt-get update -y &>/dev/null; then
                echo "[!] apt update reported errors (likely third-party repo). Continuing..."
            fi
            sudo apt-get install -y curl
        else
            echo "[TEST] Would install curl with apt"
        fi
    elif command -v dnf >/dev/null 2>&1; then
        [[ "$TEST_MODE" == "false" ]] && sudo dnf install -y curl || echo "[TEST] Would install curl with dnf"
    elif command -v yum >/dev/null 2>&1; then
        [[ "$TEST_MODE" == "false" ]] && sudo yum install -y curl || echo "[TEST] Would install curl with yum"
    elif command -v pacman >/dev/null 2>&1; then
        [[ "$TEST_MODE" == "false" ]] && sudo pacman -Sy --noconfirm curl || echo "[TEST] Would install curl with pacman"
    elif command -v zypper >/dev/null 2>&1; then
        [[ "$TEST_MODE" == "false" ]] && sudo zypper install -y curl || echo "[TEST] Would install curl with zypper"
    else
        echo "[!] Unknown package manager. Please ensure curl is installed."
    fi

    # Improved Raspberry Pi detection
    IS_RPI=false
    if [[ -f /proc/device-tree/model ]] && grep -qi "raspberry pi" /proc/device-tree/model 2>/dev/null; then
        IS_RPI=true
    elif [[ -f /boot/config.txt ]] || [[ -f /boot/firmware/config.txt ]]; then
        IS_RPI=true
    fi

    # Install Raspberry Pi tools if on Raspberry Pi
    if [[ "$IS_RPI" == "true" ]]; then
        echo "[i] Raspberry Pi detected"
        if command -v apt-get >/dev/null 2>&1; then
            if [[ "$TEST_MODE" == "false" ]]; then
                # libraspberrypi-bin is deprecated on newer Raspberry Pi OS
                if ! sudo apt-get install -y libraspberrypi-bin; then
                    echo "[i] libraspberrypi-bin not available, trying raspi-utils-core"
                    if ! sudo apt-get install -y raspi-utils-core; then
                        echo "[i] raspi-utils-core not available, trying raspi-utils-dt"
                        sudo apt-get install -y raspi-utils-dt || echo "[!] Failed to install Raspberry Pi utilities."
                    fi
                fi
            else
                echo "[TEST] Would install Raspberry Pi utilities"
            fi
        fi
    fi
else
    echo "[i] Skipping dependency installation (--no-deps flag set)"
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

    # Skip on macOS - user should use Homebrew
    if [[ "$IS_MACOS" == "true" ]]; then
        echo "[i] macOS detected - skipping auto-install"
        echo "[i] Install with: brew install fastfetch"
        return
    fi

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        
        # Handle Debian-based systems (Ubuntu, Debian, Raspberry Pi OS, etc.)
        if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]] || [[ "$ID" == "raspbian" ]]; then
            if [[ "$TEST_MODE" == "false" ]]; then
                # Try direct install first
                if sudo apt-get install -y fastfetch 2>/dev/null; then
                    echo "[✓] fastfetch installed from official repo."
                else
                    # If that fails and it's Ubuntu 22+, try PPA
                    if [[ "$ID" == "ubuntu" && "${VERSION_ID%%.*}" -ge 22 ]]; then
                        echo "[!] fastfetch not found in default repos, trying PPA..."
                        sudo apt-get install -y software-properties-common
                        sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
                        # Suppress warnings from apt update during PPA addition
                        sudo apt-get update &>/dev/null || true
                        if ! sudo apt-get install -y fastfetch; then
                            echo "[!] Failed to install fastfetch even with PPA."
                        else
                            echo "[✓] fastfetch installed from PPA."
                        fi
                    else
                        echo "[!] Failed to install fastfetch from default repos."
                    fi
                fi
            else
                echo "[TEST] Would attempt to install fastfetch"
            fi
        elif [[ "$ID" == "fedora" ]] || [[ "$ID" == "rhel" ]] || [[ "$ID" == "centos" ]]; then
            [[ "$TEST_MODE" == "false" ]] && sudo dnf install -y fastfetch || echo "[TEST] Would install fastfetch with dnf"
        elif [[ "$ID" == "arch" ]] || [[ "$ID" == "manjaro" ]]; then
            [[ "$TEST_MODE" == "false" ]] && sudo pacman -S --noconfirm fastfetch || echo "[TEST] Would install fastfetch with pacman"
        elif [[ "$ID" == "opensuse" ]] || [[ "$ID" == "opensuse-leap" ]] || [[ "$ID" == "opensuse-tumbleweed" ]]; then
            [[ "$TEST_MODE" == "false" ]] && sudo zypper install -y fastfetch || echo "[TEST] Would install fastfetch with zypper"
        else
            echo "[!] Unsupported OS for automatic fastfetch install."
        fi
    else
        echo "[!] Could not determine OS info — skipping fastfetch install."
    fi
}

if [[ "$NO_DEPS" == "false" ]] && [[ "$IS_MACOS" != "true" ]]; then
    install_fastfetch
fi

# Download the template
echo "[+] Checking welcome script for language: ${LANG_CODE}"
TEMP_FILE=$(mktemp)

if [[ "$TEST_MODE" == "false" ]]; then
    curl -sSL "${TEMPLATE_PATH}" -o "${TEMP_FILE}"
else
    echo "[TEST] Would download template from ${TEMPLATE_PATH}"
    # In test mode, create a dummy file
    echo "# Test welcome script" > "${TEMP_FILE}"
fi

# Compare with existing ~/welcome.sh and replace only if changed
if [[ -f ~/welcome.sh ]]; then
    if cmp -s "$TEMP_FILE" ~/welcome.sh; then
        echo "[-] ~/welcome.sh is already up to date."
        rm "$TEMP_FILE"
    else
        if [[ "$TEST_MODE" == "false" ]]; then
            echo "[+] Updating ~/welcome.sh"
            mv "$TEMP_FILE" ~/welcome.sh
            chmod +x ~/welcome.sh
        else
            echo "[TEST] Would update ~/welcome.sh"
            rm "$TEMP_FILE"
        fi
    fi
else
    if [[ "$TEST_MODE" == "false" ]]; then
        echo "[+] Installing new ~/welcome.sh"
        mv "$TEMP_FILE" ~/welcome.sh
        chmod +x ~/welcome.sh
    else
        echo "[TEST] Would install new ~/welcome.sh"
        rm "$TEMP_FILE"
    fi
fi

# Ensure script is hooked into shell rc files
echo "[+] Ensuring welcome script runs at login"

# Hook into .bashrc
if [[ -f ~/.bashrc ]]; then
    if ! grep -q "~/welcome.sh" ~/.bashrc; then
        if [[ "$TEST_MODE" == "false" ]]; then
            echo "~/welcome.sh" >> ~/.bashrc
            echo "[✓] Added hook to ~/.bashrc"
        else
            echo "[TEST] Would add hook to ~/.bashrc"
        fi
    else
        echo "[-] Hook already exists in ~/.bashrc"
    fi
fi

# Hook into .zshrc (ZSH support)
if [[ -f ~/.zshrc ]]; then
    if ! grep -q "~/welcome.sh" ~/.zshrc; then
        if [[ "$TEST_MODE" == "false" ]]; then
            echo "~/welcome.sh" >> ~/.zshrc
            echo "[✓] Added hook to ~/.zshrc"
        else
            echo "[TEST] Would add hook to ~/.zshrc"
        fi
    else
        echo "[-] Hook already exists in ~/.zshrc"
    fi
fi

# Create default config if it doesn't exist
CONFIG_DIR="$HOME/.config/welcome.sh"
CONFIG_FILE="$CONFIG_DIR/config"

if [[ ! -f "$CONFIG_FILE" ]]; then
    if [[ "$TEST_MODE" == "false" ]]; then
        mkdir -p "$CONFIG_DIR"
        cat > "$CONFIG_FILE" << 'EOF'
# Welcome.sh Configuration File
# 
# Customize your welcome message by uncommenting and modifying these options:

# Show fastfetch system info
#SHOW_FASTFETCH=true

# Show weather information
#SHOW_WEATHER=true

# Show public IP address
#SHOW_PUBLIC_IP=true

# Show system metrics (memory, CPU usage)
#SHOW_SYSTEM_METRICS=true

# Show ASCII art banner
#SHOW_ASCII_ART=false

# Quiet mode (minimal output)
#QUIET_MODE=false

# Weather location (default: Lake+City)
# Use format: "City+Name" or leave empty for default
#WEATHER_LOCATION=""

# Cache timeout in seconds (default: 3600 = 1 hour)
#CACHE_TIMEOUT=3600

# Request timeout for external calls (default: 3 seconds)
#REQUEST_TIMEOUT=3
EOF
        echo "[✓] Created default configuration at ${CONFIG_FILE}"
        echo "[i] Edit ${CONFIG_FILE} to customize your welcome message"
    else
        echo "[TEST] Would create default configuration"
    fi
fi

echo ""
if [[ "$TEST_MODE" == "false" ]]; then
    echo "[✓] Welcome message installed. Open a new terminal or SSH session to see it."
    echo "[i] Configuration: ${CONFIG_FILE}"
    echo "[i] To uninstall, run: curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash -s -- --uninstall"
else
    echo "[✓] Test mode completed. No changes were made."
fi
