# Upgrading from v1.0 to v2.0

## What's New in v2.0?

Version 2.0 is a major update with extensive improvements. Here's what you need to know:

## 🎯 Automatic Upgrade

If you already have v1.0 installed, simply run the installer again:

```bash
curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash
```

The installer will:
1. ✅ Detect your existing installation
2. ✅ Update `~/welcome.sh` with the new version
3. ✅ Create a configuration file at `~/.config/welcome.sh/config`
4. ✅ Add ZSH support if you use ZSH
5. ✅ Keep your existing `.bashrc` hooks

**Your existing setup will not be disrupted!**

## 🆕 What Changes for Existing Users

### New Files Created
- `~/.config/welcome.sh/config` - Your customization settings
- `~/.cache/welcome.sh/` - Cache directory for faster loading

### Behavioral Changes
- **Faster loading**: Public IP and weather are now cached for 1 hour
- **Timeouts**: External calls timeout after 3 seconds instead of hanging
- **More info**: Memory and CPU usage now displayed by default
- **Better Pi detection**: More reliable Raspberry Pi detection

### What Stays the Same
- Your `~/.bashrc` hook remains unchanged
- Same command to trigger: `~/welcome.sh`
- Same display format (with additional metrics)
- Same language detection

## ⚙️ New Configuration Options

After upgrading, you can customize your experience:

```bash
# Edit configuration
nano ~/.config/welcome.sh/config
```

### Quick Customizations

**Want the old behavior (no new features)?**
```bash
cat > ~/.config/welcome.sh/config << EOF
SHOW_SYSTEM_METRICS=false
SHOW_WEATHER=true
SHOW_PUBLIC_IP=true
EOF
```

**Want faster loading?**
```bash
cat > ~/.config/welcome.sh/config << EOF
SHOW_WEATHER=false
SHOW_PUBLIC_IP=false
QUIET_MODE=true
EOF
```

**Want the full experience?**
```bash
cat > ~/.config/welcome.sh/config << EOF
SHOW_FASTFETCH=true
SHOW_WEATHER=true
SHOW_PUBLIC_IP=true
SHOW_SYSTEM_METRICS=true
SHOW_ASCII_ART=true
WEATHER_LOCATION="Your+City"
EOF
```

## 🐞 Troubleshooting Upgrade Issues

### "I don't see the new features"
Run the installer again to ensure you have v2.0:
```bash
curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash
```

Then open a new terminal or run:
```bash
~/welcome.sh
```

### "Loading is slower now"
The first run fetches and caches data. Subsequent runs should be faster.

To disable slow features:
```bash
echo "SHOW_WEATHER=false" >> ~/.config/welcome.sh/config
echo "SHOW_PUBLIC_IP=false" >> ~/.config/welcome.sh/config
```

### "I want the old version back"
Uninstall v2.0 and reinstall v1.0:
```bash
# Uninstall v2.0
curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash -s -- --uninstall

# Install v1.0 (replace with actual v1.0 URL if needed)
# Note: v1.0 may not be available anymore
```

### "Configuration isn't working"
Make sure the config file exists:
```bash
ls -la ~/.config/welcome.sh/config
```

Check syntax in your config file:
```bash
cat ~/.config/welcome.sh/config
```

Reset to defaults:
```bash
rm ~/.config/welcome.sh/config
~/welcome.sh  # Will recreate with defaults
```

## 🎁 New Features You Should Try

### 1. ASCII Art Banner
```bash
echo "SHOW_ASCII_ART=true" >> ~/.config/welcome.sh/config
~/welcome.sh
```

### 2. Custom Weather Location
```bash
echo "WEATHER_LOCATION=\"Tokyo\"" >> ~/.config/welcome.sh/config
~/welcome.sh
```

### 3. System Metrics Dashboard
Already enabled by default! Shows memory and CPU usage.

### 4. ZSH Support
If you use ZSH, the upgrade automatically adds the hook to `.zshrc`.

### 5. Test Mode
Test changes before applying:
```bash
curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash -s -- --test
```

## 📊 Performance Comparison

### v1.0
- Loading time: ~2-5 seconds
- External calls: Every login
- Timeout handling: None (could hang)

### v2.0
- First load: ~2-5 seconds (same)
- Cached loads: <1 second (much faster!)
- External calls: Once per hour (cached)
- Timeout handling: 3 seconds max
- Memory usage: Same

## 🔄 Migration Checklist

- [x] Run installer to upgrade
- [ ] Check `~/.config/welcome.sh/config` was created
- [ ] Test by opening new terminal
- [ ] Customize configuration if desired
- [ ] Enjoy faster, feature-rich welcome message!

## 📚 Additional Resources

- [Full README](README.md) - Complete documentation
- [Quick Start Guide](QUICKSTART.md) - Get started quickly
- [Changelog](CHANGELOG.md) - Detailed changes
- [Configuration Example](config.example) - All options explained

---

## 💬 Feedback

Found an issue with the upgrade? [Open an issue on GitHub](https://github.com/MichalAFerber/welcome-message/issues)

Enjoying v2.0? Give us a ⭐ on GitHub!
