#!/bin/bash

# Path to the compiled library. BASH_ADDINS_FILE may override the default.
bashaddinsfile="${BASH_ADDINS_FILE:-$(type -P bash.addins 2>/dev/null || true)}"
[[ -n "$bashaddinsfile" ]] || bashaddinsfile="$HOME/bin/bash.addins"

# Main functions for the bash addins for the beginning of the file

function showallfunctions() {
# Lists all the functions that the bash.addins contains.
local file="$bashaddinsfile"
[[ -r "$file" ]] || { echo "showallfunctions: cannot read $file" >&2; return 1; }
local RED='\033[0;31m'  # for function names
local LIGHT_GRAY='\033[0;37m'  # for comments
local NC='\033[0m'  # no Color

awk -v red="$RED" -v gray="$LIGHT_GRAY" -v nc="$NC" ' # Read the file and extract functions and comments
/^(function[[:space:]]+)?[A-Za-z_][A-Za-z0-9_-]*\(\)[[:space:]]*\{/ {
    func_name = $0
    sub(/^function[[:space:]]+/, "", func_name)
    sub(/\(.*/, "", func_name)
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


function showaliases() {
# Lists all the aliases that the bash.addins contains.
[[ -r "$bashaddinsfile" ]] || { echo "showaliases: cannot read $bashaddinsfile" >&2; return 1; }
grep -E '^alias[[:space:]]' "$bashaddinsfile"
}

function functions_amount() {
# Outputs the number of all available functions.
showallfunctions | grep -Ev "#" | sed_removeemptylines | wc -l
}


# ----- END OF MAIN FUNCTIONS SECTION -----
