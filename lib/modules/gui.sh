#!/bin/bash

# GUI module configuration
MODULE_NAME="gui"
MODULE_VERSION="1.0"
MODULE_DESCRIPTION="GUI window management functions"

# GUI functions
function focus_window() {
    local window_title="$1"
    wmctrl -a "$window_title"
}

function minimize_app() {
    local window_title="$1"
    wmctrl -r "$window_title" -b add,hidden
}

function maximize_app() {
    local window_title="$1"
    wmctrl -r "$window_title" -b add,maximized_vert,maximized_horz
}

function get_window_info() {
    local window_title="$1"
    wmctrl -l | grep "$window_title"
}

function screenshot_window() {
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

# Module initialization
function init_${MODULE_NAME}_module() {
    # Check if required commands are available
    if ! command -v wmctrl > /dev/null 2>&1; then
        echo "Warning: wmctrl is required for GUI functions"
    fi
}

# Module help
function ${MODULE_NAME}_help() {
    cat << EOF
${MODULE_NAME} module v${MODULE_VERSION}
${MODULE_DESCRIPTION}

Available functions:
  focus_window      Focus a window by title
  minimize_app      Minimize a window
  maximize_app      Maximize a window
  get_window_info   Get window information
  screenshot_window Take screenshot of a window
EOF
}

# Initialize module
init_${MODULE_NAME}_module
