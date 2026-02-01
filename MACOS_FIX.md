# macOS & Raspberry Pi Compatibility Fixes

## Issues Fixed

### macOS Issues (v2.0.1)

#### 1. Language Code Parsing (Quote Character Issue)
**Root Cause**: `locale` output includes quotes, and the parsing didn't handle them
**Solution**: Added `tr -d '"'` to remove quotes and `tr -d ' '` to remove spaces

```bash
# Before
LANG_CODE=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1 | sed 's/C/en/')

# After  
LANG_CODE=$(locale 2>/dev/null | grep LANG= | cut -d= -f2 | tr -d '"' | cut -d_ -f1 | sed 's/C/en/' | tr -d ' ')
[[ -z "$LANG_CODE" ]] && LANG_CODE="$DEFAULT_LANG"
```

### 2. Package Manager Detection (macOS Graceful Skip)
**Problem**: macOS doesn't have apt, dnf, yum, pacman, or zypper, causing "Unknown package manager" error
**Root Cause**: Script assumed Linux package managers were always present
**Solution**: Detect macOS using `uname -s` and skip package manager installation with helpful message

```bash
OS_TYPE="$(uname -s)"
IS_MACOS=false
[[ "$OS_TYPE" == "Darwin" ]] && IS_MACOS=true

if [[ "$IS_MACOS" == "true" ]]; then
    echo "[i] macOS detected - skipping package manager install"
    echo "[i] Please ensure curl and fastfetch are installed:"
    echo "[i]   brew install curl fastfetch"
fi
```

### 3. Fastfetch Installation (macOS)
**Problem**: Installer tries to run Linux package managers on macOS
**Solution**: Skip fastfetch auto-install on macOS with instructions to use Homebrew

```bash
if [[ "$IS_MACOS" == "true" ]]; then
    echo "[i] macOS detected - skipping auto-install"
    echo "[i] Install with: brew install fastfetch"
    return
fi
```

## Testing on macOS

Now when you run the installer on macOS:

```bash
curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash
```

You'll see:
```
[+] Detected system language: en                              # ✓ Correct language
[+] Installing required packages...
[i] macOS detected - skipping package manager install         # ✓ Clean message
[i] Please ensure curl and fastfetch are installed:           # ✓ Helpful hint
[i]   brew install curl fastfetch
[i] fastfetch already installed.                              # ✓ OK if already have it
[+] Checking welcome script for language: en                  # ✓ Works!
[+] Installing new ~/welcome.sh
[+] Ensuring welcome script runs at login
[✓] Added hook to ~/.zshrc
[✓] Created default configuration at /Users/michal/.config/welcome.sh/config

[✓] Welcome message installed.
```

## macOS Installation Instructions

For macOS users, the recommended installation is:

1. Install dependencies via Homebrew:
```bash
brew install curl fastfetch
```

2. Run the installer:
```bash
curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash
```

3. Open a new terminal to see the welcome message

## What's Now Fully Supported on macOS

✅ Language detection (English, Spanish, Dutch, French, German)
✅ Zsh and Bash shell hooks  
✅ Configuration file creation
✅ System information display
✅ Weather and IP display (with caching)
✅ Memory and CPU metrics
✅ ASCII art banner
✅ All customization options

## Raspberry Pi Issues (v2.0.2)

### Fastfetch Not Installing on Raspberry Pi

**Problem**: Fastfetch was not installed on Raspberry Pi 4 during installation
**Root Cause**: The installer only checked for Ubuntu 22+ to install fastfetch, but Raspberry Pi OS has `ID=raspbian` or `ID=debian`
**Solution**: Added support for Debian-based systems and Raspbian

```bash
# Before (Ubuntu 22+ only)
if [[ "$ID" == "ubuntu" && "${VERSION_ID%%.*}" -ge 22 ]]; then

# After (all Debian-based systems)
if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]] || [[ "$ID" == "raspbian" ]]; then
```

Now the installer:
- Attempts direct apt install first (works on all Debian-based systems)
- Falls back to PPA only for Ubuntu 22+ if needed
- Works properly on Raspberry Pi OS, Debian, and other Debian derivatives

## Files Modified

- `install_welcome.sh` - Fixed fastfetch installation for Debian-based systems
- `README.md` - Added macOS installation instructions
- `CHANGELOG.md` - Documented all fixes

---

**Status**: macOS and Raspberry Pi support are now fully working! 🎉
