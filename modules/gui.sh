#!/bin/bash

# GUI module configuration
MODULE_NAME="gui"
MODULE_VERSION="1.04"
MODULE_DESCRIPTION="GUI window management functions"


function focus_window() {
# Brings a selected app window to the front, making it the active window.
# Example: focus_window chromium
xdotool search --onlyvisible --class $1 windowactivate && sleep 1
}

function minimize_app() {
# Minimizes a window of a specified application by name.
# Example: minimize_app chromium
xdotool search --name $1 windowminimize && sleep 1
}

function maximize_app() {
# Maximizes a window of a specified application by name.
# Example: maximize_app chromium
xdotool search --name $1 windowactivate windowsize 100% 100% && sleep 1
}

function get_window_info() {
# Gets info about the currently active window (application), including coordinates and size.
# The output will be written and also put into variables x, y, width and height.
# Good example: focus_window brave && get_window_info
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
# Takes a screenshot of the active window and saves it to /home/$USER/Screenshots as 'scr_$date_time.png'
# Example: screenshot_window firefox
date_time=$(date +%d.%m.%Y-%H:%M)
local window=${1?Usage example: screenshot_window firefox}
focus_window $window
window_id=$(xdotool search --name --onlyvisible $window | head -n 1)
if [ -z "$window_id" ]; then
  echo "$window window not found or it is not open (the process is not running)."
  return 1
else
  mkdir -p /home/$USER/Screenshots_$window
  local output_file="/home/$USER/Screenshots_$window/scr_$date_time.png"
  cd 
  xwd -id "$window_id" | convert xwd:- "$output_file"
  echo "Screenshot saved to $output_file"
fi
}








function focus_window_titled() {
local window_title="$1"
wmctrl -a "$window_title"
}


function minimize_app_titled() {
local window_title="$1"
wmctrl -r "$window_title" -b add,hidden
}


function maximize_app_titled() {
local window_title="$1"
wmctrl -r "$window_title" -b add,maximized_vert,maximized_horz
}


function get_window_info_titled() {
local window_title="$1"
wmctrl -l | grep "$window_title"
}


function screenshot_window_titled() {
local window_title="$1"
local output_file="$2"

if [ -z "$output_file" ]; then
output_file="screenshot_$(date +%Y%m%d_%H%M%S).png"
fi

# Get window ID
local window_id=$(wmctrl -l | grep "$window_title" | awk '{print $1}')

if [ -n "$window_id" ]; then
import -window "$window_id" "$output_file"
echo "Screenshot saved to: $output_file"
else
echo "Window not found: $window_title"
fi
}



