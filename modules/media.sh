#!/bin/bash

# Media module
MODULE_NAME="media"
MODULE_VERSION="1.2"
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
    local input="$1" start="$2" end="$3" base counter out
    [[ -f "$input" ]] || { echo "File not found: $input" >&2; return 1; }
    base="${input%.*}"   # Remove extension
    counter=1

# Find next available filename
    while [ -e "${base}_clip_${counter}.mp3" ]; do counter=$((counter + 1)); done
    out="${base}_clip_${counter}.mp3"
    ffmpeg -nostdin -hide_banner -i "$input" -ss "$start" -to "$end" -ar 44100 -ac 2 -b:a 192k -f mp3 "$out"
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
    local input="$1" start="$2" end="$3" base ext counter out
    [[ -f "$input" ]] || { echo "File not found: $input" >&2; return 1; }
    base="${input%.*}"   # Remove extension
    ext="${input##*.}"   # Get extension
    counter=1

# Find next available filename
    while [ -e "${base}_clip_${counter}.${ext}" ]; do counter=$((counter + 1)); done
    out="${base}_clip_${counter}.${ext}"
    ffmpeg -nostdin -hide_banner -i "$input" -ss "$start" -to "$end" -map 0 -c copy "$out"
}


function to_mp3() {
# Converts input audio files to MP3 format with a bitrate of 256 kbps.
# Example: to_mp3 *.wav
[[ $# -gt 0 ]] || { echo "Usage: to_mp3 <audio-file> [...]" >&2; return 2; }
local input_file output_file
for input_file in "$@"; do
  if [ -f "$input_file" ]; then
    output_file="${input_file%.*}.mp3"
    [[ "$output_file" == "$input_file" ]] && output_file="${input_file%.*}_converted.mp3"
    if ffmpeg -nostdin -hide_banner -n -i "$input_file" -ar 44100 -ac 2 -b:a 256k -f mp3 "$output_file"; then
      echo "Converted $input_file to $output_file"
    else
      echo "Conversion failed: $input_file" >&2
    fi
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
[[ "$bitrate" =~ ^[1-9][0-9]*$ ]] || { echo "Bitrate must be a positive number in kbit/s." >&2; return 2; }
shift  # Remove the first argument (bitrate) from the list of arguments
local total="$#"
local count=0
for file in "$@"; do
  if [ -f "$file" ]; then
     count=$((count + 1))
     local output="${file%.*}.mp4"
     [[ "$output" == "$file" ]] && output="${file%.*}_converted.mp4"
     echo -ne "\r[$count/$total] Converting: $file -> $output"
     if ffmpeg -nostdin -hide_banner -loglevel error -n -i "$file" -map 0:v:0 -map 0:a? -c:v libx264 -b:v "${bitrate}k" -c:a aac -b:a 256k -movflags +faststart "$output"; then
       echo -ne "\r[$count/$total] Done:   $file -> $output\n"
     else
       echo -e "\n[$count/$total] Failed: $file" >&2
     fi
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
tmpfile="$(mktemp --tmpdir="$(dirname "$infile")" --suffix=".$ext" .clearmetadata.XXXXXX)" || {
echo "Error: Could not create temp file for $infile"
continue
}

# Run ffmpeg to strip metadata
if ffmpeg -nostdin -hide_banner -i "$infile" -map 0:a? -map_metadata -1 -map_chapters -1 -c copy "$tmpfile" -y -loglevel error; then
chmod --reference="$infile" "$tmpfile" 2>/dev/null || true
mv -f "$tmpfile" "$infile"
echo "Metadata cleared from: $infile"
else
echo "Error: Failed to process $infile"
rm -f "$tmpfile"
fi
done
}


function audiosync() {
# Syncs audio and video of a mp4 video file if the audio is off by 0.26 seconds
# Example: audiosync this.mp4

    if [ $# -ne 1 ]; then
        echo "Syncs audio and video of a mp4 video file if the audio is off by 0.26 seconds."
        echo "Usage example: audiosync this.mp4"
        return 1
    fi
    local input="$1" base out
    [[ -f "$input" ]] || { echo "File not found: $input" >&2; return 1; }
    base="${input%.*}"   # Remove extension
    out="${base}_synced.mp4"
    ffmpeg -nostdin -hide_banner -n -i "$input" -itsoffset 0.2666667 -i "$input" -map 1:v:0 -map 0:a:0 -c copy -map_metadata 0 -movflags +faststart "$out"
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
  [[ "$output" == "$file" ]] && output="${file%.*}_converted.gif"
  echo "Converting '$file' to '$output'..."
  if ffmpeg -nostdin -hide_banner -n -t 10 -i "$file" -vf "fps=15,scale=640:-1:flags=lanczos" "$output"; then
    echo "Done: '$file' -> '$output'"
  else
    echo "Failed: '$file'" >&2
  fi
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
  [[ "$output" == "$file" ]] && output="${file%.*}_converted.png"
  if [[ -e "$output" ]]; then echo "Skipping: output already exists: $output" >&2; continue; fi
  echo "Converting '$file' to '$output'..."
  if convert "$file" "$output"; then echo "Done: '$file' -> '$output'"; else echo "Failed: '$file'" >&2; fi
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
  [[ "$output" == "$file" ]] && output="${file%.*}_converted.jpg"
  if [[ -e "$output" ]]; then echo "Skipping: output already exists: $output" >&2; continue; fi
  echo "Converting '$file' to '$output'..."
  if convert "$file" -background white -alpha remove -alpha off "$output"; then echo "Done: '$file' -> '$output'"; else echo "Failed: '$file'" >&2; fi
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
qrencode -o "$HOME/QR.png" -s 15 "$1"
echo "Generated $HOME/QR.png"
}


function scan_jpg() {
# Scans from a connected scanner into JPG image file.
# Output files end up in Scanned folder (under your Home folder).
local scan_dir="$HOME/Scanned" date_time filename tmpfile
mkdir -p "$scan_dir" || return 1
date_time=$(date +"%Y-%m-%d_%H-%M-%S_%N")
filename="$scan_dir/$date_time.jpg"
tmpfile=$(mktemp --suffix=.pnm) || return 1
if scanimage --resolution 300 --mode Color --format=pnm > "$tmpfile" && convert "$tmpfile" "$filename"; then
  echo "Saved: $filename"
else
  echo "Scan failed." >&2
  rm -f -- "$tmpfile"
  return 1
fi
rm -f -- "$tmpfile"
}


function scan_pdf() {
# Scans from a connected scanner into PDF image file.
# Output files end up in Scanned folder (under your Home folder).
local scan_dir="$HOME/Scanned" date_time filename tmpfile
mkdir -p "$scan_dir" || return 1
date_time=$(date +"%Y-%m-%d_%H-%M-%S_%N")
filename="$scan_dir/$date_time.pdf"
tmpfile=$(mktemp --suffix=.pnm) || return 1
if scanimage --resolution 300 --mode Color --format=pnm > "$tmpfile" && convert "$tmpfile" "$filename"; then
  echo "Saved: $filename"
else
  echo "Scan failed." >&2
  rm -f -- "$tmpfile"
  return 1
fi
rm -f -- "$tmpfile"
}


function pdf_rotate_clockwise() {
# Rotates a PDF file clockwise.
# Example: pdf_rotate_clockwise "document.pdf"
local file="${1:-}" dir name output
[[ -f "$file" ]] || { echo 'Usage: pdf_rotate_clockwise "document.pdf"' >&2; return 2; }
dir=$(dirname "$file"); name=$(basename "$file")
output="$dir/rotated_$name"
[[ ! -e "$output" ]] || { echo "Output already exists: $output" >&2; return 1; }
gs -q -o "$output" -sDEVICE=pdfwrite -c "<</Orientation 3>> setpagedevice" -f "$file"
}


function pdf_rotate_allinfolder_clockwise() {
# Rotates all PDF files in the current folder clockwise.
# Example: PDF_rotate_allinfolder_clockwise
local file tmp nullglob_was_set=0
shopt -q nullglob && nullglob_was_set=1
shopt -s nullglob
for file in *.pdf; do
  tmp=$(mktemp --tmpdir=. --suffix=.pdf .pdfrotate.XXXXXX) || continue
  if gs -q -o "$tmp" -sDEVICE=pdfwrite -c "<</Orientation 3>> setpagedevice" -f "$file"; then
    chmod --reference="$file" "$tmp" 2>/dev/null || true
    mv -- "$tmp" "$file"
  else
    echo "Failed to rotate: $file" >&2
    rm -f -- "$tmp"
  fi
done
(( nullglob_was_set )) || shopt -u nullglob
}


function pdf_compress_allinfolder() {
# Compresses all PDF files in the current folder.
# Example: PDF_compress_allinfolder
local file tmp nullglob_was_set=0
shopt -q nullglob && nullglob_was_set=1
shopt -s nullglob
for file in *.pdf; do
  tmp=$(mktemp --tmpdir=. --suffix=.pdf .pdfcompress.XXXXXX) || continue
  if gs -q -o "$tmp" -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -f "$file"; then
    chmod --reference="$file" "$tmp" 2>/dev/null || true
    mv -- "$tmp" "$file"
  else
    echo "Failed to compress: $file" >&2
    rm -f -- "$tmp"
  fi
done
(( nullglob_was_set )) || shopt -u nullglob
}


function pdf2txt_OCR() {
# Extracts data from a PDF to a text file using OCR.
# Example: pdf2txt_OCR "document.pdf"
local file="${1:-}" output_base temp_dir temp_text page
[[ -f "$file" ]] || { echo "Usage: pdf2txt_OCR <PDF-or-image-file>" >&2; return 2; }
output_base="${file%.*}"
echo "Processing: $file"
if [[ "${file,,}" == *.pdf ]]; then
  command -v pdftoppm >/dev/null 2>&1 || {
    echo "pdf2txt_OCR: pdftoppm is required for PDF OCR (package: poppler-utils)" >&2
    return 1
  }
  temp_dir=$(mktemp -d) || return 1
  temp_text="$temp_dir/output.txt"
  if ! pdftoppm -png -r 300 "$file" "$temp_dir/page" >/dev/null 2>&1; then
    rm -rf -- "$temp_dir"
    echo "Could not render PDF pages: $file" >&2
    return 1
  fi
  : > "$temp_text"
  for page in "$temp_dir"/page-*.png; do
    tesseract "$page" stdout -l est 2>/dev/null >> "$temp_text" || {
      rm -rf -- "$temp_dir"
      return 1
    }
  done
  mv -- "$temp_text" "${output_base}.txt" || { rm -rf -- "$temp_dir"; return 1; }
  rm -rf -- "$temp_dir"
else
  temp_dir=$(mktemp -d) || return 1
  if tesseract "$file" "$temp_dir/output" -l est && mv -- "$temp_dir/output.txt" "${output_base}.txt"; then
    rm -rf -- "$temp_dir"
  else
    rm -rf -- "$temp_dir"
    return 1
  fi
fi
}


function pdf2txt_OCR_allin() {
# Extracts data from all PDF files in the current folder, to text files using OCR.
# Example: pdf2txt_OCR_allin
local file nullglob_was_set=0
shopt -q nullglob && nullglob_was_set=1
shopt -s nullglob
for file in *.pdf; do pdf2txt_OCR "$file"; done
(( nullglob_was_set )) || shopt -u nullglob
}


function OCR_recursively_alljpg2txt() {
# Creates .txt files of all found jpg files in current folder AND SUBFOLDERS!
# Example: OCR_recursively_alljpg2txt
local img txt
while IFS= read -r -d '' img; do
txt="${img%.*}.txt"
if [[ ! -f "$txt" ]]; then
  echo "OCR: $img → $txt"
  tesseract "$img" "${img%.*}" -l est &> /dev/null
else
  echo "Skipped (already exists): $txt"
fi
done < <(find . -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0)
}


function resize50() {
# Resizes all image files in current folder AND ITS SUBFOLDERS to -50% image size by overwriting method, meaning shrinking the original images 50% in their resolution, without making any copies.
# Example: resize50 jpg
local ext="$1"
if [[ -z "$ext" ]]; then
echo "Resize (make 50% smaller) all jpg, png, webp or other images in current folder AND in the subfolders. NB! It does not create copies, but just overwrites the same images."
echo "Usage example: resize50 jpg"
echo "Usage example: resize50 PNG"
return 1
fi

ext="${ext,,}" # Normalize input to lowercase

case "$ext" in # Build extension patterns
  jpg)
    local -a exts=("*.jpg" "*.jpeg")
    ;;
  png)
    local -a exts=("*.png")
    ;;
  webp)
    local -a exts=("*.webp")
    ;;
  *)
    local -a exts=("*.${ext}")
    ;;
esac

# Build find command dynamically
local pattern
local -a find_cmd=(find . -type f \()
for pattern in "${exts[@]}"; do
find_cmd+=(-iname "$pattern" -o)
done
unset 'find_cmd[${#find_cmd[@]}-1]'  # remove last -o
find_cmd+=(\) -print0)

# Run find and resize each matching file
local img tmp
while IFS= read -r -d '' img; do
echo "Resizing: $img"
tmp=$(mktemp --tmpdir="$(dirname "$img")" --suffix=".${img##*.}" .resize50.XXXXXX) || continue
if convert "$img" -resize 50% "$tmp"; then
  chmod --reference="$img" "$tmp" 2>/dev/null || true
  mv -- "$tmp" "$img"
else
  echo "Resize failed: $img" >&2
  rm -f -- "$tmp"
fi
done < <("${find_cmd[@]}")
}


function jpg2txt_allincwd() {
# Extracts data into text files from image files or pdf files, inside the current folder.
# Example: jpg2txt_allincwd *.pdf
# Example: jpg2txt_allincwd *.jpg
local -a files
local f nullglob_was_set=0
if (( $# > 0 )); then
  files=("$@")
else
  shopt -q nullglob && nullglob_was_set=1
  shopt -s nullglob
  files=(*.jpg *.jpeg *.png *.pdf)
  (( nullglob_was_set )) || shopt -u nullglob
fi
(( ${#files[@]} > 0 )) || { echo "No matching image or PDF files found."; return 1; }
for f in "${files[@]}"; do pdf2txt_OCR "$f"; done
}


function toclipboard() {
# Copies variable content, text, image or file contents to the clipboard, ready to be pasted (with Ctrl+V).
# Example for text: echo "Hello, World!" | toclipboard
# Example for image: ls zoom.png | toclipboard

local input temp ext
temp=$(mktemp) || return 1
cat > "$temp"
input=$(<"$temp") # Command substitution is intentional for detecting a single file path.
if [[ -f "$input" ]]; then # Check if the input is a file and exists
ext="${input##*.}"; ext="${ext,,}"
case "$ext" in
    png)
        xclip -selection clipboard -t image/png -i "$input"
        ;;
    jpg|jpeg)
        convert "$input" png:- | xclip -selection clipboard -t image/png
        ;;
    *)
        printf '%s' "$input" | xclip -selection clipboard  # Copy the file path for other file types
        ;;
esac
else
xclip -selection clipboard < "$temp"   # Preserve the original text, including trailing newlines.
fi
local rc=$?
rm -f -- "$temp"
return "$rc"
}


# ------------ DOCUMENTS PROCESSING ------------

function xlsx2pdf() {
# Converts an excel file to PDF format using LibreOffice engine.
# Example: xlsx2pdf "file.xlsx"
local file="${1:-}"
[[ -f "$file" ]] || { echo "Usage: xlsx2pdf <file.xlsx>" >&2; return 2; }
if command -v libreoffice >/dev/null 2>&1; then
libreoffice --headless --convert-to pdf -- "$file"
else
echo "Please make sure to have LibreOffice installed for this function to work."
return 1
fi
}


function ods2xlsx() {
# Converts an ODS file to XLSX format using LibreOffice engine.
# Example: ods2xlsx "file.ods"
local file="${1:-}"
[[ -f "$file" ]] || { echo "Usage: ods2xlsx <file.ods>" >&2; return 2; }
if command -v libreoffice >/dev/null 2>&1; then
libreoffice --headless --convert-to xlsx -- "$file"
else
echo "Please make sure to have LibreOffice installed for this function to work."
return 1
fi
}


function pdf2docx() {
# Converts a PDF file to DOCX format and saves it to a specified folder by using LibreOffice engine.
# Example: pdf2docx file.pdf ~/Desktop/
local file=${1?No input given for the file name}
local folder=${2:-$(pwd)}  # Default to current directory if no output folder is provided
if command -v libreoffice >/dev/null 2>&1; then
[[ -f "$file" ]] || { echo "File not found: $file" >&2; return 1; }
mkdir -p "$folder" || return 1
libreoffice --headless --convert-to docx --outdir "$folder" "$file"
else
echo "Please make sure to have LibreOffice installed for this function to work."
return 1
fi
}



# ------------ AUDIO PROCESSES ----------------

function is_audio_playing() {
# Function to check if any application is currently producing audio output
# And if so, do something, e.g. close that window/application
echo "Waiting for audio output..."
while true; do
local audioapp playtime
audioapp=$(pactl list sink-inputs | awk -F\" '/application.process.binary/ {print $2; exit}')  # get the name of the process playing audio
if [[ $audioapp != "" ]]; then  # if $audioapp is not empty, but something was found, then ...
playtime=$(date | regex_time)
echo "Audio detected from $audioapp at $playtime"
sleep 2
window close "$audioapp"  # In this case we could just close that process/app window to stop playing
break
fi
sleep 1 && clear
done
}


function muteaudio() {
pactl set-sink-mute @DEFAULT_SINK@ toggle
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
local ytid quality thumbnail
ytid=$(printf '%s\n' "$link" | regex_youtube_id)
[[ "$ytid" =~ ^[A-Za-z0-9_-]{11}$ ]] || { echo "Could not extract a valid YouTube video ID." >&2; return 1; }
for quality in "maxresdefault" "hq720" "sddefault"; do
thumbnail="https://i.ytimg.com/vi/$ytid/${quality}.jpg"
if wget -q --spider "$thumbnail"; then
  if wget -q "$thumbnail" -O "$ytid.jpg"; then
    echo "Saved: $ytid.jpg"
    return 0
  fi
fi
done
echo "No thumbnail was found for video ID $ytid." >&2
return 1
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
        if [[ -z "$filename" || "$filename" == /* || "$filename" == ../* || "$filename" == */../* || "$filename" == */.. ]]; then
            echo "✘ Unsafe filename skipped: $filename" >&2
            continue
        fi
        local url="${baseurl%/}/$filename"
        mkdir -p -- "$(dirname "$filename")" || continue
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
  mic=$(pactl list short sources | awk 'BEGIN{IGNORECASE=1} /blue|yeti/ && /input/ {print $2; exit}')
  [[ -z "$mic" ]] && mic=$(pactl get-default-source)
  echo "$mic"
}

# Detect default desktop audio output monitor
function get_default_audio_output_monitor() {
  local monitor
  local default_sink
  default_sink=$(pactl get-default-sink 2>/dev/null)
  monitor=$(pactl list short sources | awk -v sink="$default_sink" '$2 == sink ".monitor" {print $2; exit}')
  [[ -z "$monitor" ]] && monitor=$(pactl list short sources | awk '$2 ~ /\.monitor$/ {print $2; exit}')
  echo "$monitor"
}


function record_screen() {
# Function to record screen + mic + default audio output into mkv file
  local reso mic monitor state_dir pid_file
  reso=$(get_default_resolution)
  mic=$(get_default_mic)
  monitor=$(get_default_audio_output_monitor)
  local outfile="$HOME/Videos/record_$(date +%F_%H-%M-%S).mkv"

  [[ -n "$reso" && -n "$mic" && -n "$monitor" ]] || { echo "Could not detect screen or audio sources." >&2; return 1; }
  mkdir -p "$HOME/Videos" || return 1
  state_dir="${XDG_RUNTIME_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/bash-addins}"
  mkdir -p "$state_dir" || return 1
  pid_file="$state_dir/record_screen.pid"

  echo "Recording screen ($reso)"
  echo "Mic: $mic"
  echo "Audio: $monitor"

  nohup ffmpeg -nostdin -f pulse -i "$monitor" -f pulse -i "$mic" -filter_complex amix=inputs=2:duration=first:dropout_transition=2 -f x11grab -framerate 30 -video_size "$reso" -i "${DISPLAY:-:0.0}" -c:a aac -c:v libx264 -pix_fmt yuv420p -preset ultrafast -crf 25 "$outfile" >/dev/null 2>&1 &
  printf '%s\n' "$!" > "$pid_file"
  echo "Recording started: $outfile"
}


function record_audio_output() {
# Function to record Desktop Audio only (output) into flac (or wav) file
  local monitor state_dir pid_file
  monitor=$(get_default_audio_output_monitor)
  local outfile="$HOME/Videos/audio_output_$(date +%F_%H-%M-%S).wav"

  [[ -n "$monitor" ]] || { echo "Could not detect desktop audio monitor." >&2; return 1; }
  mkdir -p "$HOME/Videos" || return 1
  state_dir="${XDG_RUNTIME_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/bash-addins}"
  mkdir -p "$state_dir" || return 1
  pid_file="$state_dir/record_audio.pid"

  echo "🎧 Recording Desktop Audio ($monitor) → $outfile"
  nohup ffmpeg -nostdin -f pulse -i "$monitor" -acodec pcm_s16le "$outfile" >/dev/null 2>&1 &
  printf '%s\n' "$!" > "$pid_file"
  echo "Recording started."
}

function record_audio_input() {
# Function to record only the default microphone (input) into flac (or wav) file
  local mic state_dir pid_file
  mic=$(get_default_mic)
  local outfile="$HOME/Videos/audio_input_$(date +%F_%H-%M-%S).wav"

  [[ -n "$mic" ]] || { echo "Could not detect microphone." >&2; return 1; }
  mkdir -p "$HOME/Videos" || return 1
  state_dir="${XDG_RUNTIME_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/bash-addins}"
  mkdir -p "$state_dir" || return 1
  pid_file="$state_dir/record_audio.pid"

  echo "🎤 Recording Microphone ($mic) → $outfile"
  nohup ffmpeg -nostdin -f pulse -i "$mic" -acodec pcm_s16le "$outfile" >/dev/null 2>&1 &
  printf '%s\n' "$!" > "$pid_file"
  echo "Recording started."
}

function record_stop() {
# Function to stop screen recording and/or audio recording
  local state_dir pid_file pid stopped=0
  state_dir="${XDG_RUNTIME_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/bash-addins}"
  for pid_file in "$state_dir/record_screen.pid" "$state_dir/record_audio.pid"; do
    [[ -f "$pid_file" ]] || continue
    pid=$(<"$pid_file")
    if [[ "$pid" =~ ^[0-9]+$ ]] && ps -p "$pid" -o comm= 2>/dev/null | grep -qx ffmpeg && kill -INT "$pid" 2>/dev/null; then
      stopped=1
      rm -f -- "$pid_file"
      if [[ "$pid_file" == *record_screen.pid ]]; then
      echo "🛑 Screen recording stopped."
      else
        echo "🛑 Audio recording stopped."
      fi
    else
      echo "Stale or invalid recorder PID file removed: $pid_file" >&2
      rm -f -- "$pid_file"
    fi
  done
  (( stopped )) || echo "No active recording found."
}


###########################################
#  END OF FFmpeg section
###########################################


function ding() {
# Function to play "ding" sound
local SOUND="/usr/share/sounds/freedesktop/stereo/complete.oga"
if command -v paplay >/dev/null 2>&1; then
   paplay "$SOUND"
  elif command -v aplay >/dev/null 2>&1; then
   aplay "$SOUND"
  else
   echo "No audio player (paplay/aplay) available" >&2
   return 1
fi
}

function ding_laptop_speakers() {
# Function to play "ding" sound, but only to the laptop speakers output
    local SOUND="/usr/share/sounds/freedesktop/stereo/complete.oga"
    local SINK

    if command -v paplay >/dev/null 2>&1; then
        SINK="$(pactl list short sinks | awk '/analog-stereo/ {print $2; exit}')"

        if [[ -n "$SINK" ]]; then
            paplay --device="$SINK" "$SOUND"
        else
            paplay "$SOUND"
        fi

    elif command -v aplay >/dev/null 2>&1; then
        aplay "$SOUND"
    else
        echo "No audio player (paplay/aplay) available" >&2
        return 1
    fi
}
