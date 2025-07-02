#!/bin/bash

# Text module configuration
MODULE_NAME="text"
MODULE_VERSION="1.0"
MODULE_DESCRIPTION="Text processing and regex functions"

# Text processing functions
function regex_email() {
    grep -oE "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"
}

function regex_links_https() {
    grep -oE "https?://[^"]+"
}

function regex_htmltag() {
    grep -oE "<[^>]+>"
}

function regex_ipaddress() {
    grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}"
}

function regex_price() {
    grep -oE "\$?[0-9]+(\.[0-9]{2})?"
}

function regex_number() {
    grep -oE "[0-9]+(\.[0-9]+)?"
}

function regex_phonenumber() {
    grep -oE "\+?[0-9]{10,15}"
}

function regex_date() {
    grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}"
}

function regex_usernamehandle() {
    grep -oE "@[a-zA-Z0-9_]+"
}

function regex_hashtag() {
    grep -oE "#[a-zA-Z0-9_]+"
}

function regex_youtube_id() {
    grep -oE "[a-zA-Z0-9_-]{11}"
}

function regex_sha256() {
    grep -oE "[a-f0-9]{64}"
}

function regex_bitcoin() {
    grep -oE "[13][a-km-zA-HJ-NP-Z1-9]{25,34}"
}

function regex_uuid() {
    grep -oE "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
}

function regex_sql() {
    grep -oE "SELECT|FROM|WHERE|INSERT|UPDATE|DELETE"
}

function sed_comma2dot() {
    sed 's/,/./g'
}

function sed_dot2comma() {
    sed 's/\./,/g'
}

function sed_space_removeextra() {
    sed 's/[[:space:]]\+/ /g'
}

function sed_space_trim() {
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

function sed_space_removeall() {
    sed 's/[[:space:]]//g'
}

function sed_keep_textandnumbers() {
    sed 's/[^a-zA-Z0-9]//g'
}

function sed_keep_numbers() {
    sed 's/[^0-9]//g'
}

function sed_keep_price() {
    # Extracts price values from input text.
    # Example: echo "Cost: $456.68" | sed_keep_price      ; outputs 456.68
    # Alias function: regex_price
    sed 's/[^0-9.]//g'
}

function sed_upper2lowercase() {
    # Changes input text to all lower case letters.
    # Example: echo "This is OuTStanding" | sed_upper2lowercase
    sed 's/[A-Z]/\L&/g'
}

function sed_add2end() {
    # Adds a suffix to each line.
    # Example: echo -e "Line1\nLine2" | sed_add2end
    # Output:
    # Line1 [SUFFIX]
    # Line2 [SUFFIX]
    sed 's/$/ [SUFFIX]/'
}

function sed_removelastline() {
    # Removes the last line in the input text.
    sed '$d'
}

function sed_removefirstline() {
    # Removes the first line in the input text.
    sed '1d'
}

function sed_keeplastword() {
    # Keeps only the last word (after whitespace).
    # Example: echo "This is some text here" | sed_keeplastword    ; output is: here
    sed -E 's/.*[[:space:]]//g'
}

function sed_addemptyline() {
    # Adds a new blank line to the text input.
    sed 'G' 
}

function sed_removeemptylines() {
    # Removes all blank/empty lines in the text input.
    sed '/./!d'
}

function sed_joinlines() {
    # Removes "\n" "\r" from the end to join two lines into one, plus removes whitespaces from the end.
    sed 's/\r//' | tr -d '\n' | sed 's/[ \t]*$//'
}

function sed_joinlines_commasep() {
    # Removes \r, join lines with ", ", and removes trailing whitespaces.
    sed 's/\r//' | tr '\n' ', ' | sed 's/[ \t]*,$//'
}

function sed_joinlines_semicolonsep() {
    # Removes \r, join lines with "; ", and removes trailing whitespaces.
    sed 's/\r//' | tr '\n' '; ' | sed 's/[ \t]*;$//'
}

function sed_cleantext() {
    # Removes the weird metadata characters from the input text.
    sed 's/\x1b\[[0-9;]*m//g'
}

# Sorting functions
function sortdown_colnum() {
    # Sorts numbers in descending order based on a specific column.
    # Example: echo -e "1\n10\n5" | sortdown_colnum 1
    sort -k${1}nr
}

function sortup_colnum() {
    # Sorts numbers in ascending order based on a specific column.
    # Example: echo -e "1\n10\n5" | sortup_colnum 1
    sort -k${1}n
}

function sortdown_abs_colnum() {
    # Sorts absolute values in descending order based on a specific column.
    # Example: echo -e "-1\n10\n-5" | sortdown_abs_colnum 1
    awk '{print $1 " " $0}' | sort -k1nr | cut -d' ' -f2-
}

function sortup_abs_colnum() {
    # Sorts absolute values in ascending order based on a specific column.
    # Example: echo -e "-1\n10\n-5" | sortup_abs_colnum 1
    awk '{print $1 " " $0}' | sort -k1n | cut -d' ' -f2-
}

function sort_col() {
    # Sorts text based on a specific column.
    # Example: echo -e "c\na\nb" | sort_col 1
    sort -k${1}
}

function sed_upper2lowercase() {
    tr '[:upper:]' '[:lower:]'
}

function sed_add2end() {
    sed "s/$/$1/"
}

function sed_removelastline() {
    sed '$d'
}

function sed_removefirstline() {
    sed '1d'
}

function sed_keeplastword() {
    sed 's/.*\([[:alnum:]]\+\)$/\1/'
}

function sed_addemptyline() {
    sed 'G'
}

function sed_removeemptylines() {
    sed '/^$/d'
}

function sed_joinlines() {
    sed ':a;N;$!ba;s/\n/ /g'
}

function sed_joinlines_commasep() {
    sed ':a;N;$!ba;s/\n/,/g'
}

function sed_joinlines_semicolonsep() {
    sed ':a;N;$!ba;s/\n/;/g'
}

function sed_cleantext() {
    sed 's/[[:space:]]\+/ /g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

function regex_keep_number() {
    grep -oE '[0-9]+(\.[0-9]+)?'
}

function regex_keep_numberof_decimals() {
    grep -oE '[0-9]+\.[0-9]{'$1'}'
}

function regex_until() {
    sed -n "1,/$1/p"
}

function regex_until_specialchar() {
    sed "s/[$1].*//"
}

function regex_awk_seen() {
    awk '{print $1}' | sort | uniq -c | sort -nr
}

function regex_awk_sum() {
    awk '{sum+=$1} END {print sum}'
}

function regex_awk_remove_betweenwords() {
    awk '{for(i=1;i<=NF;i++) if($i!="'$1'") printf "%s ", $i; print ""}'
}

function regex_awk_keep_betweenwords() {
    awk '{for(i=1;i<=NF;i++) if($i=="'$1'") printf "%s ", $i; print ""}'
}

# Module initialization
function init_${MODULE_NAME}_module() {
    true
}

# Module help
function ${MODULE_NAME}_help() {
    cat << EOF
${MODULE_NAME} module v${MODULE_VERSION}
${MODULE_DESCRIPTION}

Available functions:
  regex_*          Various regex pattern matching
  sed_*            Text manipulation using sed
  regex_awk_*      Text processing using awk
EOF
}

# Initialize module
init_${MODULE_NAME}_module
