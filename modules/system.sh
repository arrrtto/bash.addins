#!/bin/bash

# General system module
MODULE_NAME="system"
MODULE_VERSION="1.04"
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


function check_process() {
# Checks if a specified app (process) is running and outputs its status.
# Example: check_process brave    ; outputs "'$process' is running."
local process="$1"
if pgrep -x "$process" > /dev/null; then
  echo "$process is running"
else
  echo "$process is not running"
fi
}


function kill_process() {
# Kills a specified process by name.
# Example: kill_process chromium
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


