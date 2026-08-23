#!/bin/bash

# General system module
MODULE_NAME="system"
MODULE_VERSION="1.09"
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


function is_number() {
# Function meant to work for diffnum() and numgt, numge, numlt, numle to make sure the number format is good
# Accepts: 123 | 123.45 | 0.5 | .5 | 5.
# Rejects: 0,5 | 50 000 | 5.000.000 | abc
    [[ "$1" =~ ^[0-9]*\.?[0-9]+$ ]] || [[ "$1" =~ ^[0-9]+\.?$ ]]
}

function diffnum() {
# Meant for finding the difference between 2 numbers.
# Example: diffnum 5 3.24
# Example use case: diff=$(numdiff "$balance" "$last_balance") || continue
    is_number "$1" || { echo "diffnum: invalid number '$1'" >&2; return 1; }
    is_number "$2" || { echo "diffnum: invalid number '$2'" >&2; return 1; }
    awk -v a="$1" -v b="$2" 'BEGIN { printf "%.8f", a - b }'
}

function numgt() {
# Function meant for comparing if one number is greater than another in comparison, and if so, then do something.
# Example: if numgt 2.22 0.1; then echo "greater"; fi
    is_number "$1" && is_number "$2" || return 1
    awk -v a="$1" -v b="$2" 'BEGIN { exit !(a > b) }'
}

function numge() {
# Function meant for comparing if one number is greater than another, or equal to another in comparison, and if so, then do something.
# Example: if numge 2.22 0.1; then echo "greater"; fi
# Example: if numge 5 5; then echo "equal"; fi
    is_number "$1" && is_number "$2" || return 1
    awk -v a="$1" -v b="$2" 'BEGIN { exit !(a >= b) }'
}

function numlt() {
# Function meant for comparing if one number is less than another in comparison, and if so, then do something.
# Example: if numlt 0.001 0.1; then echo "less"; fi
    is_number "$1" && is_number "$2" || return 1
    awk -v a="$1" -v b="$2" 'BEGIN { exit !(a < b) }'
}

function numle() {
# Function meant for comparing if one number is less than another, or equal to another in comparison, and if so, then do something.
# Example: if numle 0.001 0.1; then echo "less"; fi
# Example: if numle 0.001 0.001; then echo "equal"; fi
    is_number "$1" && is_number "$2" || return 1
    awk -v a="$1" -v b="$2" 'BEGIN { exit !(a <= b) }'
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


function datetimenow() {
date +"%d.%m.%Y_%H.%M"
}


function timer() {
    local input="$*"

    [[ -z "$input" ]] && {
        echo "Usage:"
        echo "timer 23.06.2026 08:00"
        echo "timer tomorrow 20:00"
        echo "today 09:00"
        echo "next friday 17:00"
        return 1
    }

    local target_epoch

    # Estonian style DD.MM.YYYY HH:MM
    if [[ "$input" =~ ^([0-9]{2})\.([0-9]{2})\.([0-9]{4})[[:space:]]+([0-9]{2}:[0-9]{2}(:[0-9]{2})?)$ ]]; then
        local d="${BASH_REMATCH[1]}"
        local m="${BASH_REMATCH[2]}"
        local y="${BASH_REMATCH[3]}"
        local t="${BASH_REMATCH[4]}"

        target_epoch=$(date -d "$y-$m-$d $t" +%s 2>/dev/null) || {
            echo "Invalid date/time."
            return 1
        }
    else
        # Let GNU date handle things like:
        # tomorrow 20:00
        # today 08:00
        # next friday 17:00
        target_epoch=$(date -d "$input" +%s 2>/dev/null) || {
            echo "Invalid date/time."
            return 1
        }
    fi

    echo "Waiting until: $(date -d "@$target_epoch" '+%d.%m.%Y %H:%M:%S')"
    while (( $(date +%s) < target_epoch )); do 
        remaining=$((target_epoch - $(date +%s)))
        (( remaining <= 0 )) && break
        if (( remaining > 300 )); then
          sleep 60
        elif (( remaining > 60 )); then
          sleep 10
        else
          sleep 1
        fi
    done
    echo "Timer finished."
}


function reminderd() {
    # Check minimum args
    if [ $# -lt 2 ]; then
        echo "Meant for sending timed reminders via ntfy.sh topic from reminders.txt"
        echo "Usage: "
        echo "reminderd /home/$USER/reminders.txt ntfytopic"
        echo "Run in background: nohup bash -c 'source ~/.bashrc; reminderd /home/$USER/reminders.txt ntfytopic' >/tmp/reminderd.log 2>&1 &"
        echo "Check log: tail -f /tmp/reminderd.log"
        echo
        echo "reminders.txt file contents format should look like:"
        echo "ONCE 23.06.2026 08:00|Car repair"
        echo "DAILY 08:00|Check Telegram groups"
        echo "DAILY 22:00|Backup server"
        echo "WEEKLY Mon 09:00|Team meeting"
        echo "MONTHLY 1 10:00|Pay bills"
        return 1
    fi

    ntfytopic="$2"
    local file="${1:-$HOME/reminders.txt}"
    local sent_file="$HOME/reminderd.sent"

    touch "$file"
    touch "$sent_file"

    while true; do
        local now_date now_time now_day now_dom now_key
        now_date=$(date '+%d.%m.%Y')
        now_time=$(date '+%H:%M')
        now_day=$(date '+%a')      # Mon, Tue, Wed...
        now_dom=$(date '+%-d')     # 1, 2, 3...

        while IFS='|' read -r rule message; do
            [[ -z "$rule" || "$rule" =~ ^# ]] && continue

            local type a b c key match
            match=false
            read -r type a b c <<< "$rule"

            case "$type" in
                ONCE)
                    # ONCE 23.06.2026 08:00
                    [[ "$a" == "$now_date" && "$b" == "$now_time" ]] && match=true
                    key="$rule|$message"
                    ;;

                DAILY)
                    # DAILY 08:00
                    [[ "$a" == "$now_time" ]] && match=true
                    key="$(date '+%Y-%m-%d')|$rule|$message"
                    ;;

                WEEKLY)
                    # WEEKLY Mon 09:00
                    [[ "$a" == "$now_day" && "$b" == "$now_time" ]] && match=true
                    key="$(date '+%Y-%m-%d')|$rule|$message"
                    ;;

                MONTHLY)
                    # MONTHLY 1 10:00
                    [[ "$a" == "$now_dom" && "$b" == "$now_time" ]] && match=true
                    key="$(date '+%Y-%m')|$rule|$message"
                    ;;
            esac

            if [[ "$match" == true ]] && ! grep -Fxq "$key" "$sent_file"; then
                echo "Reminder: $message"

                curl -s -d "$message" "https://ntfy.sh/$ntfytopic" >/dev/null

                echo "$key" >> "$sent_file"
            fi

        done < "$file"

        sleep 60
    done
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


function battery_left() {
echo "$(cat /sys/class/power_supply/BAT0/capacity)%"
}


function battery_ntfy_watch() {
# Battery low alert -> ntfy
# Requires: curl, ntfy.sh topic (or your own ntfy server)
# Works on Linux laptops with /sys/class/power_supply/*
# Usage examples:
#   battery_ntfy_watch "mytopic"                # default: threshold 10%, check every 5 seconds
#   battery_ntfy_watch "mytopic" 15 30          # threshold 15%, check every 30s
#   battery_ntfy_watch "mytopic" 10 60 "https://ntfy.my.domain"
  local topic="${1:-}"
  local threshold="${2:-10}"
  local interval="${3:-5}"
  local ntfy_base="${4:-https://ntfy.sh}"

  if [[ -z "$topic" ]]; then
    echo "Usage: battery_ntfy_watch <ntfy_topic> [threshold_percent=10] [interval_seconds=60] [ntfy_base=https://ntfy.sh]" >&2
    return 2
  fi

  command -v curl >/dev/null 2>&1 || { echo "battery_ntfy_watch: curl not found" >&2; return 3; }

  # Find a battery (BAT0/BAT1 etc)
  local bat
  bat="$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)"
  if [[ -z "$bat" ]]; then
    echo "battery_ntfy_watch: No /sys/class/power_supply/BAT* found" >&2
    return 4
  fi

  # State to avoid spamming
  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/bash-addins"
  mkdir -p "$state_dir"
  local stamp_file="$state_dir/battery_ntfy_last_sent_${topic}.ts"

  # Helper: send ntfy
  _battery_ntfy_send() {
    local title="$1"
    local msg="$2"
    local prio="${3:-4}" # 1..5 (ntfy priority)
    curl -fsS \
      -H "Title: $title" \
      -H "Priority: $prio" \
      -H "Tags: battery,warning" \
      -d "$msg" \
      "$ntfy_base/$topic" >/dev/null
  }

  # Helper: safe reads
  _readf() { [[ -r "$1" ]] && cat "$1" 2>/dev/null || echo ""; }

  # Cooldown: only notify once every N minutes while low
  local cooldown_seconds=300  # 5 min

  echo "Monitoring battery $bat (threshold <= ${threshold}%, every ${interval}s) -> $ntfy_base/$topic"

  while true; do
    local cap status
    cap="$(_readf "$bat/capacity")"
    status="$(_readf "$bat/status")"

    # Normalize (some systems give "Charging"/"Discharging"/"Full"/"Unknown")
    # We only alert when NOT charging.
    if [[ "$cap" =~ ^[0-9]+$ ]]; then
      if (( cap <= threshold )); then
        if [[ "$status" != "Charging" && "$status" != "Full" ]]; then
          local now last=0
          now="$(date +%s)"
          [[ -r "$stamp_file" ]] && last="$(cat "$stamp_file" 2>/dev/null || echo 0)"

          if (( now - last >= cooldown_seconds )); then
            local title="Battery low: ${cap}%"
            local msg="Battery is at ${cap}% (status: ${status}). Plug in charger for $HOSTNAME."
            _battery_ntfy_send "$title" "$msg" 5 && echo "$now" > "$stamp_file"
          fi
        fi
      fi
    fi

    sleep "$interval"
  done
}


function nvmehealth() {
  local dev="${1:-/dev/nvme0n1}"
  local smart raw
  local critical_warning temp_k temp_c temp_f spare spare_thr used
  local data_read data_written power_on_hours media_errors err_logs unsafe_shutdowns
  local t1_count t2_count
  local status="OK"
  local warnings=""
  local notify_msg=""

  # Dependency checks
  command -v nvme >/dev/null 2>&1 || {
    echo "ERROR: nvme command not found. Install with: sudo apt install nvme-cli"
    return 1
  }

  # Read SMART log
  smart="$(sudo nvme smart-log "$dev" 2>/dev/null)"
  if [[ -z "$smart" ]]; then
    echo "ERROR: Could not read SMART log from $dev"
    return 1
  fi

  # Helper: trim leading/trailing spaces
  trim() { sed 's/^[[:space:]]*//; s/[[:space:]]*$//'; }

  # Extract values
  critical_warning="$(echo "$smart" | awk -F: '/^critical_warning/ {print $2}' | trim)"
  temp_k="$(echo "$smart" | awk -F'[()]' '/^temperature/ {gsub(/ K/,"",$2); print $2}' | trim)"
  temp_f="$(echo "$smart" | awk -F: '/^temperature/ {print $2}' | sed 's/.*\([0-9][0-9]*\) °F.*/\1/' | trim)"
  spare="$(echo "$smart" | awk -F: '/^available_spare[[:space:]]*:/ {print $2}' | tr -d '%' | trim)"
  spare_thr="$(echo "$smart" | awk -F: '/^available_spare_threshold/ {print $2}' | tr -d '%' | trim)"
  used="$(echo "$smart" | awk -F: '/^percentage_used/ {print $2}' | tr -d '%' | trim)"
  data_read="$(echo "$smart" | awk -F: '/^Data Units Read/ {print $2}' | trim)"
  data_written="$(echo "$smart" | awk -F: '/^Data Units Written/ {print $2}' | trim)"
  power_on_hours="$(echo "$smart" | awk -F: '/^power_on_hours/ {print $2}' | trim)"
  unsafe_shutdowns="$(echo "$smart" | awk -F: '/^unsafe_shutdowns/ {print $2}' | trim)"
  media_errors="$(echo "$smart" | awk -F: '/^media_errors/ {print $2}' | trim)"
  err_logs="$(echo "$smart" | awk -F: '/^num_err_log_entries/ {print $2}' | trim)"
  t1_count="$(echo "$smart" | awk -F: '/^Thermal Management T1 Trans Count/ {print $2}' | trim)"
  t2_count="$(echo "$smart" | awk -F: '/^Thermal Management T2 Trans Count/ {print $2}' | trim)"

  # Convert K -> C if present
  if [[ "$temp_k" =~ ^[0-9]+$ ]]; then
    temp_c=$((temp_k - 273))
  else
    temp_c="?"
  fi

  # Health logic
  if [[ "$critical_warning" != "0" && -n "$critical_warning" ]]; then
    status="WARN"
    warnings+="critical_warning=$critical_warning; "
  fi

  if [[ "$temp_c" != "?" ]]; then
    if (( temp_c >= 80 )); then
      status="WARN"
      warnings+="temperature=${temp_c}C; "
    fi
  fi

  if [[ "$used" =~ ^[0-9]+$ ]]; then
    if (( used >= 80 )); then
      status="WARN"
      warnings+="wear_used=${used}%; "
    fi
  fi

  if [[ "$media_errors" =~ ^[0-9]+$ ]] && (( media_errors > 0 )); then
    status="WARN"
    warnings+="media_errors=$media_errors; "
  fi

  if [[ "$err_logs" =~ ^[0-9]+$ ]] && (( err_logs > 0 )); then
    status="WARN"
    warnings+="err_logs=$err_logs; "
  fi

  if [[ "$t1_count" =~ ^[0-9]+$ ]] && (( t1_count > 0 )); then
    status="WARN"
    warnings+="thermal_t1_events=$t1_count; "
  fi

  if [[ "$t2_count" =~ ^[0-9]+$ ]] && (( t2_count > 0 )); then
    status="WARN"
    warnings+="thermal_t2_events=$t2_count; "
  fi

  # Pretty output
  echo "========================================"
  echo "NVMe health check"
  echo "Device:              $dev"
  echo "Status:              $status"
  echo "Temperature:         ${temp_c}°C${temp_f:+ / ${temp_f}°F}"
  echo "Percentage used:     ${used}%"
  if [[ "$used" =~ ^[0-9]+$ ]]; then
    echo "Health remaining:    $((100 - used))%"
  else
    echo "Health remaining:    ?"
  fi
  echo "Available spare:     ${spare}%"
  echo "Spare threshold:     ${spare_thr}%"
  echo "Power on hours:      $power_on_hours"
  echo "Unsafe shutdowns:    $unsafe_shutdowns"
  echo "Media errors:        $media_errors"
  echo "Error log entries:   $err_logs"
  echo "Data units read:     $data_read"
  echo "Data units written:  $data_written"
  echo "Thermal T1 events:   $t1_count"
  echo "Thermal T2 events:   $t2_count"
  [[ -n "$warnings" ]] && echo "Warnings:            $warnings"
  echo "========================================"

  # Optional ntfy integration if you already have a function/command named ntfy
  if [[ "$status" != "OK" ]]; then
    notify_msg="NVMe warning on $(hostname): $dev :: $warnings"
    if command -v ntfy >/dev/null 2>&1; then
      ntfy "$notify_msg" 2>/dev/null
    fi
  fi
}


function diskhealth() {
  local dev="${1:-/dev/nvme0n1}"

  if [[ "$dev" == /dev/nvme* ]]; then
    nvmehealth "$dev"
    return
  fi

  command -v smartctl >/dev/null 2>&1 || {
    echo "ERROR: smartctl not found. Install with: sudo apt install smartmontools"
    return 1
  }

  local smart health temp reallocated pending offline_unc status warnings
  status="OK"
  warnings=""

  smart="$(sudo smartctl -a "$dev" 2>/dev/null)"
  [[ -z "$smart" ]] && { echo "ERROR: Could not read SMART data from $dev"; return 1; }

  health="$(echo "$smart" | awk -F: '/SMART overall-health self-assessment test result|SMART Health Status/ {print $2}' | sed 's/^[[:space:]]*//')"
  temp="$(echo "$smart" | awk '/Temperature_Celsius|Current Drive Temperature|Temperature:/ {print $NF; exit}')"
  reallocated="$(echo "$smart" | awk '/Reallocated_Sector_Ct/ {print $10; exit}')"
  pending="$(echo "$smart" | awk '/Current_Pending_Sector/ {print $10; exit}')"
  offline_unc="$(echo "$smart" | awk '/Offline_Uncorrectable/ {print $10; exit}')"

  [[ -z "$health" ]] && health="UNKNOWN"
  [[ -z "$temp" ]] && temp="?"
  [[ -z "$reallocated" ]] && reallocated="0"
  [[ -z "$pending" ]] && pending="0"
  [[ -z "$offline_unc" ]] && offline_unc="0"

  if [[ "$health" != *PASSED* && "$health" != *OK* && "$health" != "UNKNOWN" ]]; then
    status="WARN"
    warnings+="health=$health; "
  fi

  if [[ "$temp" =~ ^[0-9]+$ ]] && (( temp >= 55 )); then
    status="WARN"
    warnings+="temperature=${temp}C; "
  fi

  if [[ "$reallocated" =~ ^[0-9]+$ ]] && (( reallocated > 0 )); then
    status="WARN"
    warnings+="reallocated=$reallocated; "
  fi

  if [[ "$pending" =~ ^[0-9]+$ ]] && (( pending > 0 )); then
    status="WARN"
    warnings+="pending=$pending; "
  fi

  if [[ "$offline_unc" =~ ^[0-9]+$ ]] && (( offline_unc > 0 )); then
    status="WARN"
    warnings+="offline_uncorrectable=$offline_unc; "
  fi

  echo "========================================"
  echo "Disk health check"
  echo "Device:              $dev"
  echo "Status:              $status"
  echo "SMART overall:       $health"
  echo "Temperature:         ${temp}°C"
  echo "Reallocated sectors: $reallocated"
  echo "Pending sectors:     $pending"
  echo "Offline uncorrect.:  $offline_unc"
  [[ -n "$warnings" ]] && echo "Warnings:            $warnings"
  echo "========================================"

  if [[ "$status" != "OK" ]]; then
    if command -v ntfy >/dev/null 2>&1; then
      ntfy "Disk warning on $(hostname): $dev :: $warnings" 2>/dev/null
    fi
  fi
}


function ramdrive() {
    local mountpoint="/mnt/ramdrive"
    local begin_marker="# BEGIN Bash-Addins ramdrive"
    local end_marker="# END Bash-Addins ramdrive"

    _ramdrive_usage() {
        cat <<'EOF'
Usage:
  ramdrive create SIZE [permanent]
  ramdrive mount
  ramdrive unmount
  ramdrive umount

Examples:
  ramdrive create 4GB
  ramdrive create 4.5GB permanent
  ramdrive mount
  ramdrive unmount

SIZE syntax:
  A positive number followed by MB or GB.
  Decimal fractions must use a period, not a comma.

Valid:    512MB  4GB  4.5GB  0.5GB
Invalid:  4,5GB  4A.5GB  4.5  4GiB

Notes:
  - The default mount point is /mnt/ramdrive
  - MB and GB are interpreted as MiB and GiB.
  - 'permanent' means mounted automatically at boot.
  - Contents always disappear after unmounting or rebooting.
  - The drive is mounted noswap, nosuid, nodev and noexec.
EOF
    }

    _ramdrive_is_mounted() {
        mountpoint -q "$mountpoint"
    }

    _ramdrive_show() {
        findmnt "$mountpoint"
        df -h "$mountpoint"
        ls -ld "$mountpoint"
    }

    local action="${1:-}"

    case "$action" in
        "")
            _ramdrive_usage
            return 0
            ;;

        create)
            local requested_size="${2:-}"
            local persistence="${3:-}"
            local normalized number unit bytes
            local mem_available mem_total reserve usable
            local user_uid user_gid
            local temp_fstab backup_name
            local permanent=0

            if [[ -z "$requested_size" ]]; then
                printf 'Error: a size is required.\n\n' >&2
                _ramdrive_usage
                return 2
            fi

            if [[ -n "${4:-}" ]]; then
                printf 'Error: too many arguments.\n\n' >&2
                _ramdrive_usage
                return 2
            fi

            if [[ -n "$persistence" ]]; then
                if [[ "$persistence" == "permanent" ]]; then
                    permanent=1
                else
                    printf 'Error: expected "permanent", got: %s\n' \
                        "$persistence" >&2
                    return 2
                fi
            fi

            normalized="${requested_size^^}"

            if [[ ! "$normalized" =~ ^([1-9][0-9]*|0\.[0-9]+|[1-9][0-9]*\.[0-9]+)(MB|GB)$ ]]; then
                printf 'Error: invalid size: %s\n' "$requested_size" >&2
                printf 'Use forms such as 512MB, 4GB or 4.5GB.\n' >&2
                return 2
            fi

            number="${normalized::-2}"
            unit="${normalized: -2}"

            bytes="$(
                awk -v number="$number" -v unit="$unit" '
                    BEGIN {
                        multiplier = unit == "GB" ? 1073741824 : 1048576
                        printf "%.0f\n", number * multiplier
                    }
                '
            )"

            if [[ ! "$bytes" =~ ^[0-9]+$ ]] || (( bytes < 1048576 )); then
                printf 'Error: calculated RAM-drive size is invalid.\n' >&2
                return 2
            fi

            mem_available="$(
                awk '
                    $1 == "MemAvailable:" {
                        printf "%.0f\n", $2 * 1024
                    }
                ' /proc/meminfo
            )"

            mem_total="$(
                awk '
                    $1 == "MemTotal:" {
                        printf "%.0f\n", $2 * 1024
                    }
                ' /proc/meminfo
            )"

            if [[ -z "$mem_available" || -z "$mem_total" ]]; then
                printf 'Error: unable to determine available memory.\n' >&2
                return 1
            fi

            # Preserve at least 1 GiB, or 10% of physical RAM if greater.
            reserve=$(( mem_total / 10 ))

            if (( reserve < 1073741824 )); then
                reserve=1073741824
            fi

            if (( mem_available > reserve )); then
                usable=$(( mem_available - reserve ))
            else
                usable=0
            fi

            printf 'Requested maximum: %s\n' \
                "$(numfmt --to=iec-i --suffix=B "$bytes")"
            printf 'Available memory:  %s\n' \
                "$(numfmt --to=iec-i --suffix=B "$mem_available")"
            printf 'Safety reserve:    %s\n' \
                "$(numfmt --to=iec-i --suffix=B "$reserve")"

            if (( bytes > usable )); then
                printf '\nError: insufficient safely usable RAM.\n' >&2
                printf 'Maximum allowed now: %s\n' \
                    "$(numfmt --to=iec-i --suffix=B "$usable")" >&2
                return 1
            fi

            if (( EUID == 0 )); then
                printf 'Error: run ramdrive as your normal user, not root.\n' >&2
                return 1
            fi

            user_uid="$(id -u)"
            user_gid="$(id -g)"

            if _ramdrive_is_mounted; then
                printf '\n%s is currently mounted.\n' "$mountpoint"
                printf 'Remounting will permanently discard everything in it.\n'
                read -r -p 'Continue? [y/N] ' answer

                if [[ ! "$answer" =~ ^[Yy]$ ]]; then
                    printf 'Cancelled.\n'
                    return 0
                fi
            fi

            printf '\nAdministrator permission is required.\n'

            if ! sudo -v; then
                printf 'Error: sudo authentication failed.\n' >&2
                return 1
            fi

            if _ramdrive_is_mounted; then
                if ! sudo umount "$mountpoint"; then
                    printf 'Error: the RAM drive is busy.\n' >&2
                    printf 'Open files can be inspected with:\n' >&2
                    printf '  sudo lsof +D %q\n' "$mountpoint" >&2
                    return 1
                fi
            fi

            sudo mkdir -p "$mountpoint"

            if (( permanent )); then
                temp_fstab="$(mktemp)" || return 1
                backup_name="/etc/fstab.ramdrive-backup.$(date +%Y%m%d-%H%M%S)"

                # Remove a previous function-managed block and any older
                # standalone entry for this exact mount point.
                awk \
                    -v begin="$begin_marker" \
                    -v end="$end_marker" \
                    -v mp="$mountpoint" '
                    $0 == begin {
                        managed = 1
                        next
                    }

                    $0 == end {
                        managed = 0
                        next
                    }

                    managed {
                        next
                    }

                    /^[[:space:]]*#/ {
                        print
                        next
                    }

                    $2 == mp {
                        next
                    }

                    {
                        print
                    }
                ' /etc/fstab > "$temp_fstab"

                {
                    printf '\n%s\n' "$begin_marker"
                    printf 'tmpfs %s tmpfs rw,size=%s,noswap,mode=0700,uid=%s,gid=%s,nosuid,nodev,noexec 0 0\n' \
                        "$mountpoint" "$bytes" "$user_uid" "$user_gid"
                    printf '%s\n' "$end_marker"
                } >> "$temp_fstab"

                if ! sudo cp --preserve=all /etc/fstab "$backup_name"; then
                    rm -f "$temp_fstab"
                    printf 'Error: unable to back up /etc/fstab.\n' >&2
                    return 1
                fi

                if ! sudo install -o root -g root -m 0644 \
                    "$temp_fstab" /etc/fstab; then
                    rm -f "$temp_fstab"
                    printf 'Error: unable to update /etc/fstab.\n' >&2
                    return 1
                fi

                rm -f "$temp_fstab"

                if ! sudo mount "$mountpoint"; then
                    printf 'Error: fstab was updated, but mounting failed.\n' >&2
                    printf 'Backup: %s\n' "$backup_name" >&2
                    return 1
                fi

                printf '\nPermanent RAM drive created successfully.\n'
                printf 'fstab backup: %s\n\n' "$backup_name"
            else
                if ! sudo mount -t tmpfs \
                    -o "size=$bytes,noswap,mode=0700,uid=$user_uid,gid=$user_gid,nosuid,nodev,noexec" \
                    tmpfs "$mountpoint"; then
                    printf 'Error: unable to mount RAM drive.\n' >&2
                    return 1
                fi

                printf '\nTemporary RAM drive created successfully.\n'
                printf 'It will not be recreated automatically after reboot.\n\n'
            fi

            _ramdrive_show
            ;;

        mount)
            if _ramdrive_is_mounted; then
                printf '%s is already mounted.\n\n' "$mountpoint"
                _ramdrive_show
                return 0
            fi

            if ! awk -v mp="$mountpoint" '
                /^[[:space:]]*#/ { next }
                $2 == mp { found=1 }
                END { exit !found }
            ' /etc/fstab; then
                printf 'Error: no permanent ramdrive configuration exists.\n' >&2
                printf 'Create one first, for example:\n' >&2
                printf '  ramdrive create 4.5GB permanent\n' >&2
                return 1
            fi

            printf 'Administrator permission is required.\n'

            if ! sudo -v || ! sudo mount "$mountpoint"; then
                printf 'Error: unable to mount %s.\n' "$mountpoint" >&2
                return 1
            fi

            printf '\nRAM drive mounted successfully.\n\n'
            _ramdrive_show
            ;;

        unmount|umount)
            if ! _ramdrive_is_mounted; then
                printf '%s is not mounted.\n' "$mountpoint"
                return 0
            fi

            printf 'Everything currently in %s will be lost.\n' "$mountpoint"
            read -r -p 'Unmount it? [y/N] ' answer

            if [[ ! "$answer" =~ ^[Yy]$ ]]; then
                printf 'Cancelled.\n'
                return 0
            fi

            printf 'Administrator permission is required.\n'

            if ! sudo -v || ! sudo umount "$mountpoint"; then
                printf 'Error: unable to unmount the RAM drive.\n' >&2
                printf 'Check open files with:\n' >&2
                printf '  sudo lsof +D %q\n' "$mountpoint" >&2
                return 1
            fi

            printf '%s unmounted. Its contents are gone.\n' "$mountpoint"
            ;;

        help|-h|--help)
            _ramdrive_usage
            ;;

        *)
            printf 'Error: unknown action: %s\n\n' "$action" >&2
            _ramdrive_usage
            return 2
            ;;
    esac

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


findfiles() {
    if (( $# == 0 )); then
        echo 'Usage: findfiles "glob pattern here"' >&2
        echo 'Example: findfiles "*.lock"' >&2
        return 2
    fi
    find . -type f -iname "$*" -printf '%p\n'
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
mv "$file" "$(echo "$file" | sed 's/Ä/A/g; s/Ü/U/g; s/Õ/O/g; s/Ö/O/g')"
done
}



function choicelist() {
# Presents a numbered selection menu based on piped input.
# Usage: selected=$(command producing lines | choicelist)
# Example: selected=$(ls *.mp3 | choicelist)
#
# Multi-select mode:
#   selected=$(command | choicelist multi)
#   # User may enter multiple numbers (e.g. "1 3 5" or "1,3")
#
# Cancel:
#   Enter 0, c, C, q, or Q to cancel (function returns exit code 2, no output).
#
# Behavior:
# - Reads incoming lines from stdin (via pipe) into a list.
# - Displays a numbered menu to the user (via stderr — visible even inside $()).
# - Prompts for a choice using /dev/tty so user input still works when piped.
# - In single mode: returns the chosen line to stdout.
# - In multi mode: returns each selected line on a separate stdout line.
#
# Example:
#   file=$(ls *.mp3 | choicelist)
#   echo "Selected: $file"
#
#   files=$(ls *.mp3 | choicelist multi)
#   echo "Selected files:"
#   echo "$files"
#
# Exit codes:
#   0 = Success (output contains selected line(s))
#   1 = No input received
#   2 = User cancelled
#
# Notes:
# - Menu goes to stderr so the caller sees it even inside command substitution.
# - Output (stdout) only contains the final selection(s).
# - Works correctly with pipelines, scripts, aliases, and subshells.

    local mode="single"
    [[ "$1" == "multi" ]] && mode="multi"
    mapfile -t _choices
    if (( ${#_choices[@]} == 0 )); then return 1; fi
    
    # Print menu to stderr
    for i in "${!_choices[@]}"; do printf "%d) %s\n" $((i+1)) "${_choices[$i]}" >&2; done

    # Prompt text depends on single vs multi mode
    local prompt="Your choice: "
    [[ "$mode" == "multi" ]] && prompt="Your choice (multi): "

    local _pick

    while true; do
        printf "%s" "$prompt" >&2
        read _pick < /dev/tty

        # Cancel
        if [[ "$_pick" =~ ^(0|c|C|q|Q)$ ]]; then
            return 2
        fi

        if [[ "$mode" == "single" ]]; then
            # Single selection must be a valid number
            if [[ "$_pick" =~ ^[0-9]+$ ]] && (( _pick >= 1 && _pick <= ${#_choices[@]} )); then
                printf "%s" "${_choices[$((_pick-1))]}"
                return 0
            fi

        else
            # Multi mode: allow "1 3 5" or "1,3,5"
            local ok=true
            # Normalize commas → spaces
            local picks=$(printf "%s" "$_pick" | tr ',' ' ')

            for n in $picks; do
                if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 1 || n > ${#_choices[@]} )); then
                    ok=false
                fi
            done

            if $ok; then
                # Print selected lines, one per line
                for n in $picks; do
                    printf "%s\n" "${_choices[$((n-1))]}"
                done
                return 0
            fi
        fi

        printf "Invalid choice. Enter numbers between 1-%d.\n" "${#_choices[@]}" >&2
    done
}




function syncit() {
# Synchronizes files from a source folder to a destination folder using rsync.
# Copies only newer files, continues on errors, logs the process output results in the source folder, as log file.
# Example: syncit ~/source ~/backup
local src=${1?No input given for source folder. Example usage: syncit ~/source ~/backup}   # First argument: source folder
local dest=${2?No input given for destination folder} # Second argument: destination folder
if [ -z "$src" ] || [ -z "$dest" ]; then return 0; fi  # Do nothing if missing arguments

src="${src%/}"   # Normalize source path (remove trailing slash if present)
dest="${dest%/}" # Normalize destination path (remove trailing slash if present)
local datetime
datetime=$(date +"%Y-%m-%d_%H.%M") # Format datetime as yyyy-mm-dd_HH.MM
local logfile="${src}/${datetime}_syncit.log" # Log file stored in source folder

mkdir -p "$dest" # Ensure destination folder exists
rsync -av --ignore-errors --update --progress --log-file="$logfile" "${src}/" "${dest}/" # Run rsync to synchronize folders

# Output summary
echo "---------------------------------------"
echo "Copying complete. Log saved to: $logfile"
echo "---------------------------------------"
}


function foldersize() {
# Shows the total size of a folder (or current directory if omitted).
# Example:
#   foldersize
#   foldersize ~/Downloads
local dir="${1:-.}"
if [[ ! -d "$dir" ]]; then echo "Directory not found: $dir"; return 1; fi
du -sh -- "$dir"
}

function foldersizes() {
# Shows sizes of immediate subfolders, largest first.
# Example: foldersizes ~/Downloads
local dir="${1:-.}"
[[ -d "$dir" ]] || { echo "Directory not found: $dir"; return 1; }
du -sh "$dir"/* 2>/dev/null | sort -hr
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
# Example: wait4file ~/Downloads/*.mp4
# Example: wait4file ~/Downloads/*vie*
if [ $# -lt 1 ]; then
  echo "Usage: wait4file /path/to/file"
  echo "Usage: wait4file /path/to/pattern"
  return 1
fi
# If the shell expanded a glob, you'll get multiple args (already-matching files). In that case, we're done immediately.
if [ $# -gt 1 ]; then
  echo "File found:"
  printf '  %s\n' "$@"
  return 0
fi
local pattern="$1"
echo "Waiting for: $pattern"
while ! compgen -G "$pattern" > /dev/null; do sleep 2; done    # Loop until the pattern matches at least one file
echo "File found:"
compgen -G "$pattern"    # Print all matches (can be multiple)
}


wait4file_gone() {
  # Waits until a file OR glob/pattern disappears.
  # Works with:
  #   wait4file_gone ~/Downloads/movie.mp4
  #   wait4file_gone ~/Downloads/*.mp4
  #   wait4file_gone ~/Downloads/*vie*

  if [ $# -lt 1 ]; then
    echo "Usage: wait4file_gone /path/or/pattern"
    return 1
  fi

  # If the shell expanded the glob, we got multiple existing files.
  # We'll wait until ALL of them are gone.
  if [ $# -gt 1 ]; then
    echo "Waiting for all matched files to disappear:"
    printf '  %s\n' "$@"

    while :; do
      still_there=false
      for f in "$@"; do
        if [ -e "$f" ]; then
          still_there=true
          break
        fi
      done
      $still_there || break
      sleep 2
    done

    echo "All matched files are gone."
    return 0
  fi

  local pattern="$1"
  if ! compgen -G "$pattern" > /dev/null; then
    echo "No files matching '$pattern' (already gone)."   # If nothing matches already, we’re done
    return 0
  fi

  echo "Waiting for files matching '$pattern' to disappear..."
  while compgen -G "$pattern" > /dev/null; do sleep 2; done    # Loop until NOTHING matches the pattern
  echo "All files matching '$pattern' are gone."
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


function wait4file_gone_ext() {
    local ext="$2"
    local dir="${1:-$HOME/Downloads}"
    while find "$dir" -type f -name "$2" -print -quit 2>/dev/null | grep -q .; do sleep 1; done
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


function screenoff() {
xset dpms force off
}

function lockscreen() {
cinnamon-screensaver-command --lock
}


function autologin() {
    local user="$1"
    local state="$2"
    local session_arg="$3"

    local dm=""
    local target=""
    local backup=""
    local session=""

    # ----------------------------
    # Helpers
    # ----------------------------
    _autologin_usage() {
        echo "Usage:"
        echo "  autologin <username> on [session]"
        echo "  autologin <username> off"
        echo
        echo "Examples:"
        echo "  autologin \"$USER\" on"
        echo "  autologin \"$USER\" off"
        echo "  autologin \"$USER\" on plasma"
    }

    _autologin_detect_dm() {
        # Best source on Debian/Mint systems
        if [ -f /etc/X11/default-display-manager ]; then
            local dm_path
            dm_path="$(cat /etc/X11/default-display-manager 2>/dev/null)"
            basename "$dm_path"
            return 0
        fi

        # Fallback: systemd symlink
        if [ -L /etc/systemd/system/display-manager.service ]; then
            basename "$(readlink -f /etc/systemd/system/display-manager.service)" .service
            return 0
        fi

        # Last fallback: common running processes
        for x in lightdm gdm3 gdm sddm; do
            if pgrep -x "$x" >/dev/null 2>&1; then
                echo "$x"
                return 0
            fi
        done

        return 1
    }

    _autologin_backup_file() {
        local f="$1"
        if [ -f "$f" ]; then
            backup="${f}.bak.$(date +%Y%m%d-%H%M%S)"
            sudo cp -a "$f" "$backup" || return 1
            echo "Backup created: $backup"
        fi
    }

    _autologin_detect_session() {
        # Explicit argument wins
        if [ -n "$session_arg" ]; then
            echo "$session_arg"
            return 0
        fi

        # Common session environment vars
        if [ -n "$XDG_SESSION_DESKTOP" ]; then
            echo "$XDG_SESSION_DESKTOP"
            return 0
        fi

        if [ -n "$DESKTOP_SESSION" ]; then
            echo "$DESKTOP_SESSION"
            return 0
        fi

        # ~/.dmrc often stores the last/default session
        if [ -f "/home/$user/.dmrc" ]; then
            awk -F= '
                /^\[Desktop\]/ {in_desktop=1; next}
                /^\[/ {in_desktop=0}
                in_desktop && $1=="Session" {print $2; exit}
            ' "/home/$user/.dmrc"
            return 0
        fi

        return 1
    }

    # ----------------------------
    # Validate args
    # ----------------------------
    if [ -z "$user" ] || [ -z "$state" ]; then
        _autologin_usage
        return 1
    fi

    if ! id "$user" >/dev/null 2>&1; then
        echo "Error: user '$user' does not exist."
        return 1
    fi

    case "$state" in
        on|off) ;;
        *)
            _autologin_usage
            return 1
            ;;
    esac

    dm="$(_autologin_detect_dm)"
    if [ -z "$dm" ]; then
        echo "Error: could not detect display manager."
        return 1
    fi

    echo "Detected display manager: $dm"

    # ----------------------------
    # LIGHTDM
    # ----------------------------
    if [ "$dm" = "lightdm" ]; then
        target="/etc/lightdm/lightdm.conf.d/99-autologin.conf"

        if [ "$state" = "on" ]; then
            sudo mkdir -p /etc/lightdm/lightdm.conf.d || return 1

            if [ -f "$target" ]; then
                _autologin_backup_file "$target" || return 1
            fi

            sudo tee "$target" >/dev/null <<EOF
[Seat:*]
autologin-user=$user
autologin-user-timeout=0
EOF

            echo "Autologin ENABLED for user '$user' in LightDM."
            echo "Config: $target"
            return 0
        else
            if [ -f "$target" ]; then
                _autologin_backup_file "$target" || return 1
                sudo rm -f "$target" || return 1
                echo "Autologin DISABLED in LightDM."
            else
                echo "No LightDM autologin override file found. Nothing to remove."
            fi
            return 0
        fi
    fi

    # ----------------------------
    # GDM / GDM3
    # ----------------------------
    if [ "$dm" = "gdm3" ] || [ "$dm" = "gdm" ]; then
        if [ -f /etc/gdm3/custom.conf ]; then
            target="/etc/gdm3/custom.conf"
        elif [ -f /etc/gdm/custom.conf ]; then
            target="/etc/gdm/custom.conf"
        else
            echo "Error: could not find GDM custom.conf."
            return 1
        fi

        _autologin_backup_file "$target" || return 1

        if [ "$state" = "on" ]; then
            sudo awk -v user="$user" '
                BEGIN {
                    daemon_found=0
                    autologin_enable_set=0
                    autologin_user_set=0
                }
                /^\[daemon\]/ {
                    daemon_found=1
                    print
                    next
                }
                daemon_found && /^[[:space:]]*AutomaticLoginEnable[[:space:]]*=/ {
                    if (!autologin_enable_set) {
                        print "AutomaticLoginEnable=True"
                        autologin_enable_set=1
                    }
                    next
                }
                daemon_found && /^[[:space:]]*AutomaticLogin[[:space:]]*=/ {
                    if (!autologin_user_set) {
                        print "AutomaticLogin=" user
                        autologin_user_set=1
                    }
                    next
                }
                { print }
                END {
                    if (!daemon_found) {
                        print ""
                        print "[daemon]"
                        print "AutomaticLoginEnable=True"
                        print "AutomaticLogin=" user
                    } else {
                        if (!autologin_enable_set) print "AutomaticLoginEnable=True"
                        if (!autologin_user_set) print "AutomaticLogin=" user
                    }
                }
            ' "$target" | sudo tee "${target}.tmp" >/dev/null && sudo mv "${target}.tmp" "$target" || return 1

            echo "Autologin ENABLED for user '$user' in GDM."
            echo "Config: $target"
            return 0
        else
            sudo awk '
                /^\[daemon\]/ { print; next }
                /^[[:space:]]*AutomaticLoginEnable[[:space:]]*=/ { next }
                /^[[:space:]]*AutomaticLogin[[:space:]]*=/ { next }
                { print }
            ' "$target" | sudo tee "${target}.tmp" >/dev/null && sudo mv "${target}.tmp" "$target" || return 1

            echo "Autologin DISABLED in GDM."
            echo "Config cleaned: $target"
            return 0
        fi
    fi

    # ----------------------------
    # SDDM
    # ----------------------------
    if [ "$dm" = "sddm" ]; then
        target="/etc/sddm.conf.d/autologin.conf"

        if [ "$state" = "on" ]; then
            sudo mkdir -p /etc/sddm.conf.d || return 1

            session="$(_autologin_detect_session)"
            if [ -z "$session" ]; then
                echo "Error: SDDM usually needs a session name too."
                echo "Could not auto-detect session."
                echo "Try for example:"
                echo "  autologin \"$user\" on plasma"
                echo "  autologin \"$user\" on cinnamon"
                return 1
            fi

            if [ -f "$target" ]; then
                _autologin_backup_file "$target" || return 1
            fi

            sudo tee "$target" >/dev/null <<EOF
[Autologin]
User=$user
Session=$session
Relogin=false
EOF

            echo "Autologin ENABLED for user '$user' in SDDM."
            echo "Session: $session"
            echo "Config: $target"
            return 0
        else
            if [ -f "$target" ]; then
                _autologin_backup_file "$target" || return 1
                sudo rm -f "$target" || return 1
                echo "Autologin DISABLED in SDDM."
            else
                echo "No SDDM autologin override file found. Nothing to remove."
            fi
            return 0
        fi
    fi

    echo "Error: unsupported or unhandled display manager: $dm"
    return 1
}



