#!/bin/bash

# General system module
MODULE_NAME="system"
MODULE_VERSION="1.07"
MODULE_DESCRIPTION="System utilities, files and process management"


function showallfunctions() {
# Lists all the functions that the bash.addins contains.
local file=$(which bash.addins)
local RED='\033[0;31m'      # for function names
local LIGHT_GRAY='\033[0;37m'  # for comments
local NC='\033[0m'          # no Color

awk -v red="$RED" -v gray="$LIGHT_GRAY" -v nc="$NC" ' # Read the file and extract functions and comments
/^function/ {
    func_name = $2;  # Get the function name
    sub(/[(]/, "", func_name);  # Remove the ( from the function name
    sub(/[)]/, "", func_name);  # Remove the ) from the function name
    if (func_name ~ /^ba_/) next;  # Skip functions starting with "ba_"
    printf "%s%s%s\n", red, func_name, nc;  # Print the function name in red
    getline;  # Move to the next line
    while ($0 ~ /^#/) {  # While the line starts with #
        printf "%s%s%s\n", gray, $0, nc;  # Print the comment line in light gray
        getline;  # Move to the next line
    }
    print "";  # Print a blank line for separation
}
' "$file"
}


function functions_amount(){
# Outputs the number of all available functions.
showallfunctions | grep -Ev "#" | sed_removeemptylines | wc -l
}


function reload() {
# Reloads the BASH Add-ins library file by executing: source bash.addins
source bash.addins
}


function all() {
# Lists all files in the current folder as a raw list, while skipping the folders.
# Example: ls | all
while IFS= read -r file; do [[ -f "$file" ]] && echo "$file"; done
}


function countdown_minutes() {
# Counts down from a specified number of minutes, displaying the remaining time.
# Example: countdown_minutes 5
count=${1?No parameters given. Try countdown_minutes 5}
(( ++count )) 
while (( --count >= 0 )); do
# using echo -ne and \r (carriage return) to overwrite the same line instead of printing a new one each time.
# The extra spaces ("  ") at the end ensure the previous text is fully cleared when the number shrinks.
  echo -ne "\r$count minutes left to wait.  "
  sleep 60
done
echo ""  # Move to a new line after the loop finishes
}


function randomnumber() {
# Generates random number for you between your desired numbers, such as between 1 and 1500.
# Example: randomnumber 5 250
if [ -z "$1" ]; then
echo "Generates random number for you between your desired numbers, such as between 1 and 1500."
echo "Example usage: randomnumber 5 250"
return 1
fi
local min=$1
local max=$2
expr $min + $RANDOM % $max
}


function sleeprandom() {
# Generates a random number between 0-9 and sleeps (waits) for that random number of seconds.
# Useful for automation scripts to mimic "human waiting times".
local random_number=$(( RANDOM % 10 ))
sleep "$random_number"
}


function whatnext() {
# Waits for user input. Good to use after or before a certain process in a BASH script.
read -p "Do you want to continue? (y/n): " choice
case "$choice" in 
  y|Y ) 
    echo "Continuing...";;
  n|N ) 
    echo "Exiting..."
    exit 1;;
  * ) 
    echo "Invalid input. Please enter y or n."
    exit 1;;
esac
}



function whatdate() {
    # Check minimum args
    if [ $# -lt 3 ]; then
        echo "Usage: whatdate <number> <unit> [<number> <unit> ...] <ago|ahead>"
        echo "Example: whatdate 2 months 3 days ago"
        echo "Example: whatdate 1 week ahead"
        return 1
    fi

    # Get direction (last argument)
    direction=${@: -1}

    # Determine direction symbol
    case "$direction" in
        ago) op="-" ;;
        ahead) op="+" ;;
        *) echo "Invalid direction. Use 'ago' or 'ahead'."; return 1 ;;
    esac

    # Build the time expression (everything except the last argument)
    args=("${@:1:$#-1}")

    # Normalize units and rebuild time expression
    time_expr=""
    for ((i=0; i<${#args[@]}; i+=2)); do
        num=${args[i]}
        unit=${args[i+1]}
        # Normalize plural/singular
        case "$unit" in
            hour|hours)   u="hour" ;;
            day|days)     u="day" ;;
            week|weeks)   u="week" ;;
            month|months) u="month" ;;
            year|years)   u="year" ;;
            *) echo "Invalid unit '$unit'. Use hours, days, weeks, months, or years."; return 1 ;;
        esac
        time_expr+=" $op$num $u"
    done

    # Calculate date
    result=$(date -d "$time_expr" +"%d.%m.%Y" 2>/dev/null)

    if [ -z "$result" ]; then
        echo "Error calculating date."
        return 1
    fi

    echo "$result"
}





# ------------ SYSTEM RELATED ------------

function systeminfo() {
# Displays comprehensive system information, including OS details, RAM memory, CPU and disk usage.
clear
local RED='\033[0;31m'
local GREEN='\033[0;32m'
local YELLOW='\033[0;33m'
local BLUE='\033[0;34m'
local NC='\033[0m' # No Color

local cpu_model=$(lscpu | grep "Model name" | awk -F: '{print $2}' | xargs)
local install_date=$(ls -ld / | awk '{print $7".", $6, $8}')
local total_mem=$(free -h | grep Mem | awk '{print $2}' | sed 's/Gi/ GB/')
local available_mem=$(free -h | grep Mem | awk '{print $7}' | sed 's/Gi/ GB/')
local os_info=$(lsb_release -d | awk -F: '{print $2}' | xargs)
local os_version=$(lsb_release -d | awk -F: '{print $2}' | xargs | sed_keep_price)
local os_mint=$(lsb_release -d | grep -o 'Mint')
local kernel_version=$(uname -r)
local uptime_info=$(uptime -p)
local hostname_info=$(hostname)

curl -sX 'GET' "https://endoflife.date/api/v1/products/linuxmint" -H "accept: application/json" > /tmp/eolapi.json
releases=() && while read -r r; do releases+=("$r"); done < <(jq -r '.result.releases[].name' /tmp/eolapi.json)
counter="0"
for version_number in ${releases[@]}; do
 if [[ $version_number = $os_version ]]; then break; fi  # scan through the version numbers
 counter=$((counter + 1))
done

echo -e "${BLUE}Operating System:${NC} $os_info"
echo -e "${YELLOW}Installation Date:${NC} $install_date"
if [[ $version_number != "" ]] && [[ $os_mint == "Mint" ]]; then echo -e "${YELLOW}End of Support:${NC}" $(jq -r ".result.releases["$counter"].eolFrom" /tmp/eolapi.json); fi
echo -e "${YELLOW}Kernel Version:${NC} $kernel_version"
echo -e "${YELLOW}Uptime:${NC} $uptime_info"
echo -e "${YELLOW}Hostname:${NC} $hostname_info"
echo -e "${GREEN}CPU Model:${NC} $cpu_model"
echo -e "${GREEN}Total Memory:${NC} $total_mem | out of which $available_mem is available" | sed_comma2dot
echo -e "${BLUE}Disks:${NC}"
df -h | grep "^/" | grep -Ev "boot" | awk '{print $1" -", $2"B total", "|", $4"B free"}' | sed_comma2dot
echo
echo
if [[ -f /tmp/eolapi.json ]]; then rm /tmp/eolapi.json; fi  # delete the json file, if it exists
}


function freememory() {
# Shows RAM memory information.
mem=$(free -h | grep Mem)
swap=$(free -h | grep Swap)

# Extract total and available memory values
total_mem=$(echo $mem | awk '{print $2}' | sed 's/Gi/ GB/')
available_mem=$(echo $mem | awk '{print $7}' | sed 's/Gi/ GB/')

# Extract total and free swap values
total_swap=$(echo $swap | awk '{print $2}' | sed 's/Gi/ GB/')
free_swap=$(echo $swap | awk '{print $4}' | sed 's/Gi/ GB/')

# Format and display the output
echo "Available RAM: $available_mem of $total_mem" | sed_comma2dot
echo "Available Swap: $free_swap of $total_swap" | sed_comma2dot
}


function freespace() {
# Shows free (available) disk space.
df -h | grep "^/" | grep -Ev "boot" | awk '{print "Free space on", $1":", $4"B"}'
}


function process_check() {
# Checks if a specified app (process) is running and outputs its status.
# Example: process_check brave    ; outputs "'$process' is running."
local process="$1"
if pgrep -x "$process" > /dev/null; then
  echo "$process is running"
else
  echo "$process is not running"
fi
}


function process_kill() {
# Kills a specified process by name.
# Example: process_kill chromium
pid=$(pgrep -f $1) # Find the PID of the given process
# Send a SIGTERM signal (graceful close)
if [[ ! -z "$pid" ]]; then kill -SIGTERM "$pid"; fi
}

function kill_zombieprocesses_chromium(){
# Kills/removes all the Chromium browser processes, including the zombie ones.
ps -eo pid,ppid,state,comm | awk '$3=="Z" && $4=="chromium" {print $2}' | sort -u | xargs -r kill -9
}

function bigfiles() {
# Finds and lists files in the current folder and subfolders that exceed a specified size.
# Example: bigfiles +1G
# Example: bigfiles +200M
if [ -z "$1" ]; then
echo "Finds and lists you all files in the current folder and subfolders, with your set minimum size."
echo "And it also sorts the list from the largest to smallest."
echo "Usage: bigfiles +SIZE[G|M|k]"
echo "Example: bigfiles +1G or bigfiles +500M or bigfiles 200k"
return 1
fi
find . -type f -size "$1" -exec du -h {} + 2>/dev/null | sort -hr
}


function list() {
# Meant for listing the contents of a text file, where is supposed to be a list of files, and then processing those files in a certain manner.
local input_file="$1"
local action="$2"
shift 2

# Usage info
if [[ -z "$input_file" || -z "$action" ]]; then
echo "Usage: list <file-with-paths> <action> [extra-args...]"
echo
echo "Actions:"
echo "  echo             Print each file path"
echo "  delete           Delete files"
echo "  size             Show file sizes (du -h)"
echo "  basename         Show only the filename"
echo "  dirname          Show only the directory"
echo "  exists           Check if file exists"
echo "  copy <dir>       Copy files into directory"
echo "  move <dir>       Move files into directory"
echo "  chmod <mode>     Change permissions (e.g. 644)"
echo "  exec <command>   Run command on each file (e.g. 'file', 'md5sum')"
echo
echo "Examples:"
echo "  list fileslist.txt echo"
echo "  list fileslist.txt delete"
echo "  list fileslist.txt copy /tmp/backup"
echo "  list fileslist.txt exec md5sum"
return 1
fi

if [[ ! -f "$input_file" ]]; then echo "Error: file '$input_file' not found."; return 1; fi

while IFS= read -r file; do
    case "$action" in
            echo)
                echo "$file"
                ;;
            delete)
                rm -v -- "$file"
                ;;
            size)
                du -h -- "$file"
                ;;
            basename)
                basename -- "$file"
                ;;
            dirname)
                dirname -- "$file"
                ;;
            exists)
                [[ -e "$file" ]] && echo "Exists: $file" || echo "Missing: $file"
                ;;
            copy)
                cp -v -- "$file" "$1"
                ;;
            move)
                mv -v -- "$file" "$1"
                ;;
            chmod)
                chmod "$1" -- "$file"
                ;;
            exec)
                "$@" "$file"
                ;;
            *)
                echo "Unsupported action: $action"
                echo "For usage help, just type: list"
                return 1
                ;;
    esac
done < "$input_file"
}



function replace_extension() {
# Replaces the file extension of all files with a specified old extension to a new extension.
# Example: replace_extension jpg.txt txt   ; that renames "jpg.txt" extension to "txt"
old_ext="$1"
new_ext="$2"
if [[ -z "$old_ext" || -z "$new_ext" ]]; then
echo "Usage example: replace_extension jpg.txt txt"
return 1
fi
shopt -s nullglob  # avoid literal glob if no match
for file in *."$old_ext"; do
base="${file%.$old_ext}"
new_file="${base}.${new_ext}"
mv -- "$file" "$new_file"
done
}


function replace_spaces() {
# Replaces spaces in filenames with underscores (_ characters) in a specified folder.
# Example: replace_spaces ~/Downloads
local folder=${1?No input given for the folder} # Check if the folder is empty
if [ -z "$folder" ]; then return 0; fi  # Do nothing if no folder is provided
folder="${folder%/}" # Normalize folder path by removing trailing slash if present. No need, but for perfection sake
find "$folder/" -maxdepth 1 -type f -iname "*" | while IFS= read -r file; do
if [[ "$file" =~ \  ]]; then new_name="${file// /_}"; mv "$file" "$new_name"; fi
done
}


function replace_nordic_chars() {
# Replaces Nordic characters like õüäö to ouao in filenames in a specified folder.
# Example: replace_nordic_chars ~/Downloads
local folder=${1?No input given for the folder} # Check if the folder is empty
if [ -z "$folder" ]; then return 0; fi  # Do nothing if no folder is provided
folder="${folder%/}" # Normalize folder path by removing trailing slash if present. No need, but for perfection sake
find "$folder/" -maxdepth 1 -type f -iname "*" | while IFS= read -r file; do
mv "$file" "$(echo "$file" | sed 's/ä/a/g; s/ü/u/g; s/õ/o/g; s/ö/o/g')"
done
}


#####################################
# WAIT4 UTILITIES — standardized set
# All follow the same style and argument checks
#####################################

function wait4download() {
# Waits for a download to complete by checking for .crdownload files in the Downloads folder.
# Example: wait4download
DOWNLOAD_DIR="/home/$USER/Downloads"
tempfile=$(find "$DOWNLOAD_DIR" -name "*.crdownload" | head -n 1)    # Find the file with .crdownload extension (assuming only one active download)
if [ -n "$tempfile" ]; then    # Check if the download process has started (i.e., a .crdownload file exists)
  echo "Downloading... $tempfile"
finalfile="${tempfile%.crdownload}"    # Extract the expected final file name (remove .crdownload)
while [ -f "$tempfile" ]; do sleep 5; done    # Loop until the .crdownload file disappears and final file exists
if [ -f "$finalfile" ]; then    # Once loop exits, check if the final file exists
 echo "$finalfile downloaded!"
else
 echo "$finalfile cannot be found at all. Did it even get downloaded?"
fi
else
 echo "No .crdownload files found, so possibly nothing is downloading to Downloads folder at the moment."
fi
}


function wait4process_start() {
# Waits for a specific process to start running.
# Example: wait4process_start firefox
local process="$1"
if [ -z "$process" ]; then
  echo "Usage: wait4process_start process_name"
  return 1
fi
echo "Waiting for process '$process' to start..."
while ! pgrep -x "$process" >/dev/null; do sleep 2; done
echo "Process '$process' started!"
}


function wait4process_stop() {
# Waits for a specific process to stop running.
# Example: wait4process_stop firefox
local process="$1"
if [ -z "$process" ]; then
  echo "Usage: wait4process_stop process_name"
  return 1
fi
echo "Waiting for process '$process' to stop..."
while pgrep -x "$process" >/dev/null; do sleep 2; done
echo "Process '$process' stopped."
}


function wait4window() {
# Waits until a window with the given title appears.
# Example: wait4window "Telegram"
local title="$1"
if [ -z "$title" ]; then
  echo "Usage: wait4window \"Window Title\""
  return 1
fi
echo "Waiting for window titled '$title'..."
while ! xdotool search --name "$title" >/dev/null 2>&1; do sleep 2; done
echo "Window '$title' found."
}


function wait4window_close() {
# Waits until a window with the given title closes.
# Example: wait4window_close "Telegram"
local title="$1"
if [ -z "$title" ]; then
  echo "Usage: wait4window_close \"Window Title\""
  return 1
fi
if ! xdotool search --name "$title" >/dev/null 2>&1; then
  echo "Window '$title' not found — already closed?"
  return 0
fi
echo "Waiting for window titled '$title' to close..."
while xdotool search --name "$title" >/dev/null 2>&1; do sleep 2; done
echo "Window '$title' closed."
}


function wait4file() {
# Waits for a file to appear in the filesystem.
# Example: wait4file /home/user/Downloads/file.txt
local filepath="$1"
if [ -z "$filepath" ]; then
  echo "Usage: wait4file /path/to/file"
  return 1
fi
echo "Waiting for file '$filepath'..."
while [ ! -f "$filepath" ]; do sleep 2; done
echo "File '$filepath' found!"
}


function wait4file_gone() {
# Waits until a file disappears (deleted or moved).
# Example: wait4file_gone /home/user/Downloads/file.txt
local filepath="$1"
if [ -z "$filepath" ]; then
  echo "Usage: wait4file_gone /path/to/file"
  return 1
fi
if [ ! -e "$filepath" ]; then
  echo "File '$filepath' already gone."
  return 0
fi
echo "Waiting for file '$filepath' to disappear..."
while [ -e "$filepath" ]; do sleep 2; done
echo "File '$filepath' is gone."
}


function wait4file_ready() {
# Waits until a file stops changing in size AND is no longer opened by any process.
# Example: wait4file_ready /home/$USER/Videos/render.mp4
local filepath="$1"
local stable_checks=3  # how many consecutive unchanged size checks to confirm readiness

if [ -z "$filepath" ]; then
  echo "Usage: wait4file_ready /path/to/file"
  return 1
fi

if [ ! -f "$filepath" ]; then
  echo "File '$filepath' not found."
  return 1
fi

echo "Waiting for file '$filepath' to finish writing..."
local last_size=0
local unchanged=0

# --- Phase 1: Wait until file size is stable ---
while true; do
  local size=$(stat -c%s "$filepath" 2>/dev/null)
  if [ "$size" -eq "$last_size" ]; then
    ((unchanged++))
  else
    unchanged=0
  fi

  if [ "$unchanged" -ge "$stable_checks" ]; then
    echo "File size has stabilized (unchanged for $stable_checks checks)."
    break
  fi

  last_size=$size
  sleep 2
done

# --- Phase 2: Wait until file is released by all processes ---
echo "Checking if any processes are still using '$filepath'..."
while lsof "$filepath" >/dev/null 2>&1; do
  echo "File is still open by some process... waiting..."
  sleep 2
done

echo "File '$filepath' is ready."
}


function wait4network() {
# Waits until there is an active internet connection.
# Example: wait4network
echo "Waiting for internet connection..."
until ping -c1 8.8.8.8 &>/dev/null; do sleep 3; done
echo "Internet connection is active."
}


function wait4updates_apt() {
# Waits until APT or dpkg is not locked by another process.
# Example: wait4updates_apt
echo "Waiting for apt/dpkg lock to be released..."
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1 || \
      sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
  sleep 3
done
echo "APT is ready."
}


function wait4mount() {
# Waits until a given mount point is mounted.
# Example: wait4mount /media/usb
local mountpoint="$1"
if [ -z "$mountpoint" ]; then
  echo "Usage: wait4mount /mount/point"
  return 1
fi
echo "Waiting for mount point '$mountpoint'..."
while ! mount | grep -q "$mountpoint"; do sleep 2; done
echo "'$mountpoint' mounted."
}


function wait4unmount() {
# Waits until a given mount point is unmounted.
# Example: wait4unmount /media/usb
local mountpoint="$1"
if [ -z "$mountpoint" ]; then
  echo "Usage: wait4unmount /mount/point"
  return 1
fi
echo "Waiting for '$mountpoint' to unmount..."
while mount | grep -q "$mountpoint"; do sleep 2; done
echo "'$mountpoint' unmounted."
}


function wait4cpu_idle() {
# Waits until CPU usage drops below a given threshold (default 20%).
# Example: wait4cpu_idle 15
local threshold=${1:-20}
echo "Waiting for CPU usage to drop below ${threshold}%..."
while true; do
  local usage=$(awk -v t=$threshold '/^%Cpu/ {print 100 - $8}' <(top -bn1))
  if (( ${usage%.*} < threshold )); then break; fi
  sleep 5
done
echo "CPU is idle (below ${threshold}%)."
}


function wait4app_idle() {
# Waits until a specific process has near-zero CPU usage.
# Example: wait4app_idle kdenlive 5
local process="$1"
local threshold=${2:-5}  # CPU threshold in percent
if [ -z "$process" ]; then
  echo "Usage: wait4app_idle process_name [CPU threshold number in percentage]"
  return 1
fi

echo "Waiting for '$process' to become idle (below ${threshold}% CPU)..."
while true; do
  local pid=$(pgrep -x "$process" | head -n1)
  [ -z "$pid" ] && { echo "Process '$process' not running."; return 1; }

  local cpu=$(ps -p "$pid" -o %cpu= | awk '{print int($1)}')
  if (( cpu < threshold )); then
    echo "'$process' is idle."
    break
  fi
  sleep 2
done
}


function wait4time() {
# Waits until the system clock reaches the given time (HH:MM)
# Example: wait4time 16:00
    local target_time="$1"
    if [[ ! "$target_time" =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
        echo "Usage: wait4time HH:MM"
        echo "Example: wait4time 16:00"
        return 1
    fi

    echo "Waiting until $target_time..."
    while true; do
        local now
        now=$(date +"%H:%M")
        if [[ "$now" == "$target_time" ]]; then
            echo "Reached $target_time!"
            break
        fi
        sleep 1
    done
}



function press() {
# Function for sending a keyboard stroke with xdotool (to the currently focused window). 
# Ex.: press "alt+r", "Control_L+J", "ctrl+alt+n", BackSpace, space, shift, super, meta, Return, F2, Up, Down
# Ex.: to send Ctrl+L and then BackSpace as separate keystrokes one after another: press ctrl+l BackSpace
xdotool key "$@"
}

function type_into() {
xdotool type "$@"
}

function enter_text() {
xdotool type "$@"
}


