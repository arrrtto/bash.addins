#!/bin/bash

# Fancy stuff module - started on 24.07.2025 by Artto
MODULE_NAME="fancy"
MODULE_VERSION="1.2"
MODULE_DESCRIPTION="Other type of cool or fancy functions"


# --- WGET DOWNLOAD WITH PROGRESS BAR CODE BEGIN ------
function gradient_progress_bar() {
# Function to print a gradient progress bar based on a given percentage. Meant to be used by wget_progressbar function.
local percent="${1:-0}"
[[ "$percent" =~ ^[0-9]+$ ]] || percent=0
(( percent > 100 )) && percent=100
local total_steps=50
local filled_steps=$((percent * total_steps / 100))
local character="🮆"
local progress_bar="" j r g b
for ((j=0; j<filled_steps; j++)); do  # Calculate the color transition for each filled character
r=$((35 + (75 * j / total_steps)))
g=$((206 - (206 * j / total_steps)))
b=255  # Keep blue constant
progress_bar+="\033[38;2;${r};${g};${b}m${character}\033[0m"  # Append the colored character to the progress bar
done
for ((j=filled_steps; j<total_steps; j++)); do progress_bar+=" "; done  # Fill the remaining characters with spaces
printf '\r%b %s%%' "$progress_bar" "$percent"
}

function gradient_in() {
# Meant to be used by gradient_text function, not separately.
local text="$1"
local start_r="$2"  # Starting red color
local start_g="$3"  # Starting green color
local start_b="$4"  # Starting blue color
local end_r="$5" # Ending red color
local end_g="$6" # Ending green color
local end_b="$7" # Ending blue color
local length=${#text}
local i r g b
(( length > 0 )) || { echo; return 0; }
for ((i=0; i<length; i++)); do
# Calculate the color transition
r=$((start_r + (end_r - start_r) * i / length))
g=$((start_g + (end_g - start_g) * i / length))
b=$((start_b + (end_b - start_b) * i / length))
# Print the character with the calculated color
printf "\033[38;2;${r};${g};${b}m${text:i:1}\033[0m"
done
echo  # Move to the next line after printing the text
}

function gradient_text() {
# Function for outputting gradient text in Terminal, from one RGB color to another.
# Example usage: gradient_text "Some text here"
if [ -z "$1" ]; then
local func_name="${FUNCNAME[0]}"
grep -E "function $func_name" -A 2 "$bashaddinsfile" | grep -oP '# .*'
return
fi
local -a start_color=(35 206 255) #RGB values
local -a end_color=(100 112 240) #RGB values
gradient_in "$1" "${start_color[0]}" "${start_color[1]}" "${start_color[2]}" "${end_color[0]}" "${end_color[1]}" "${end_color[2]}"
}

function wget_progressbar() {
# Function for downloading a file with wget and displaying only a fancy gradient progress bar, plus download percentage.
# The argument needs to be an URL (link)
# Example usage: wget_progressbar "https://github.com/Qortal/qortal/releases/latest/download/qortal.zip"
if [ -z "$1" ]; then
local func_name="${FUNCNAME[0]}"
grep -E "function $func_name" -A 3 "$bashaddinsfile" | grep -oP '# .*'
return
fi
local url="$1" file
[[ "$url" =~ ^https?://[^[:space:]]+$ ]] || { echo "Invalid HTTP/HTTPS URL." >&2; return 2; }
file=$(basename "${url%%\?*}")
[[ -n "$file" ]] || file="download"
gradient_text "Downloading $file, please wait"
if wget --progress=bar:force:noscroll "$url" \
  2> >(while IFS= read -r line; do
    if [[ $line =~ ([0-9]{1,3})% ]]; then
      gradient_progress_bar "${BASH_REMATCH[1]}" >&2
    fi
  done); then
  printf '\n'
else
  local rc=$?
  printf '\nDownload failed.\n' >&2
  return "$rc"
fi
}
# --- WGET DOWNLOAD WITH PROGRESS BAR CODE END ------
