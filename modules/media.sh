#!/bin/bash

# Media module
MODULE_NAME="media"
MODULE_VERSION="1.07"
MODULE_DESCRIPTION="Audio/video/image processing functions"


# ------------ AUDIO AND VIDEO PROCESSING ----------------

function exa() {
# Extracts a segment of audio from an input file between specified start and end times.
# Example: exa this.mp3 00:14:17 00:19:22

    if [ $# -ne 3 ]; then
        echo "Extracts a segment of audio from an input file between specified start and end times."
        echo "Usage: exa input_file start_time end_time"
        echo "Example: exa this.mp3 00:14:17 00:19:22"
        return 1
    fi
    input="$1"
    start="$2"
    end="$3"
    base="${input%.*}"   # Remove extension
    ext="${input##*.}"   # Get extension
    counter=1

# Find next available filename
    while [ -e "${base}_clip_${counter}.mp3" ]; do counter=$((counter + 1)); done
    out="${base}_clip_${counter}.mp3"
    ffmpeg -i "$input" -ss "$start" -to "$end" -ar 44100 -ac 2 -ab 192k -f mp3 "$out"
}


function exc() {
# Extracts a segment of video or audio from an input file between specified start and end times.
# Example: exc this.mp4 00:14:17 00:19:22
    if [ $# -ne 3 ]; then
        echo "Extracts a segment of video or audio from an input file between specified start and end times."
        echo "Usage: exc input_file start_time end_time"
        echo "Example: exc this.mp4 00:14:17 00:19:22"
        return 1
    fi
    input="$1"
    start="$2"
    end="$3"
    base="${input%.*}"   # Remove extension
    ext="${input##*.}"   # Get extension
    counter=1

# Find next available filename
    while [ -e "${base}_clip_${counter}.${ext}" ]; do counter=$((counter + 1)); done
    out="${base}_clip_${counter}.${ext}"
    ffmpeg -i "$input" -ss "$start" -to "$end" -c copy "$out"
}


function to_mp3() {
# Converts input audio files to MP3 format with a bitrate of 256 kbps.
# Example: to_mp3 *.wav
for input_file in "$@"; do
  if [ -f "$input_file" ]; then
    local output_file="${input_file%.*}.mp3"  # Change to .mp3 based on input file extension
    ffmpeg -i "$input_file" -ar 44100 -ac 2 -ab 256k -f mp3 "$output_file"
    echo "Converted $input_file to $output_file"
  else
    echo "No such file found: $input_file"
  fi
done
}


function to_mp4() {
# Converts input video files to MP4 format with a specified bitrate.
# Example: to_mp4 3000 *.mov
if [[ $# -lt 2 ]]; then
    echo "For converting input video files to MP4 format with your custom bitrate."
    echo "Usage example for all .mov files in the current folder: to_mp4 3000 *.mov"
    echo "Usage example for one file: to_mp4 3000 somevideo.mkv"
    echo "... converts the file(s) to MP4 with specified bitrate and automatically 256kbps AAC audio."
    return 1
fi
local bitrate="$1"
shift  # Remove the first argument (bitrate) from the list of arguments
local total="$#"
local count=0
for file in "$@"; do
  if [ -f "$file" ]; then
     count=$((count + 1))
     local output="${file%.*}.mp4"
     echo -ne "\r[$count/$total] Converting: $file -> $output"
     ffmpeg -loglevel error -y -i "$file" -c:v libx264 -b:v "${bitrate}k" -c:a aac -strict experimental -b:a 256k "$output"
     echo -ne "\r[$count/$total] Done:   $file -> $output\n"
  else
     echo "No such file found: $file"
  fi
done
echo "All conversions complete!"
}


function audio_removemetadata() {
# Removes all metadata (including album art) from one or more audio files using ffmpeg.
# Overwrites the original file(s) with a clean copy.
# Example: audio_removemetadata song.mp3 track.wav *.flac
if [[ $# -eq 0 ]]; then
echo "Usage example: audio_removemetadata *.mp3"
echo "Usage example: audio_removemetadata track1.mp3 track2.mp3 *.flac *.wav"
return 1
fi

local infile tmpfile ext
for infile in "$@"; do
if [[ ! -f "$infile" ]]; then echo "Skipping: File not found: $infile"; continue; fi

ext="${infile##*.}"   # preserve extension
tmpfile="$(mktemp --tmpdir="$(dirname "$infile")" clearmetadata.XXXXXX).$ext" || {
echo "Error: Could not create temp file for $infile"
continue
}

# Run ffmpeg to strip metadata
if ffmpeg -i "$infile" -map_metadata -1 -c copy "$tmpfile" -y -loglevel error; then
mv -f "$tmpfile" "$infile"
echo "Metadata cleared from: $infile"
else
echo "Error: Failed to process $infile"
rm -f "$tmpfile"
fi
done
rm clearmetadata.*
}




# ------------ IMAGE PROCESSING ----------------

function to_gif() {
# Converts input video files to GIF format.
# Example: to_gif *.mp4
if [[ $# -lt 1 ]]; then
  echo "For converting input video files to GIF format."
  echo "Usage example: to_gif video_file.mp4"
  return 1
fi
local count=0
local total="$#"
for file in "$@"; do
if [ -f "$file" ]; then
  count=$((count + 1))
  local output="${file%.*}.gif"
  echo "Converting '$file' to '$output'..."
  ffmpeg -t 10 -i "$file" -vf "fps=15,scale=640:-1:flags=lanczos" "$output"
  echo "Done: '$file' -> '$output'"
else
  echo "No such file found: $file"
fi
done
echo "All conversions complete!"
}


function to_png() {
# Converts input image files to PNG format.
# Example: to_png *.jpg
if [[ $# -lt 1 ]]; then
  echo "For converting input image files to PNG format."
  echo "Usage example: to_png photo1.jpg"
  return 1
fi
local count=0
local total="$#"
for file in "$@"; do
if [ -f "$file" ]; then
  count=$((count + 1))
  local output="${file%.*}.png"
  echo "Converting '$file' to '$output'..."
  convert "$file" "$output"
  echo "Done: '$file' -> '$output'"
else
  echo "No such file found: $file"
fi
done
echo "All conversions complete!"
}


function to_jpg() {
# Converts input image files to JPG format.
# Example: to_jpg *.png
if [[ $# -lt 1 ]]; then
  echo "For converting input image files to JPG format."
  echo "Usage example: to_jpg photo1.png"
  return 1
fi
local count=0
local total="$#"
for file in "$@"; do
if [ -f "$file" ]; then
  count=$((count + 1))
  local output="${file%.*}.jpg"
  echo "Converting '$file' to '$output'..."
  convert "$file" "$output"
  echo "Done: '$file' -> '$output'"
else
  echo "No such file found: $file"
fi
done
echo "All conversions complete!"
}


function generateQR() {
# Generates a QR code image file from an input text, link or some other strings.
# Usage: generateQR "https://qortal.dev"
# Outputs the file to Home folder as QR.png
# Pro Tip: generateQR "https://qortal.dev" && ls /home/$USER/QR.png | toclipboard
# This puts the generated QR code image to the Clipboard, ready to be pasted :)
if [[ $# -ne 1 ]]; then
echo "For generating QR code out of any text or input. The generated QR-code image file (QR.png) will end up in your home folder."
echo "Usage example: generateQR \"https://qortal.dev\""
return 1
fi
qrencode -o /home/$USER/QR.png -s 15 "$1"
echo "Generated /home/$USER/QR.png"
}


function scan_jpg() {
# Scans from a connected scanner into JPG image file.
# Output files end up in Scanned folder (under your Home folder).
mkdir -p /home/$USER/Scanned
date_time=$(date +"%d.%m_%H:%M:%S")
filename="/home/$USER/Scanned/$date_time"
scanimage --resolution 300 --mode Color --format=pnm > /tmp/scanned_image.pnm
sleep 1
convert /tmp/scanned_image.pnm $filename.jpg
}


function scan_pdf() {
# Scans from a connected scanner into PDF image file.
# Output files end up in Scanned folder (under your Home folder).
mkdir -p /home/$USER/Scanned
date_time=$(date +"%d.%m_%H:%M:%S")
failinimi="/home/$USER/Scanned/$date_time"
scanimage --resolution 300 --mode Color --format=pnm > /tmp/scanned_image.pnm
sleep 1
convert /tmp/scanned_image.pnm $filename.pdf
}


function pdf_rotate_clockwise() {
# Rotates a PDF file clockwise.
# Example: pdf_rotate_clockwise "document.pdf"
local file=${1?Usage example: pdf_rotate_clockwise "document.pdf"}
gs -o "rotated_$1" -sDEVICE=pdfwrite -c "<</Orientation 3>> setpagedevice" -f "$1"
}


function pdf_rotate_allinfolder_clockwise() {
# Rotates all PDF files in the current folder clockwise.
# Example: PDF_rotate_allinfolder_clockwise
for file in *.pdf; do gs -o "$file" -sDEVICE=pdfwrite -c "<</Orientation 3>> setpagedevice" -f "$file"; done
}


function pdf_compress_allinfolder() {
# Compresses all PDF files in the current folder.
# Example: PDF_compress_allinfolder
for file in *.pdf; do gs -o "$file" -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -c "<</Orientation 3>> setpagedevice" -f "$file"; done
}


function pdf2txt_OCR() {
# Extracts data from a PDF to a text file using OCR.
# Example: pdf2txt_OCR "document.pdf"
echo "Processing:" $1
tesseract "$1" "$1.txt" -l est
replace_extension jpg.txt.txt txt
}


function pdf2txt_OCR_allin() {
# Extracts data from all PDF files in the current folder, to text files using OCR.
# Example: pdf2txt_OCR_allin
while IFS= read -r file; do
echo "Processing:" $file
output="${file%.*}.txt"   # $output will have a replaced extension
tesseract "$file" "$output" -l est
replace_extension txt.txt txt
done
}


function OCR_recursively_alljpg2txt() {
# Creates .txt files of all found jpg files in current folder AND SUBFOLDERS!
# Example: OCR_recursively_alljpg2txt
find . -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) | while IFS= read -r img; do
txt="${img%.*}.txt"
if [[ ! -f "$txt" ]]; then
  echo "OCR: $img → $txt"
  tesseract "$img" "${img%.*}" -l est &> /dev/null
else
  echo "Skipped (already exists): $txt"
fi
done
}


function resize50() {
# Resizes all image files in current folder AND ITS SUBFOLDERS to -50% image size by overwriting method, meaning shrinking the original images 50% in their resolution, without making any copies.
# Example: resize50 jpg
ext="$1"
if [[ -z "$ext" ]]; then
echo "Resize (make 50% smaller) all jpg, png, webp or other images in current folder AND in the subfolders. NB! It does not create copies, but just overwrites the same images."
echo "Usage example: resize50 jpg"
echo "Usage example: resize50 PNG"
return 1
fi

ext="${ext,,}" # Normalize input to lowercase

case "$ext" in # Build extension patterns
  jpg)
    exts=("*.jpg" "*.JPG" "*.jpeg" "*.JPEG")
    ;;
  png)
    exts=("*.png" "*.PNG")
    ;;
  webp)
    exts=("*.webp" "*.WEBP")
    ;;
  *)
    exts=("*.${ext}" "*.${ext^^}")
    ;;
esac

# Build find command dynamically
find_cmd=(find . -type f)
for pattern in "${exts[@]}"; do
find_cmd+=(-iname "$pattern" -o)
done
unset 'find_cmd[${#find_cmd[@]}-1]'  # remove last -o

# Run find and resize each matching file
"${find_cmd[@]}" | while IFS= read -r img; do
echo "Resizing: $img"
convert "$img" -resize 50% "$img"
done
}


function jpg2txt_allincwd() {
# Extracts data into text files from image files or pdf files, inside the current folder.
# Example: jpg2txt_allincwd *.pdf
# Example: jpg2txt_allincwd *.jpg
pattern="${1:-*.jpg}"       # Check if an argument is passed, otherwise default to *.jpg
for f in $pattern; do pdf2txt_OCR "$f" "$f"; done   # Loop through the files based on the provided pattern
}


function toclipboard() {
# Copies variable content, text, image or file contents to the clipboard, ready to be pasted (with Ctrl+V).
# Example for text: echo "Hello, World!" | toclipboard
# Example for image: ls zoom.png | toclipboard

input=$(cat) # Read input from stdin or a pipe
if [[ -f "$input" ]]; then # Check if the input is a file and exists
case "$input" in
    *.png)
        xclip -selection clipboard -t image/png -i "$input"
        ;;
    *.jpg | *.jpeg)
        convert "$input" png:- | xclip -selection clipboard -t image/png
        ;;
    *)
        echo -n "$input" | xclip -selection clipboard  # Copy the file path to clipboard, if any other file type
        ;;
esac
else
echo "$input" | xclip -selection clipboard   # If it's not a file, copy the input as plain text
fi
}


# ------------ DOCUMENTS PROCESSING ------------

function xlsx2pdf() {
# Converts an excel file to PDF format using LibreOffice engine.
# Example: xlsx2pdf "file.xlsx"
local test=$(which libreoffice)
if [[ $test != "" ]]; then
libreoffice --headless --convert-to pdf "$1"
else
echo "Please make sure to have LibreOffice installed for this function to work."
fi
}


function ods2xlsx() {
# Converts an ODS file to XLSX format using LibreOffice engine.
# Example: ods2xlsx "file.ods"
local test=$(which libreoffice)
if [[ $test != "" ]]; then
libreoffice --headless --convert-to xlsx "$1"
else
echo "Please make sure to have LibreOffice installed for this function to work."
fi
}


function pdf2docx() {
# Converts a PDF file to DOCX format and saves it to a specified folder by using LibreOffice engine.
# Example: pdf2docx file.pdf ~/Desktop/
local file=${1?No input given for the file name}
local folder=${2:-$(pwd)}  # Default to current directory if no output folder is provided
local test=$(which libreoffice)
if [[ $test != "" ]]; then
libreoffice --headless --convert-to docx --outdir "$folder" "$file"
else
echo "Please make sure to have LibreOffice installed for this function to work."
fi
}



# ------------ AUDIO PROCESSES ----------------

function is_audio_playing() {
# Function to check if any application is currently producing audio output
# And if so, do something, e.g. close that window/application
echo "Waiting for audio output..."
while true; do
audioapp=$(pactl list sink-inputs | awk -F\" '/application.process.binary/ {print $2}')  # get the name of the process playing audio
if [[ $audioapp != "" ]]; then  # if $audioapp is not empty, but something was found, then ...
playtime=$(date | regex_time)
echo "Audio detected from $audioapp at $playtime"
sleep 2
window close $audioapp  # In this case we could just close that process/app window to stop playing
break
fi
sleep 1 && clear
done
}




# ------------ VARIA ----------------

function yt-downloadthumbnail() {
# Function to download the thumbnail of the video from YouTube
local link="$1"
if [[ -z "$link" ]]; then
echo "Function to download the thumbnail of the video from YouTube."
echo "Usage example: yt-downloadthumbnail https://www.youtube.com/watch?v=vJabNEwZIuc"
return 1
fi
ytid=$(echo $link | regex_youtube_id)
for quality in "maxresdefault" "hq720" "sddefault"; do
thumbnail="https://i.ytimg.com/vi/$ytid/${quality}.jpg"
if wget -q --spider "$thumbnail"; then
  wget -q "$thumbnail" -O "$ytid.jpg"
  return
fi
done
}


function wget_batch() {
    local baseurl="$1"
    shift

    if [[ -z "$baseurl" ]]; then
        echo "Function to download a batch of files with wget."
        echo "Usage:"
        echo "  wget_batch <base_url> <filelist.txt>"
        echo "  wget_batch <base_url> file1 file2 file3 ..."
        echo "Usage example: wget_batch https://ilm.ee/client/failid/ filelist.txt"
        echo "Usage example: wget_batch https://ilm.ee/client/failid/ galerii322002.jpg galerii322003.jpg galerii322008.jpg"
        echo "NB: If you use a filelist file, just have only the filenames on each row, one below another."
        return 1
    fi

    local files=()

    if [[ $# -eq 1 && -f "$1" ]]; then
        # Read from file
        while IFS= read -r filename; do
            [[ -n "$filename" ]] && files+=("$filename")
        done < "$1"
    else
        # Remaining args are filenames
        files=("$@")
    fi

    for filename in "${files[@]}"; do
        local url="${baseurl%/}/$filename"
        if wget -q --spider "$url"; then
            wget -q "$url" -O "$filename"
            echo "✔ Saved $filename"
        else
            echo "✘ File not found: $url"
        fi
    done
}


###########################################
#  Automatic FFmpeg Screen Recorder
###########################################

# Detect default screen resolution
function get_default_resolution() {
  xrandr | awk '/\*/ {print $1; exit}'
}

# Detect default microphone (prefer Blue Yeti, but if not found, take whatever is the default)
function get_default_mic() {
  local mic
  mic=$(pactl list short sources | grep -i 'blue\|yeti' | awk '{print $2}' | grep -E "input")
  [[ -z "$mic" ]] && mic=$(pactl get-default-source)
  echo "$mic"
}

# Detect default desktop audio output monitor
function get_default_audio_output_monitor() {
  local monitor
  monitor=$(pactl list short sources | grep ".monitor" | head -n1 | awk '{print $2}')
  echo "$monitor"
}


function record_screen() {
# Function to record screen + mic + default audio output into mkv file
  local reso=$(get_default_resolution)
  local mic=$(get_default_mic)
  local monitor=$(get_default_audio_output_monitor)
  local outfile="$HOME/Videos/record_$(date +%F_%H-%M-%S).mkv"

  echo "Recording screen ($reso)"
  echo "Mic: $mic"
  echo "Audio: $monitor"

  nohup ffmpeg -f pulse -i "$monitor" -f pulse -i "$mic" -filter_complex amix=inputs=2:duration=first:dropout_transition=2 -f x11grab -r 30 -s "$reso" -i :0.0 -acodec aac -pix_fmt yuv420p -preset ultrafast -crf 25 -threads 12 "$outfile" >/dev/null 2>&1 &
  echo $! > /tmp/record_screen.pid
}


function record_stop() {
  if [[ -f /tmp/record_screen.pid ]]; then
    PID=$(cat /tmp/record_screen.pid)
    if kill "$PID" 2>/dev/null; then
      echo "🛑 Recording stopped."
      rm -f /tmp/record_screen.pid
    else
      echo "Could not stop recording (PID not found)."
    fi
  else
    echo "No active recording found."
  fi
}

###########################################
#  END OF FFmpeg Screen Recorder section
###########################################

