#!/bin/bash

# GUI module configuration
MODULE_NAME="gui"
MODULE_VERSION="1.06"
MODULE_DESCRIPTION="GUI window management functions"


function focus_window() {
# Brings a selected app window to the front, making it the active window.
# Example: focus_window chromium
if [ -z "$1" ]; then cat $bashaddinsfile | grep -E "function ${FUNCNAME[0]}" -A 2 | grep -oP '# .*'; return; fi
xdotool search --onlyvisible --class $1 windowactivate && sleep 1
}

function minimize_app() {
# Minimizes a window of a specified application by name.
# Example: minimize_app firefox
if [ -z "$1" ]; then cat $bashaddinsfile | grep -E "function ${FUNCNAME[0]}" -A 2 | grep -oP '# .*'; return; fi
xdotool search --name $1 windowminimize && sleep 1
}

function maximize_app() {
# Maximizes a window of a specified application by name.
# Example: maximize_app firefox
if [ -z "$1" ]; then cat $bashaddinsfile | grep -E "function ${FUNCNAME[0]}" -A 2 | grep -oP '# .*'; return; fi
xdotool search --name $1 windowactivate windowsize 100% 100% && sleep 1
}

function get_window_info() {
# Gets info about the currently active window, including coordinates and size.
# The output will be written and also put into variables x, y, width and height.
# Usage example: get_window_info firefox
# PS: this function depends on focus_window in its workings.
if [ -z "$1" ]; then cat $bashaddinsfile | grep -E "function ${FUNCNAME[0]}" -A 4 | grep -oP '# .*'; return; fi
focus_window "$1" & sleep 0.5
window_id=$(xdotool getactivewindow)
xwininfo -id $window_id | awk '/Absolute upper-left X:/ { print "X: " $4 }'
xwininfo -id $window_id | awk '/Absolute upper-left Y:/ { print "Y: " $4 }'
xwininfo -id $window_id | awk '/Width:/ { print "Width: " $2 }'
xwininfo -id $window_id | awk '/Height:/ { print "Height: " $2 }'
x=$(xwininfo -id $window_id | awk '/Absolute upper-left X:/ { print $4 }')
y=$(xwininfo -id $window_id | awk '/Absolute upper-left Y:/ { print $4 }')
width=$(xwininfo -id $window_id | awk '/Width:/ { print $2 }')
height=$(xwininfo -id $window_id | awk '/Height:/ { print $2 }')
}


function screenshot_window() {
# Takes a screenshot of the active window and saves it to /home/$USER/Screen-shots as 'scr_$date_time.png'
# Example: screenshot_window firefox
if [ -z "$1" ]; then cat $bashaddinsfile | grep -E "function ${FUNCNAME[0]}" -A 1 | grep -oP '# .*'; return; fi
date_time=$(date +%d.%m.%Y-%H:%M)
local window=${1?Usage example: screenshot_window firefox}
focus_window $window
window_id=$(xdotool search --name --onlyvisible $window | head -n 1)
if [ -z "$window_id" ]; then
  echo "$window window not found or it is not open (the process is not running)."
  return 1
else
  mkdir -p /home/$USER/Screen-shots
  local output_file="/home/$USER/Screen-shots/scr_$date_time.png"
  cd 
  xwd -id "$window_id" | convert xwd:- "$output_file"
  echo "Screenshot saved to $output_file"
fi
}



function get_window_info_titled() {
local window_title="$1"
wmctrl -l | grep "$window_title"
}


function screenshot_window_titled() {
# Takes a screenshot of the window and saves it to /home/$USER/Screen-shots as 'scr_$date_time.png'
# Example: screenshot_window firefox
if [ -z "$1" ]; then cat $bashaddinsfile | grep -E "function ${FUNCNAME[0]}" -A 2 | grep -oP '# .*'; return; fi
local window_title="$1"
local window_id=$(wmctrl -l | grep "$window_title" | awk '{print $1}')  # Get window ID
if [ -n "$window_id" ]; then
mkdir -p /home/$USER/Screen-shots
output_file="/home/$USER/Screen-shots/scr_$(date +%Y%m%d_%H%M%S).png"
import -window "$window_id" "$output_file"
xwd -id "$window_id" | convert xwd:- "$output_file"
echo "Screenshot saved to $output_file"
else
echo "Window not found: $window_title"
fi
}


function window() {
# Manages open windows based on the specified action.
# Actions available: focus, close, maximize
# Usage example: window close firefox
# PS: Works only with Xorg and i3 window managers.
if [ -z "$1" ]; then cat $bashaddinsfile | grep -E "function ${FUNCNAME[0]}" -A 4 | grep -oP '# .*'; return; fi
windowmanager=$(ps -e | grep -oP 'i3|Xorg')
if [[ -z $windowmanager ]]; then echo "No X or i3 window manager found."; fi
if [[ $windowmanager = "Xorg" ]]; then
local action="$1" && local window_name="$2"
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
      echo "Valid actions are: focus, close and maximize"
      return
      ;;
esac
fi
if [[ $windowmanager = "i3" ]]; then
local action="$1" && local window_name="$2"
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
      echo "Valid actions are: focus, close and maximize"
      return
      ;;
esac
fi
}






