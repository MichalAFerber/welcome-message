# Changelog

All notable changes to the Custom Linux Welcome Message project will be documented in this file.

## [2.0.1] - 2026-01-31

### 🐛 Bug Fixes

- **macOS Language Detection** - Fixed language code parsing to handle quotes in locale output
- **macOS Package Manager** - Gracefully skip Linux package managers on macOS with helpful instructions
- **macOS Fastfetch Installation** - Skip auto-install on macOS, provide Homebrew instructions
- **macOS Uptime Command** - Fixed `uptime -p` compatibility (not available on macOS)
- **macOS Load Average** - Fixed `/proc/loadavg` compatibility (not available on macOS)
- **macOS Process Commands** - Fixed `ps --sort` syntax for macOS compatibility
- **macOS Memory Display** - Added `vm_stat` support for accurate memory reporting

### ✨ Features

- **macOS Full Support** - Complete compatibility with Bash and Zsh on macOS
- **OS Detection** - Automatic detection of macOS using `uname -s`
- **Cross-Platform Functions** - Helper functions for uptime, load average, and top CPU process
- **macOS Memory Reporting** - Accurate memory display using `vm_stat` on macOS

### 📚 Documentation

- Added comprehensive macOS installation guide to README
- Added Homebrew installation instructions
- Updated QUICKSTART with macOS-specific steps
- Created MACOS_FIX.md documenting all compatibility improvements
- Updated README title to include macOS

### ✨ Improvements

- Better error messages for unsupported systems
- Added OS detection using `uname`
- Improved locale parsing with quote and space handling
- Cross-platform helper functions for system metrics

## [2.0.0] - 2026-01-31

### 🎉 Major Release - Complete Overhaul

This release includes significant improvements across all aspects of the project, making it more powerful, flexible, and user-friendly.

### ✨ Added

#### Configuration System
- **Configuration file support** (`~/.config/welcome.sh/config`)
- Customizable display options (toggle fastfetch, weather, IP, metrics, ASCII art)
- Weather location customization
- Cache timeout configuration
- Request timeout configuration
- Quiet mode for faster loading
- Example configuration file (`config.example`)

#### Performance Optimizations
- **Smart caching system** for public IP and weather data (1-hour default cache)
- **Timeout protection** for external API calls (3-second default)
- Cache directory management (`~/.cache/welcome.sh/`)
- Improved load times with conditional checks

#### System Metrics Dashboard
- **Memory usage display** with percentage
- **Top CPU process** monitoring
- Enhanced disk usage information
- CPU temperature detection with multi-method fallback
- Support for `lm-sensors` temperature reading
- Improved throttling detection for Raspberry Pi

#### Multi-Distribution Support
- **DNF package manager** support (Fedora, RHEL 8+)
- **YUM package manager** support (CentOS, RHEL 7)
- **Pacman package manager** support (Arch Linux, Manjaro)
- **Zypper package manager** support (openSUSE, SUSE Linux)
- Package update detection across all supported package managers
- Automatic fastfetch installation for all supported distributions

#### Installation Improvements
- **ZSH support** - automatic hook installation for `.zshrc`
- **`--test` flag** - preview installation without making changes
- **`--uninstall` flag** - complete removal of all files and hooks
- **`--no-deps` flag** - skip dependency installation
- **`--help` flag** - display usage information
- Improved Raspberry Pi detection (multiple methods)
- Default configuration file creation
- Better error handling and user feedback

#### User Experience
- **ASCII art banner** option (disabled by default, enable in config)
- **Quiet mode** for minimal output
- Color-coded system metrics (blue for memory, magenta for CPU)
- Improved error messages and status indicators
- Installation summary with configuration file location

#### Security & Reliability
- Request timeouts to prevent hanging on slow connections
- Improved error handling for network calls
- Safe uninstall with backup of modified files
- Better detection of system capabilities

### 🔧 Changed

- **Raspberry Pi detection** now uses multiple methods:
  - `/proc/device-tree/model` check
  - `/boot/config.txt` and `/boot/firmware/config.txt` detection
  - Removed unreliable `/dev/vcio` check
- **Installer** updated to version 2.0 with new features
- **All templates** updated with new functionality across 5 languages
- Improved throttling detection (Raspberry Pi only)
- Weather API calls now use cached data when available
- Public IP detection now uses cached data when available

### 🐛 Fixed

- **Missing `get_temp()` function** - now properly defined in all templates
- Temperature detection now works on systems without vcgencmd
- More reliable package manager detection
- Better handling of missing dependencies
- Improved cross-platform compatibility (macOS, Linux)

### 📚 Documentation

- Updated README.md with comprehensive new features
- Added configuration examples and customization guide
- Added troubleshooting section
- Added performance optimization tips
- Added multi-distribution support documentation
- Created example configuration file
- Added advanced usage examples
- Improved installation instructions

### 🌍 Languages

All templates updated with new features:
- English (`en`)
- Spanish (`es`)
- Dutch (`nl`)
- French (`fr`)
- German (`de`)

## [1.0.0] - 2025-08-01

### Initial Release

- Basic welcome message with fastfetch
- Multi-language support (5 languages)
- Public IP and weather display
- Disk usage monitoring
- Package update detection (APT only)
- Raspberry Pi throttling detection
- Basic installation script
- Idempotent installer

---

**Legend:**
- ✨ Added: New features
- 🔧 Changed: Changes in existing functionality
- 🐛 Fixed: Bug fixes
- 📚 Documentation: Documentation changes
- 🌍 Languages: Translation updates
