#!/bin/bash

# Aliases module
MODULE_NAME="aliases"
MODULE_VERSION="1.04"
MODULE_DESCRIPTION="All kinds of aliases for various purposes to simplify life :)"

alias cls='clear'
alias distro='cat /etc/os-release'
alias grep='grep --color=auto'
alias installdeb='sudo dpkg -i'
if which ifconfig >/dev/null 2>&1; then alias ipaddress_local="echo $(ifconfig | grep broadcast | awk '{print $2}')"; fi # Only if ifconfig is installed in the system, create the alias
alias ipaddress_public='wget https://ipinfo.io/ip -qO -'
alias findfile='find . -print | grep -i $2'
alias findtext_insidefiles='grep -r $1'
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



