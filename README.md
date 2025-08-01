# 🖥️ Custom Linux Welcome Message

![screenshot](welcome-message-preview.png)

Easily add a beautiful, dynamic welcome message to your Linux shell—complete with Fastfetch system stats, public IP, disk usage, weather, and multi-language support.

![License: MIT](https://img.shields.io/badge/license-MIT-green)

## 🚀 Features

- 💬 Multi-language welcome message (auto-detected via `LANG`)
- 📦 Fastfetch system overview at login
- 🌐 Weather, public IP, disk usage report
- ✅ Idempotent installer — safe to run repeatedly
- 🧠 Smart Fastfetch install with PPA fallback (Ubuntu 22.04+)
- 🐧 Compatible with Ubuntu, Raspberry Pi OS, and most major Linux distros

## ⚙️ Installation

Run this command to install:

```bash
curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash
````

✅ You can re-run this any time — it will only update the script if needed.

## 🗣️ Language Support

The installer detects your system language using `LANG` and fetches a matching `welcome.sh.template.{lang}`.
Currently available: `en`, `es`, `nl`, `fr`, `de`.
If no matching template is found, the script will display all available templates and automatically use English.

You can temporarily force a language without changing your system locale permanently:

```bash
LANG=fr_FR.UTF-8 LANGUAGE=fr \
bash <(curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh)
```

## 🧪 Safe, Smart, and Idempotent

* Uses content comparison (not hashes) to determine updates
* Adds hook to `.bashrc` or `.zshrc` if needed
* Will not duplicate or overwrite if already installed

## 📦 Dependencies

These are installed automatically:

* `bash`, `curl`
* `fastfetch` (via APT or PPA if needed)
* `libraspberrypi-bin` (only on Raspberry Pi)

Ubuntu 22.04+ users benefit from a Fastfetch PPA for latest builds.

## 📂 Directory Layout

```bash
.
├── install_welcome.sh
└── templates/
    ├── welcome.sh.template.en
    ├── welcome.sh.template.es
    ├── welcome.sh.template.nl
    ├── welcome.sh.template.fr
    └── welcome.sh.template.de
```

Want to contribute a translation? Add a new `welcome.sh.template.xx` file!

## 🧠 Advanced Usage

To manually trigger an update, just rerun:

```bash
curl -s https://raw.githubusercontent.com/MichalAFerber/welcome-message/main/install_welcome.sh | bash
```

To test in a clean shell environment, use Docker or a VM.

## 🤝 Contributing

Pull requests are welcome! Especially for:

* 🌍 Translations (`templates/welcome.sh.template.xx`)
* 💡 Feature ideas
* 🐞 Bug fixes

## 📄 License

[MIT License](LICENSE)

## 🙏 Credits

* Inspired by [fastfetch](https://github.com/fastfetch-cli/fastfetch)
* Weather via [wttr.in](https://wttr.in)

> For more info, read the full blog guide: [Custom Linux Welcome Message](https://michalferber.me/blog/custom-linux-welcome-message)

Enjoy your new login experience. Whiskey, Tango, Foxtrot ready. 🫡
