# Changelog

All notable changes to the Custom Linux Welcome Message project will be documented in this file.

## [2.1.1] - 2026-04-06

### Changed

- **Default weather location** changed from Lake+City to New+York
- **Configurable weather format** - Added `WEATHER_FORMAT` option to set the wttr.in display format (default: 3). See https://wttr.in/:help for all options
- **Config auto-update on upgrade** - Installer now adds new config options and removes deprecated ones from existing config files
- **Individual metric toggles** - Replaced `SHOW_SYSTEM_METRICS` with individual toggles: `SHOW_DISK_USAGE`, `SHOW_MEMORY`, `SHOW_CPU_TEMP`, `SHOW_TOP_CPU`
- **All mounted volumes** - Disk usage now lists all mounted volumes instead of just `/` (macOS system volumes are filtered out)
- **CPU temp macOS** - CPU temperature is automatically skipped on macOS where it is not available
- **Auto-create config** - The welcome script now creates a default config file at `~/.config/welcome.sh/config` if one doesn't exist
- **Weather city name casing** - Format 3 now preserves the casing from your config; formats 1 and 2 prepend the city name
- **Private IP display** - Added `SHOW_PRIVATE_IP` option to show the local/private IP address (default: false)
- **Uptime toggle** - Added `SHOW_UPTIME` option to toggle the uptime and load average display
- **Clear cache flag** - Added `--clear-cache` flag to `welcome.sh` for clearing cached data (useful when testing config changes)
- **Custom greeting** - Added `GREETING` config option to override the default language-specific greeting message
- **Removed obsolete docs** - Removed `IMPLEMENTATION.md`, `MACOS_FIX.md`, `UPGRADE.md`, and `QUICKSTART.md` (content already covered by CHANGELOG.md and README.md)

## [2.1.0] - 2026-04-03

### Bug Fixes

- **macOS memory reporting** - Fixed hardcoded 8 GiB total and 4096-byte page size; now reads actual RAM via `sysctl -n hw.memsize` and page size via `sysctl -n hw.pagesize`, and counts active + wired + compressor pages
- **macOS load average** - Fixed `load average:` (singular) to `load averages?:` to match macOS `uptime` output which uses plural
- **Linux memory reporting** - Fixed `free -h` with awk arithmetic (human-readable strings like "1.5Gi" can't be used in math); now uses `free -b`
- **`clear` placement** - Removed unconditional `clear` that was wiping ASCII art banner and prior terminal content
- **French template syntax errors** - Fixed extra `fi`, missing closing `)` on disk usage line, hardcoded weather without caching/toggle, old `/dev/vcio` RPi detection
- **Spanish/Dutch template syntax errors** - Fixed missing closing `)` on disk usage line, extra `fi` in Dutch
- **German template** - Added missing `get_uptime`, `get_load_average`, `get_top_cpu` function definitions and OS detection

### Improvements

- **`SHOW_SYSTEM_METRICS` scope** - Now controls disk usage and CPU temperature in addition to memory and top CPU process, for consistent toggle behavior
- **Removed duplicate color definitions** in all templates
- Updated documentation to reflect `SHOW_SYSTEM_METRICS` scope change

## [2.0.2] - 2026-01-31

### 🐛 Bug Fixes

- **Raspberry Pi fastfetch installation** - Fixed installer skipping fastfetch on Raspberry Pi OS
- **Debian support** - Now properly installs fastfetch on Debian-based systems
- **Raspbian support** - Added explicit support for Raspbian (older Raspberry Pi OS)

### ✨ Improvements

- Simplified fastfetch installation logic for apt-based systems
- PPA fallback now only used for Ubuntu 22+ as intended
- Better error handling for package installation failures

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
