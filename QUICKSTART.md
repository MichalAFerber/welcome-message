# Quick Start Guide

Get up and running with Custom Linux Welcome Message in under 2 minutes!

## 📦 Installation

### Linux (Ubuntu, Debian, Fedora, Arch, etc.)

```bash
curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash
```

### macOS

First, install **Homebrew** (if not already installed):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then install dependencies and the welcome message:

```bash
brew install curl fastfetch
curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash
```

That's it! Open a new terminal to see your welcome message.

## ⚙️ Basic Configuration

### 1. Enable ASCII Art Banner

```bash
mkdir -p ~/.config/welcome.sh
echo "SHOW_ASCII_ART=true" >> ~/.config/welcome.sh/config
```

Test it: `~/welcome.sh`

### 2. Change Weather Location

```bash
echo "WEATHER_LOCATION=\"New+York\"" >> ~/.config/welcome.sh/config
```

### 3. Speed Up Loading

```bash
cat >> ~/.config/welcome.sh/config << EOF
SHOW_WEATHER=false
SHOW_PUBLIC_IP=false
QUIET_MODE=true
EOF
```

## 🔧 Common Tasks

### Test Your Changes

```bash
~/welcome.sh
```

### Reinstall/Update

```bash
curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash
```

### Uninstall

```bash
curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash -s -- --uninstall
```

### Temporarily Disable

Edit `~/.bashrc` or `~/.zshrc` and comment out:
```bash
# ~/welcome.sh
```

## 📋 Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `SHOW_FASTFETCH` | `true` | Show system info with fastfetch |
| `SHOW_WEATHER` | `true` | Show weather from wttr.in |
| `SHOW_PUBLIC_IP` | `true` | Show your public IP |
| `SHOW_SYSTEM_METRICS` | `true` | Show memory and CPU usage |
| `SHOW_ASCII_ART` | `false` | Show ASCII art banner |
| `QUIET_MODE` | `false` | Minimal output for faster loading |
| `WEATHER_LOCATION` | `""` | Your city (e.g., "London") |
| `CACHE_TIMEOUT` | `3600` | Cache duration in seconds |
| `REQUEST_TIMEOUT` | `3` | Timeout for API calls (seconds) |

## 🌍 Supported Languages

- 🇬🇧 English (`en`)
- 🇪🇸 Spanish (`es`)
- 🇳🇱 Dutch (`nl`)
- 🇫🇷 French (`fr`)
- 🇩🇪 German (`de`)

Force a specific language:
```bash
LANG=es_ES.UTF-8 bash <(curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh)
```

## 🚀 Next Steps

1. ✅ Install the welcome message
2. 🎨 Customize your configuration
3. 🌍 Check out the full [README](README.md) for advanced features
4. 🐛 Report issues on [GitHub](https://github.com/MichalAFerber/welcome-message/issues)

## 💡 Pro Tips

- Cache speeds up loading by storing IP and weather data for 1 hour
- Quiet mode disables top CPU process checks for faster loading
- ASCII art looks best with a decent terminal font
- Configuration changes take effect immediately - just run `~/welcome.sh`

---

Need help? Check the [full documentation](README.md) or [troubleshooting guide](README.md#-troubleshooting).
