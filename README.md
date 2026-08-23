# BASH Addins

BASH Addins is a modular library of practical Bash functions and aliases for GNU/Linux. It adds memorable commands for everyday jobs such as finding files, cleaning text, checking a computer, converting media, handling PDFs, controlling X11 windows and working with RSS feeds.

It was started by [Artto Aunap](https://github.com/arrrtto) in 2025 for personal use and is now shared with the GNU/Linux and FOSS community.

## What does it look like?

After installation, functions can be used like ordinary Terminal commands:

```bash
# See memory and disk information
systeminfo

# Find large files below the current folder
bigfiles +500M

# Convert WAV recordings to MP3
to_mp3 *.wav

# Extract email addresses from a file
cat contacts.txt | regex_email

# Show the latest video from a YouTube channel feed
rss_youtube_lastvideo UCDr1XkQaCr4IgrMVN0_28yg
```

Many text functions are designed for piping. The pipe character `|` sends one command's output into the next command:

```bash
cat prices.txt | sed_comma2dot | regex_awk_sum
```

For explanations, practical use cases, examples and safety notes for **every function and alias**, see **[Functionality.md](Functionality.md)**.

## How it works

Source files are organized into modules. The installer combines them into one generated file:

```text
~/bin/bash.addins
```

The installer also adds this line to `~/.bashrc`, so the commands become available whenever a new Bash Terminal opens:

```bash
source ~/bin/bash.addins
```

You can load the library inside your own Bash scripts too:

```bash
#!/bin/bash
source "$HOME/bin/bash.addins"

if numgt 5.2 3.1; then
    echo "The first number is greater."
fi
```

## Modules

| Module | What it provides |
|---|---|
| `main.sh` | Core discovery commands for listing installed functions and aliases. |
| `aliases.sh` | Short everyday commands for listing files, updating Debian systems, finding files and checking IP addresses. |
| `system.sh` | System information, disk health, reminders, timers, RAM drives, file management, process control and automation wait helpers. |
| `text.sh` | Piped text cleanup, pattern extraction, line selection, number comparison, JSON filtering and CSV-style sorting. |
| `media.sh` | Audio/video conversion, screenshots, scanning, OCR, PDF processing, screen/audio recording and clipboard helpers. |
| `gui.sh` | X11 window focusing, resizing, minimizing, closing, inspecting and screenshot capture. |
| `fancy.sh` | Gradient Terminal text and a gradient download progress display. |
| `rss.sh` | YouTube, GitHub and general RSS/Atom feed helpers. |
| `crypto.sh` | Cryptocurrency-related information utilities. |

## Installation

BASH Addins currently provides automatic dependency installation for Debian-family systems such as Debian, Ubuntu, Linux Mint and LMDE.

1. Download the installer:

```bash
wget https://raw.githubusercontent.com/arrrtto/bash.addins/refs/heads/main/installer
```

2. Make it executable:

```bash
chmod +x installer
```

3. Run setup:

```bash
./installer setup
```

Setup will:

- update available APT package information;
- install available optional dependencies one by one;
- skip and report packages unavailable from enabled repositories;
- download the current modules when needed;
- compile `bash.addins`;
- move it to `~/bin/bash.addins`;
- add it to `~/.bashrc`.

Open a new Terminal afterward, or load it immediately with:

```bash
source "$HOME/bin/bash.addins"
```

Run the installer without an argument to see all installer commands:

```bash
./installer
```

## First commands to try

```bash
# Browse all functions and short descriptions
showallfunctions

# Browse aliases
showaliases

# Count installed functions
functions_amount

# Read the complete guide
less Functionality.md
```

## Dependencies

Different functions need different programs. The installer attempts to install the main packages separately, so one unavailable optional package does not prevent other packages or the library itself from being installed.

Examples include FFmpeg, ImageMagick, Tesseract OCR, Ghostscript, LibreOffice, jq, curl, wget, rsync, smartmontools, nvme-cli, X11 tools and PulseAudio/PipeWire-Pulse utilities. See the [dependency section in Functionality.md](Functionality.md#dependencies) for feature-specific details.

## Important notes

- BASH Addins is a work in progress. Please keep backups and review commands before using bulk rename, delete, resize, PDF replacement, RAM-drive or autologin functions.
- GUI automation functions are primarily for X11/Xorg. They may not work under Wayland.
- Some functions require `sudo` and will ask for your administrator password.
- Network information functions contact the service named in their description.

## Updating and compiling

Download current modules, compile and install them:

```bash
./installer update
```

Compile the module files already present locally:

```bash
./installer compile
```

Reload the installed library in the current Terminal:

```bash
reload
```

## Demonstration

[Watch the BASH Addins demonstration video on Odysee](https://odysee.com/@A-Computer-Service:e/bash.addins:6).

## Contributing

Contributions, bug reports and clearer examples are welcome:

1. Fork the repository.
2. Create a feature branch.
3. Make and test your changes.
4. Push the branch.
5. Open a pull request.

## Contact

- Email: `artto@tuta.com`
- Telegram: `@divineloveartto`

## License

BASH Addins is licensed under the [MIT License](LICENSE). It is free software: you may use, study, modify and share it.

_With Love from Artto_
