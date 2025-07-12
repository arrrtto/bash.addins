# bash.addins

Enhanced bash scripting library with modular functionality for GNU/Linux operating systems, started by Artto Aunap (https://github.com/arrrtto) in 2025 for personal use, but in 2025 decided to share with the GNU/Linux and FOSS community.

The whole point of it is to load additional useful alias commands and functions (as commands) into Terminal or BASH scripts, to simplify the use of various processes regarding files, windows, texts processings, RegEx, etc.

BASH Addins is intended to work as one singular file containing all the functions and aliases, and that file (bash.addins) is supposed to be on a PATH (e.g. in ~/bin folder) and get loaded into Terminal when Terminal is opened (that happens automatically during installation below, as "source bash.addins" is added into .bashrc file). That file gets generated and put into its correct location ("installed") when using the installer (see below).

Adding "source bash.addins" command can also be added into own local BASH scripts to use the available BASH Addins functions. Many of such functions are meant to be used with command piping (e.g. those regex commands).


BASH Addins is a work in progress and far from "complete". It already does a lot, even though there may be bugs or missing features :)
Happy using, and contributing via GitHub, if you want to help make BASH Addins better! :)

## Dependencies as of right now
qrencode ffmpeg wget sane-utils imagemagick ghostscript xdotool curl csvkit imagemagick wmctrl xclip x11-apps tesseract-ocr scrot gnome-screenshot jq python3-full python3-xlsxwriter python3-openpyxl python3-odf python3-pdfkit csvkit html2text docx2txt xlsx2csv mupdf unoconv libreoffice libreoffice-script-provider-python sox pdftk

## Features / Modules
:: BASH Addins is organized into several modules, that contain functions/aliases that get combined into the bash.addins file, when running ./installer setup or ./installer compile

- `main.sh`: Basic stuff for the bash.addins to work
- `aliases.sh`: Contains various useful aliases to use in Terminal
- `system.sh`: System utilities and process management
- `text.sh`: Text processing and RegEx functions
- `gui.sh`: GUI window management
- `media.sh`: Audio/Video/Image processing
- `crypto.sh`: Cryptocurrency related utilities


## Installation of BASH Addins using the installer script

1. Download the installer:
```bash
wget https://raw.githubusercontent.com/arrrtto/bash.addins/main/installer
```

2. Make the installer script executable:
```bash
chmod +x ./installer
```

3. Run setup to install necessary additional software packages (dependencies) (works for Debian based systems currently) and to automatically generate the bash.addins file from modules:
```bash
./installer setup
```

or just run ./installer to see what other options there are, if you like. After a successful installation you should have a ~/bin/bash.addins file and it automatically loaded next time you open Terminal. Then you can start using the functions and aliases. 


## Usage of BASH Addins after a successful installation

```bash
# Show available functions and their descriptions
showallfunctions

# Show available aliases
showaliases
```

## Module Documentation

Each module has its own documentation and versioning info inside the module files themselves. Check the specific module documentation for detailed usage instructions or run showallfunctions or showaliases

There will also be a demonstrational video made soon on how to use BASH Addins and its various functionalities. The link will also be updated here into this Readme by Artto.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. Overall it is free software, as defined by Free Software Foundation - free to modify, to benefit humanity.


// With Love from Artto (July 2025)
