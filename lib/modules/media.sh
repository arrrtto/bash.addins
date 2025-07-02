#!/bin/bash

# Media module configuration
MODULE_NAME="media"
MODULE_VERSION="1.0"
MODULE_DESCRIPTION="Audio/video/image processing functions"

# Media conversion functions
function to_mp4() {
    ffmpeg -i "$1" -c:v libx264 -crf 23 -c:a aac -b:a 128k "${1%.*}.mp4"
}

function to_gif() {
    ffmpeg -i "$1" -vf "fps=10,scale=320:-1:flags=lanczos" -c:v gif "${1%.*}.gif"
}

function to_png() {
    convert "$1" "${1%.*}.png"
}

function to_jpg() {
    convert "$1" "${1%.*}.jpg"
}

function to_jpg_from_HEIC() {
    heif-convert "$1" "${1%.*}.jpg"
}

function cutvideo() {
    local input="$1"
    local start="$2"
    local duration="$3"
    ffmpeg -i "$input" -ss "$start" -t "$duration" -c copy "${input%.*}_cut.mp4"
}

function cutaudio() {
    local input="$1"
    local start="$2"
    local duration="$3"
    ffmpeg -i "$input" -ss "$start" -t "$duration" -c copy "${input%.*}_cut.mp3"
}

function toclipboard() {
    local file="$1"
    if [ -f "$file" ]; then
        xclip -selection clipboard -t image/png -i "$file"
        echo "Image copied to clipboard"
    else
        echo "File not found: $file"
    fi
}

# Image processing functions
function generateQR() {
    local text="$1"
    local output="${text// /_}_qr.png"
    qrencode -o "$output" "$text"
    echo "QR code generated: $output"
}

function scan_jpg() {
    local file="$1"
    tesseract "$file" "${file%.*}_text" -l eng
}

function scan_pdf() {
    local file="$1"
    pdftotext "$file" "${file%.*}.txt"
}

function pdf_rotate_clockwise() {
    local file="$1"
    pdftk "$file" rotate 1-endE output "${file%.*}_rotated.pdf"
}

function pdf_rotate_allinfolder_clockwise() {
    for file in *.pdf; do
        pdftk "$file" rotate 1-endE output "${file%.*}_rotated.pdf"
    done
}

function pdf_compress_allinfolder() {
    for file in *.pdf; do
        gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen \
           -dNOPAUSE -dQUIET -dBATCH -sOutputFile="${file%.*}_compressed.pdf" "$file"
    done
}

function pdf2txt_OCR() {
    local file="$1"
    pdftotext "$file" - | tesseract - -l eng
}

function pdf2txt_OCR_allin() {
    for file in *.pdf; do
        pdf2txt_OCR "$file" > "${file%.*}.txt"
    done
}

function jpg2txt_allincwd() {
    # Extracts data into text files from image files or pdf files, inside the current folder.
    # Example: jpg2txt_allincwd *.pdf
    # Example: jpg2txt_allincwd *.jpg
    local pattern="${1:-*.jpg}"                               # Check if an argument is passed, otherwise default to *.jpg
    for f in $pattern; do pdf2txt_OCR "$f" "$f"; done   # Loop through the files based on the provided pattern
}

function OCR_recursively_alljpg2txt() {
    find . -type f -name "*.jpg" -exec tesseract {} "{}.txt" \;
}

function resize50() {
    local file="$1"
    convert "$file" -resize 50% "${file%.*}_resized.${file##*.}"
}

# Document conversion functions
function xlsx2pdf() {
    libreoffice --headless --convert-to pdf "$1"
}

function ods2xlsx() {
    libreoffice --headless --convert-to xlsx "$1"
}

function pdf2docx() {
    libreoffice --headless --convert-to docx "$1"
}

function jpg2txt_allincwd() {
    for file in *.jpg; do
        tesseract "$file" "${file%.*}_text"
    done
}

# Module initialization
function init_${MODULE_NAME}_module() {
    # Check if required commands are available
    local required=("ffmpeg" "convert" "heif-convert" "qrencode" "tesseract" "pdftk" "gs" "libreoffice")
    for cmd in "${required[@]}"; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            echo "Warning: $cmd is required for media functions"
        fi
    done
}

# Module help
function ${MODULE_NAME}_help() {
    cat << EOF
${MODULE_NAME} module v${MODULE_VERSION}
${MODULE_DESCRIPTION}

Available functions:
  Video/Audio:
    to_mp4          Convert to MP4 format
    to_gif          Convert to GIF format
    cutvideo        Cut video segment
    cutaudio        Cut audio segment

  Image:
    to_png          Convert to PNG
    to_jpg          Convert to JPG
    to_jpg_from_HEIC Convert HEIC to JPG
    generateQR      Generate QR code
    resize50        Resize image to 50%

  Document:
    xlsx2pdf        Convert XLSX to PDF
    ods2xlsx        Convert ODS to XLSX
    pdf2docx        Convert PDF to DOCX

  OCR:
    scan_jpg        Scan JPG to text
    scan_pdf        Scan PDF to text
    pdf2txt_OCR     Convert PDF to text with OCR
EOF
}

# Initialize module
init_${MODULE_NAME}_module
