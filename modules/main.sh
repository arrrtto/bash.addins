#!/bin/bash

bashaddinsfile=$(which bash.addins)

# Main functions for the bash addins for the beginning of the file

function showallfunctions() {
# Lists all the functions that the bash.addins contains.
local file=$(which bash.addins)
local RED='\033[0;31m'  # for function names
local LIGHT_GRAY='\033[0;37m'  # for comments
local NC='\033[0m'  # no Color

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


function showaliases() {
# Lists all the aliases that the bash.addins contains.
cat $(which bash.addins) | grep -E "^alias"
}

function functions_amount(){
# Outputs the number of all available functions.
showallfunctions | grep -Ev "#" | sed_removeemptylines | wc -l
}


# ----- END OF MAIN FUNCTIONS SECTION -----

