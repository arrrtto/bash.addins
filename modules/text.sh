#!/bin/bash

# Text/Numbers processing module
MODULE_NAME="text"
MODULE_VERSION="1.08"
MODULE_DESCRIPTION="Text processing and RegEx functions"


# HOW TO USE THESE FUNCTIONS? With piping, of course!

function regex_email() {
# Extracts email addresses from input text.
# Example: cat source.html | regex_email
grep -E -o '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
}


function regex_links_https() {
# Extracts all https links addresses from input text.
# Example: cat source.html | regex_links_https
grep -E -o 'https?://[a-zA-Z0-9./?=_-]+'
}


function regex_htmltag() {
# Matches HTML tags in input text, such as <div class="container"> and <img src="image.png" />
# Example: cat index.html | regex_htmltag
grep -E -o '<[a-zA-Z][a-zA-Z0-9]*[^>]*>'
}


function regex_ipaddress() {
# Extracts IP addresses from input text.
# Example: some_text | regex_ipaddress
grep -E -o '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b'
}


function regex_price() {
# Extracts price values from input text.
# Example: echo "Cost: $456.68" | regex_price      ; outputs 456.68
sed 's/[^0-9.]//g'
}


function regex_number() {
# Extracts numeric values from input text.
# Example: echo "Cost: $ 456.68" | regex_number    ; outputs 456 and 68 on separate lines
# NB! Best to NOT use echo $456, because the first number after $ gets lost when using echo.
grep -E -o '[0-9]+'
}


function regex_phonenumber() {
# Extracts phone numbers from input text.
grep -E -o '(\+?[0-9]{1,3}[-. ]?)?(\(?[0-9]{2,4}\)?[-. ]?)?[0-9]{3,4}[-. ][0-9]{3,4}'
}


function regex_date() {
# Extracts various date formats like DD-MM-YYYY, YYYY/MM/DD, DD.MM.YYYY, etc.
# Example: echo "Date: 14.05.2022" | regex_date → 14.05.2022
grep -E -o '[0-9]{4}[./-][0-9]{2}[./-][0-9]{2}|[0-9]{2}[./-][0-9]{2}[./-][0-9]{4}'
}


function regex_time() {
# Extracts time from input text.
# Example: echo "2025-05-26T18:04:59+00:00" | regex_time → 18:04:59
grep -E -o '[0-9]{2}:[0-9]{2}:[0-9]{2}?'
}


function regex_usernamehandle() {
# Extracts usernames or handles, which start with @ from input text.
# Example: echo "This is @my_user useraccount" | regex_usernamehandle
grep -E -o '@[a-zA-Z0-9_]+'
}


function regex_hashtag() {
# Extracts hashtags from input text.
# Example: echo "This is #cool stuff" | regex_hashtag
grep -E -o '#[a-zA-Z0-9_]+'
}


function regex_youtube_id() {
# Extracts YouTube video ID from YouTube links.
# Example: echo "https://www.youtube.com/watch?v=dQw4w9WgXcQ" | regex_youtube_id    ; → dQw4w9WgXcQ
# Example: echo "https://youtu.be/abcd1234567" | regex_youtube_id    ; → abcd1234567
sed -nE 's~.*(v=|vi=|be/|embed/|shorts/|/v/|/e/|watch\?v=)([a-zA-Z0-9_-]{11}).*~\2~p'
}


function regex_sha256() {
# Extracts SHA-256 hashes from input text.
# Example: some_text | regex_sha256
grep -E -o '\b[a-fA-F0-9]{64}\b'
}


function regex_bitcoin() {
# Extracts Bitcoin addresses from input text.
# Example: some_text | regex_bitcoin
grep -E -o '\b[13][a-km-zA-HJ-NP-Z1-9]{25,34}\b'
}


function regex_uuid() {
# Extracts UUIDs from input text.
# Example: some_text | regex_uuid
grep -E -o '\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b'
}


function regex_sql() {
# Extracts SQL commands from input text.
# Example: some_text | regex_sql
grep -E -o '\b(SELECT|INSERT|UPDATE|DELETE)\b[^;]+;'
}


function sed_comma2dot() {
# Replaces commas with dots in input text.
# Example: echo "1,23" | sed_comma2dot
sed 's/,/./g'
}


function sed_dot2comma() {
# Replaces dots with commas in input text.
# Example: echo "1.23" | sed_dot2comma    ; result: 1,23
sed 's/./,/g'
}


function sed_space_removeextra() {
# Replaces multiple (white)spaces with one space.
# Example: echo "This    is some text" | sed_space_removeextra
sed 's/[[:space:]]\+/ /g'
}


function sed_space_trim() {
# Removes leading and trailing whitespaces.
sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}


function sed_space_removeall() {
# Removes all whitespaces (Spaces, Tabs, Newlines)
sed ':a;N;$!ba;s/[[:space:]]//g'
}


function sed_keep_textandnumbers() {
# Filters out text characters and numbers from the input text.
sed 's/[^a-zA-Z0-9]//g'
}


function sed_keep_numbers() {
# Keeps only numbers in output.
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
# Removes \r, join lines with ", ", and removes trailing whitespaces.
sed 's/\r//' | tr '\n' '; ' | sed 's/[ \t]*;$//'
}


function sed_cleantext() {
# Removes the weird metadata characters from the input text.
sed 's/\x1b\[[0-9;]*m//g'
}


function sed_keeplinesbetween() {
# Outputs only the lines between certain keywords, taking in as parameters the starting line keyword and the ending line keyword.
# Example: Let's say you have a file.txt with these lines:
# Hey brother,
# Did you know
# that this is some text
# and SED is a cool piece of software?
# ----
# cat file.txt | sed_keeplinesbetween Did ----
if [ "$#" -ne 2 ]; then echo "Usage: sed_keeplinesbetween <start_word> <end_word>"; return 1; fi
local start_word="$1"
local end_word="$2"
sed -n "/${start_word}/,/^${end_word}/!d" | sed "/^${end_word}/q"
}



function regex_keep_number() {
# Keeps only the numbers and dots (.) which are found from the input text.
# Example: echo "The price is 0.54 USD" | regex_keep_number    ; Output: 0.54
grep -oE "[0-9]+\.[0-9]+"
}


function regex_keep_numberof_decimals() {
# Keeps only a selected number of decimals after dot (.)
# Ex: echo "0.24005" | regex_keep_numberof_decimals 2
# Output: 0.24
local input
read -r input
local digits="${1:-2}"
echo "$input" | grep -oE "^[0-9]+\.[0-9]{1,$digits}"
}


function regex_until() {
# Deletes everything after a certain character.
# Example: echo "helloXworld" | regex_until "X"    ->    Output: hello
sed -e "s/$1.*//"
}


function regex_until_specialchar() {
# If input text contains special characters like / or &, then uses a different delimiter (| instead of /):
# Example: echo "some text & with" | regex_until_specialchar '&'    ; Output: some text
local char="$1"
sed "s|$char.*||"
}


function regex_awk_seen() {
# Skips the already seen outputs/text when going through the lines of text.
# The point is to not show duplicate lines, if these have already displayed once.
awk '!seen[$0]++'
}


function regex_awk_sum() {
# Adds numbers, that are outputted on lines of text, by summing them together.
# Very useful for calculating sums.
# Example: cat numbers.txt | regex_awk_sum
# If numbers.txt file contains "4.52" on the first line, and "2" on second line,
# then the output is the sum of them (4.52 + 2), in this case 6.52
awk '{sum+=$1} END {print sum}'
}


function regex_awk_remove_betweenwords() {
# Removes a part of the input text, that is between two defined words.
# Example: echo "This is some random text" | regex_awk_remove_betweenwords "This" "some"
# outputs to " random text"
local start=${1?Need the starting word and ending word}
local start="$1"
local end="$2"
awk -v s="$start" -v e="$end" '{gsub(s ".*" e, ""); print}'
}


function regex_awk_keep_betweenwords() {
# Keeps a part of the input text, starting with the first word and ending with the second.
# Example: echo "This is some random text" | regex_awk_keep_betweenwords "some" "text"
# outputs to: "some random text", so it keeps the beginning word and the ending word also.
local start=${1?Need the starting word and ending word}
local start="$1"
local end="$2"
awk "{match(\$0, /$start .*?$end/, m); if (m[0]) print m[0]}"
}


function sed_keep_between_xml() {
# Keeps only the part of data between XML format data like <something>data</something>
# Example: echo "<title>New video</title>" | sed_keep_betweenxmlwords "title"
# outputs to: "New video"
local start=${1?Need the word that is inside the <> brackets}
grep -E "<$1>" | sed -E "s:.*<$1>(.*)</$1>.*:\1:"
}


# -- ADDITIONAL INFO ABOUT SORTING FUNCTIONS BELOW --

# Sorting down or up, based on the number and sorting based on column
# e.g. the input for sorting is looks like:
# Toivo,Teivas,34.03,Something
# Annika,Leivas,-54.00,Somethingelse
# then the column to be sorted by is 3, and separator is automatically set to ","

#| Function                          | Sort Order | Based On    | Result Starts With |
#| ---------------------------- | ------------ | ------------- | -------------------- |
#| `sortdown_colnum`         | Ascending  | Real values | Most negative      |
#| `sortup_colnum`             | Descending | Real values | Most positive      |
#| `sortdown_abs_colnum` | Ascending  | Abs values  | Closest to 0         |
#| `sortup_abs_colnum`   | Descending | Abs values  | Furthest from 0    |

function sortdown_colnum() {
# Sorts input data by a specified column in descending numerical order.
# Example: cat data.csv | sortdown_colnum 3    ; sorting based on the column number 3
col="$1"
awk -F',' -v col="$col" '{ print $col "|" $0 }' | sort -t'|' -k1,1n | cut -d'|' -f2-
}


function sortup_colnum() {
# Sorts input data by a specified column in ascending numerical order.
# Example: cat data.csv | sortup_colnum 3    ; sorting based on the column number 3
col="$1"
awk -F',' -v col="$col" '{ print $col "|" $0 }' | sort -t'|' -k1,1nr | cut -d'|' -f2-
}


function sortdown_abs_colnum() {
# Sorts input data by a specified column in descending order, treating negative values as positive.
# Example: cat data.csv | sortdown_abs_colnum 3
col="$1"
awk -F',' -v col="$col" '{
  a = $col
  gsub(/-/, "", a)
  print a "|" $0
}' | sort -t'|' -k1,1n | cut -d'|' -f2-
}


function sortup_abs_colnum() {
# Sorts input data by a specified column in ascending order, treating negative values as positive.
# Example: cat data.csv | sortup_abs_colnum 3
col="$1"
awk -F',' -v col="$col" '{
  a = $col
  gsub(/-/, "", a)
  print a "|" $0
}' | sort -t'|' -k1,1nr | cut -d'|' -f2-
}


function sort_col() {
# Sorts input data by a specified column number, either numerically or alphabetically, based on the mode (up or down).
# Example: cat data.csv | sort_col 2 up
# sort_col 2 up - sorts A-Z, if used non-numerical, but words
# sort_col 2 down - sorts Z-A
col="$1"
mode="$2"

awk -F',' -v col="$col" '
BEGIN { is_number=1 }
{
  field = $col
  # Check if its a number (handle negatives & decimals)
  if (field !~ /^-?[0-9]+(\.[0-9]+)?$/) {
    is_number = 0
  }
  data[NR] = $0
  fields[NR] = field
}
END {
  for (i = 1; i <= NR; i++) {
    val = fields[i]
    if (is_number && (mode == "upabs" || mode == "downabs")) {
      gsub(/-/, "", val)
    }
    if (is_number)
      printf("%20.10f|%s\n", val, data[i])
    else
      print val "|" data[i]
  }
}
' mode="$mode" | {
  case "$mode" in
    up|upabs)
      sort
      ;;
    down|downabs)
      sort -r
      ;;
    *)
      echo "Invalid mode: $mode" >&2
      return 1
      ;;
  esac
} | cut -d'|' -f2-
}



