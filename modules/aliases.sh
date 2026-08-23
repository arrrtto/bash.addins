#!/bin/bash

# Aliases module
MODULE_NAME="aliases"
MODULE_VERSION="1.2"
MODULE_DESCRIPTION="All kinds of aliases for various purposes to simplify life :)"

alias cls='clear'
alias cleanup='sudo journalctl --rotate && sudo journalctl --vacuum-time=7d && sudo apt clean && sudo apt autoremove'
alias distro='cat /etc/os-release'
alias grep='grep --color=auto'
alias installdeb='sudo dpkg -i'
alias ipaddress_public='wget https://ipinfo.io/ip -qO -'
alias fixupdate='sudo apt install -f'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias lsdir="find . -maxdepth 1 -type d | sort | sed 's/.\///g'"            # List only folders in the current folder/directory, sorted A-Z
alias lsfiles="find . -maxdepth 1 -type f | sort | sed 's/.\///g'"            # List only files in the current folder/directory, sorted A-Z
alias lsfolders='lsdir'
alias mkdir='mkdir -p'                                                      # Create a folder only if it does not exist
alias setup='sudo dpkg -i'
alias uninstall='sudo apt remove'
alias uninstall_totally='sudo apt purge'
alias update='sudo apt update && sudo apt upgrade -y'                       # Here we could set up a similar IF function to test if apt is installed or not (e.g. Arch Linux)
alias week='date +"Current week number: %V"'
alias datetime='date +"%Y-%m-%d_%H.%M"'                         # Format datetime as yyyy-mm-dd_HH.MM

function ipaddress_local() {
# Shows the currently detected local IP address or addresses.
hostname -I 2>/dev/null | awk '{$1=$1; print}'
}

function findfile() {
# Finds files and folders below the current directory whose name contains the given text.
# Example: findfile invoice
local term="${1:-}"
[[ -n "$term" ]] || { echo "Usage: findfile <name-text>" >&2; return 2; }
find . -iname "*$term*" -print
}

function findtext_insidefiles() {
# Finds literal text inside files below the current directory.
# Example: findtext_insidefiles "customer number"
local text="${1:-}"
[[ -n "$text" ]] || { echo "Usage: findtext_insidefiles <literal-text>" >&2; return 2; }
grep -rF --exclude-dir=.git -- "$text" .
}
