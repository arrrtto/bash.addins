#!/bin/bash

# GUI module configuration
MODULE_NAME="gui"
MODULE_VERSION="1.2"
MODULE_DESCRIPTION="GUI window management functions"


function focus_window() {
# Brings a selected app window to the front, making it the active window.
# Example: focus_window chromium
if [ -z "$1" ]; then grep -E "function ${FUNCNAME[0]}" -A 2 "$bashaddinsfile" | grep -oP '# .*'; return; fi
local window_id
window_id=$(xdotool search --onlyvisible --class "$1" 2>/dev/null | head -n 1)
[[ -n "$window_id" ]] || { echo "Visible window not found: $1" >&2; return 1; }
xdotool windowactivate "$window_id"
}

function minimize_app() {
# Minimizes a window of a specified application by name.
# Example: minimize_app firefox
if [ -z "$1" ]; then grep -E "function ${FUNCNAME[0]}" -A 2 "$bashaddinsfile" | grep -oP '# .*'; return; fi
local window_id
window_id=$(xdotool search --onlyvisible --name "$1" 2>/dev/null | head -n 1)
[[ -n "$window_id" ]] || { echo "Visible window not found: $1" >&2; return 1; }
xdotool windowminimize "$window_id"
}

function maximize_app() {
# Maximizes a window of a specified application by name.
# Example: maximize_app firefox
if [ -z "$1" ]; then grep -E "function ${FUNCNAME[0]}" -A 2 "$bashaddinsfile" | grep -oP '# .*'; return; fi
local window_id
window_id=$(xdotool search --onlyvisible --name "$1" 2>/dev/null | head -n 1)
[[ -n "$window_id" ]] || { echo "Visible window not found: $1" >&2; return 1; }
xdotool windowactivate "$window_id" windowsize "$window_id" 100% 100%
}

function get_window_info() {
# Gets info about the currently active window, including coordinates and size.
# The output will be written and also put into variables x, y, width and height.
# Usage example: get_window_info firefox
# PS: this function depends on focus_window in its workings.
if [ -z "$1" ]; then grep -E "function ${FUNCNAME[0]}" -A 4 "$bashaddinsfile" | grep -oP '# .*'; return; fi
focus_window "$1" || return 1
local window_id info
window_id=$(xdotool getactivewindow) || return 1
info=$(xwininfo -id "$window_id") || return 1
x=$(awk '/Absolute upper-left X:/ {print $4}' <<< "$info")
y=$(awk '/Absolute upper-left Y:/ {print $4}' <<< "$info")
width=$(awk '/Width:/ {print $2}' <<< "$info")
height=$(awk '/Height:/ {print $2}' <<< "$info")
printf 'X: %s\nY: %s\nWidth: %s\nHeight: %s\n' "$x" "$y" "$width" "$height"
}


function screenshot_window() {
# Takes a screenshot of the active window and saves it under $HOME/Screen-shots.
# Example: screenshot_window firefox
if [ -z "$1" ]; then grep -E "function ${FUNCNAME[0]}" -A 1 "$bashaddinsfile" | grep -oP '# .*'; return; fi
local date_time window window_id output_file
date_time=$(date +%Y-%m-%d_%H-%M-%S_%N)
window="$1"
focus_window "$window" || return 1
window_id=$(xdotool search --name --onlyvisible "$window" 2>/dev/null | head -n 1)
if [ -z "$window_id" ]; then
  echo "$window window not found or it is not open (the process is not running)."
  return 1
else
  mkdir -p "$HOME/Screen-shots" || return 1
  output_file="$HOME/Screen-shots/scr_$date_time.png"
  if xwd -silent -id "$window_id" | convert xwd:- "$output_file"; then
    echo "Screenshot saved to $output_file"
  else
    echo "Screenshot failed." >&2
    return 1
  fi
fi
}



function get_window_info_titled() {
local window_title="$1"
[[ -n "$window_title" ]] || { echo "Usage: get_window_info_titled <literal-title-text>" >&2; return 2; }
wmctrl -l | awk -v title="$window_title" 'index($0, title)'
}


function screenshot_window_titled() {
# Takes a screenshot of the window and saves it under $HOME/Screen-shots.
# Example: screenshot_window firefox
if [ -z "$1" ]; then grep -E "function ${FUNCNAME[0]}" -A 2 "$bashaddinsfile" | grep -oP '# .*'; return; fi
local window_title="$1"
local window_id output_file
window_id=$(wmctrl -l | awk -v title="$window_title" 'index($0, title) {print $1; exit}')
if [ -n "$window_id" ]; then
mkdir -p "$HOME/Screen-shots" || return 1
output_file="$HOME/Screen-shots/scr_$(date +%Y-%m-%d_%H-%M-%S_%N).png"
if xwd -silent -id "$window_id" | convert xwd:- "$output_file"; then
  echo "Screenshot saved to $output_file"
else
  echo "Screenshot failed." >&2
  return 1
fi
else
echo "Window not found: $window_title"
return 1
fi
}


function window() {
# Manages open windows based on the specified action.
# Actions available: focus, close, maximize
# Usage example: window close firefox
# PS: Works only with Xorg and i3 window managers.
if [[ $# -ne 2 ]]; then echo "Usage: window <focus|close|maximize|minimize> <window-title>" >&2; return 2; fi
local action="$1" window_name="$2"
if pgrep -x i3 >/dev/null 2>&1 && command -v i3-msg >/dev/null 2>&1; then
if [[ "$window_name" == *['"\\']* ]]; then
  echo "i3 window titles containing quotes or backslashes are not supported." >&2
  return 2
fi
case "$action" in
  close)
      i3-msg "[title=\"$window_name\"] kill"
      ;;
  maximize)
      i3-msg "[title=\"$window_name\"] fullscreen"
      ;;
  minimize)
      i3-msg "[title=\"$window_name\"] move scratchpad"
      ;;
  focus)
      i3-msg "[title=\"$window_name\"] focus"
      ;;
  *)
      echo "Invalid action: $action"
      return 2
      ;;
esac
elif [[ -n "${DISPLAY:-}" ]] && command -v wmctrl >/dev/null 2>&1; then
case "$action" in
  close)
      wmctrl -c "$window_name"
      ;;
  maximize)
      wmctrl -r "$window_name" -b add,maximized_vert,maximized_horz
      ;;
  minimize)
      wmctrl -r "$window_name" -b add,hidden
      ;;
  focus)
      wmctrl -a "$window_name"
      ;;
  *)
      echo "Invalid action: $action"
      return 2
      ;;
esac
else
  echo "No supported X11/i3 window-control environment was detected." >&2
  return 1
fi
}

