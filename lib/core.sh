#!/bin/bash

# Core configuration
BA_VERSION="1.04"
BA_NAME="bash.addins"
BA_DESCRIPTION="Enhanced bash scripting library"
BA_AUTHOR="Artto Aunap"
BA_LICENSE="MIT"

# Core functions
function show_help() {
    cat << EOF
${BA_NAME} v${BA_VERSION}
${BA_DESCRIPTION}

Usage:
  ${BA_NAME} [command]

Available commands:
  help      Show this help message
  setup     Install and setup bash.addins
  update    Update bash.addins to latest version
  version   Show current version

For more information about specific modules, run:
  ${BA_NAME} module_name help
EOF
}

function setup_bash_addins() {
    # Check dependencies
    check_dependencies
    
    # Add to bashrc
    add_to_bashrc
    
    # Install dependencies
    install_dependencies
    
    echo "Setup complete! Reload your shell to apply changes."
}

function check_dependencies() {
    local required=("bash" "sed" "awk" "grep" "curl")
    for dep in "${required[@]}"; do
        if ! command -v "$dep" > /dev/null 2>&1; then
            echo "Error: Required dependency '$dep' not found"
            exit 1
        fi
    done
}

function add_to_bashrc() {
    if ! grep -q "bash.addins.sh" ~/.bashrc; then
        echo "# bash.addins configuration" >> ~/.bashrc
        echo "source $(realpath "$0")" >> ~/.bashrc
        echo "bash.addins added to .bashrc"
    else
        echo "bash.addins already in .bashrc"
    fi
}

function install_dependencies() {
    # Install all the dependencies (should get installed well at least on Debian based systems)
    sudo apt install -y qrencode ffmpeg wget libheif1 sane-utils imagemagick ghostscript xdotool curl csvkit imagemagick wmctrl xclip x11-apps tesseract-ocr scrot gnome-screenshot jq python3-full python3-xlsxwriter python3-openpyxl python3-odf python3-pdfkit csvkit html2text docx2txt xlsx2csv mupdf unoconv libreoffice-script-provider-python sox pdftk
}

function ba_versioncheck() {
    # Checks for a newer version of the BASH Addins library on GitHub
    mkdir -p /tmp
    echo "Checking GitHub for a newer version..."
    curl -s "https://github.com/arrrtto/bash.addins/blob/main/bash.addins" > /tmp/ba.ver
    local ba_githubversion=$(cat /tmp/ba.ver | grep -oP 'ba_version=........' | grep -oP '\d+\.\d+')
    rm /tmp/ba.ver
    
    # Compare the versions as arithmetic values
    if [[ "$(printf '%s\n' "$BA_VERSION" "$ba_githubversion" | sort -V | head -n 1)" != "$ba_githubversion" ]]; then
        echo "Newer version of the BASH addins library ($ba_githubversion) available on GitHub."
    else
        echo "You have the newest version already :)"
    fi
}

function ba_setup() {
    # For setting up the files, folder structure, configurations (paths) and installing software dependencies
    local bashrc_file="$HOME/.bashrc"
    local new_lines=$(cat <<EOF
export PATH=\$PATH:/home/\$USER/bin
source bash.addins
EOF
)

    if ! grep -q "bash.addins" "$bashrc_file"; then
        echo "$new_lines" >> "$bashrc_file"
        echo ".bashrc has been updated with new environment variables."
    fi

    mkdir -p /home/$USER/bin
    if [[ $BA_RUNNING_FOLDER != "/home/$USER/bin" ]]; then
        cp "$BA_RUNNING_FOLDER/bash.addins" "/home/$USER/bin/bash.addins"
        chmod +x "/home/$USER/bin/bash.addins"
    fi

    install_dependencies
}
