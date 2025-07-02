#!/bin/bash

# System module configuration
MODULE_NAME="system"
MODULE_VERSION="1.0"
MODULE_DESCRIPTION="System utilities and process management"

# System aliases
alias cls='clear'
alias distro='cat /etc/os-release'
alias grep='grep --color=auto'
alias installdeb='sudo dpkg -i'
alias ipaddress_local="echo $(ifconfig | grep broadcast | awk '{print $2}')"
alias ipaddress_public='wget https://ipinfo.io/ip -qO -'
alias findfile='find . -print | grep -i $2'
alias findtext_insidefiles='grep -r $1'
alias fixupdate='sudo apt install -f'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias lsdir="find . -maxdepth 1 -type d | sort | sed 's/.///g'"            # List only folders in the current folder/directory, sorted A-Z
alias lsfiles="find . -maxdepth 1 -type f | sort | sed 's/.///g'"            # List only files in the current folder/directory, sorted A-Z
alias lsfolders='lsdir'
alias mkdir='mkdir -p'                                                      # Create a folder only if it does not exist
alias setup='sudo dpkg -i'
alias showfunctions='showallfunctions'
alias update='sudo apt update && sudo apt -y upgrade'

# System functions
function countdown_minutes() {
    # Counts down from a specified number of minutes, displaying the remaining time.
    # Example: countdown_minutes 5
    count=${1?No parameters given. Try countdown_minutes 5}
    (( ++count )) 
    while (( --count >= 0 )); do
        echo "Time remaining: $((count/60)) minutes and $((count%60)) seconds"
        sleep 1
    done
}

function randomnumber() {
    # Generates a random number between 1 and specified maximum (default 100).
    # Example: randomnumber 50    ; generates a random number between 1 and 50
    local max=${1:-100}
    echo $((RANDOM % max + 1))
}

function whatnext() {
    # Shows a random motivational message.
    local messages=(
        "What's next? Keep going!"
        "Think outside the box"
        "Always believe in something bigger"
        "The future is what you make it"
        "Dream big, act bigger"
    )
    echo "${messages[$RANDOM % ${#messages[@]}]}"
}

function showallfunctions() {
    local file=$(which bash.addins)
    local RED='\033[0;31m'      # for function names
    local LIGHT_GRAY='\033[0;37m'  # for comments
    local NC='\033[0m'          # no Color

    awk -v red="$RED" -v gray="$LIGHT_GRAY" -v nc="$NC" ' 
    /^function/ {
        func_name = $2;  
        sub(/[(]/, "", func_name);  
        sub(/[)]/, "", func_name);  
        if (func_name ~ /^ba_/) next;  
        printf "%s%s%s\n", red, func_name, nc;  
        getline;  
        while ($0 ~ /^#/) {  
            printf "%s%s%s\n", gray, $0, nc;  
            getline;  
        }
        print "";  
    }
    ' "$file"
}

function showaliases() {
    cat $(which bash.addins) | grep -E "alias "
}

function functions_amount(){
    showallfunctions | grep -Ev "#" | sed_removeemptylines | wc -l
}

function reload() {
    source bash.addins
}

function all() {
    while IFS= read -r file; do [[ -f "$file" ]] && echo "$file"; done
}

function freememory() {
    echo "Freeing memory..."
    sudo sysctl -w vm.drop_caches=3
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    echo "Memory freed."
}

function freespace() {
    df -h
}

function exa() {
    # Executes a command and displays the output with execution time.
    # Example: exa "ls -l"
    local cmd="$1"
    echo "Executing: $cmd"
    /usr/bin/time -f "\nExecution time: %E" $cmd
}

function exc() {
    # Executes a command and displays the output with execution time and memory usage.
    # Example: exc "ls -l"
    local cmd="$1"
    echo "Executing: $cmd"
    /usr/bin/time -f "\nExecution time: %E\nMemory usage: %M KB" $cmd
}

function systeminfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Distribution: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '"')"
    echo "Uptime: $(uptime -p)"
    echo "Memory: $(free -h | grep Mem)"
    echo "CPU: $(lscpu | grep "Model name")"
    echo "Disk Usage: $(df -h / | grep /)"
}

function bigfiles() {
    find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -rh
}

function replace_extension() {
    local file="$1"
    local new_ext="$2"
    mv "$file" "${file%.*}.$new_ext"
}

function replace_spaces() {
    local file="$1"
    mv "$file" "${file// /_}"
}

function check_process() {
    ps aux | grep "$1" | grep -v grep
}

function kill_process() {
    killall "$1"
}

function kill_zombieprocesses_chromium() {
    killall chromium-browser
}

function wait4download() {
    local file="$1"
    while [ ! -f "$file" ]; do
        sleep 1
    done
    echo "$file is ready"
}

# Module initialization
function init_${MODULE_NAME}_module() {
    true
}

# Module help
function ${MODULE_NAME}_help() {
    cat << EOF
${MODULE_NAME} module v${MODULE_VERSION}
${MODULE_DESCRIPTION}

Available functions:
  showallfunctions   Show all available functions
  showaliases        Show all aliases
  freememory         Free system memory cache
  freespace          Show disk space usage
  systeminfo         Show system information
  bigfiles           List large files
  replace_extension  Replace file extension
  replace_spaces     Replace spaces in filename
  check_process      Check if process is running
  kill_process       Kill process by name
  wait4download      Wait for file download
EOF
}

# Initialize module
init_${MODULE_NAME}_module
