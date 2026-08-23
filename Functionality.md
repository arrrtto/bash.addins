# BASH Addins Functionality Guide

This guide explains every user-facing alias and function included in BASH Addins. It is written for ordinary GNU/Linux home users: you can copy the examples, replace the sample names with your own, and run them in Terminal.

> [!IMPORTANT]
> BASH Addins is currently designed mainly for Debian, Ubuntu, Linux Mint and LMDE. Graphical window commands generally require an X11/Xorg session; some do not work under Wayland.

## Contents

- [How to use BASH Addins](#how-to-use-bash-addins)
- [Main commands](#main-commands)
- [Aliases and everyday shortcuts](#aliases-and-everyday-shortcuts)
- [System, files and processes](#system-files-and-processes)
- [Text and number processing](#text-and-number-processing)
- [Media and documents](#media-and-documents)
- [GUI and window management](#gui-and-window-management)
- [Fancy Terminal output](#fancy-terminal-output)
- [RSS feeds](#rss-feeds)
- [Cryptocurrency](#cryptocurrency)
- [Dependencies](#dependencies)

## How to use BASH Addins

After installation, open a new Terminal. Functions behave like ordinary commands:

```bash
systeminfo
battery_left
foldersize ~/Downloads
```

### Piping text into another command

Many text functions read from standard input. The pipe character `|` sends the output of the command on its left into the command on its right:

```bash
echo "Contact me at hello@example.com" | regex_email
cat shopping-list.txt | sed_removeemptylines
curl -s https://example.com | regex_links_https
```

Functions can be chained:

```bash
cat prices.txt | sed_comma2dot | regex_awk_sum
```

### Filenames containing spaces

Put filenames and paths inside quotation marks:

```bash
to_mp3 "My recording.wav"
foldersize "My Videos"
pdf_rotate_clockwise "Important document.pdf"
```

### Safety labels used below

- **Changes files** means the command creates, moves, renames or replaces files.
- **Destructive** means data may be deleted or permanently lost.
- **Runs continuously** means press `Ctrl+C` to stop it.
- **Needs sudo** means it may ask for your administrator password.

## Main commands

| Command | What it does | Example |
|---|---|---|
| `showallfunctions` | Lists installed BASH Addins functions and their short descriptions. | `showallfunctions` |
| `showaliases` | Lists the aliases built into the compiled library. | `showaliases` |
| `functions_amount` | Counts the available functions. | `functions_amount` |

## Aliases and everyday shortcuts

Aliases are short alternative command names. Some deliberately use general names such as `update`, `setup` and `mkdir`; remember that these names behave differently after BASH Addins is loaded.

| Alias | Meaning | Example |
|---|---|---|
| `cls` | Clears the Terminal screen. | `cls` |
| `cleanup` | Rotates old system logs, retains seven days, cleans APT packages and offers to remove unused packages. **Needs sudo.** | `cleanup` |
| `distro` | Shows information about the installed Linux distribution. | `distro` |
| `grep` | Runs `grep` with automatic colored matches. | `grep error logfile.txt` |
| `installdeb` | Installs a local Debian package with `dpkg`. **Needs sudo.** | `installdeb program.deb` |
| `ipaddress_public` | Asks ipinfo.io for your internet-facing public IP address. | `ipaddress_public` |
| `fixupdate` | Asks APT to repair missing or broken dependencies. **Needs sudo.** | `fixupdate` |
| `l` | Compact directory listing with file-type indicators. | `l` |
| `la` | Lists entries including hidden ones, except `.` and `..`. | `la` |
| `ll` | Detailed listing including hidden entries. | `ll` |
| `lsdir` / `lsfolders` | Lists only immediate folders, alphabetically. | `lsfolders` |
| `lsfiles` | Lists only immediate files, alphabetically. | `lsfiles` |
| `mkdir` | Always runs `mkdir -p`, creating parent folders and not complaining if the folder exists. | `mkdir Projects/Photos` |
| `setup` | Another name for `sudo dpkg -i`. | `setup program.deb` |
| `uninstall` | Removes an installed Debian package while generally retaining configuration. | `uninstall package-name` |
| `uninstall_totally` | Purges a Debian package and its system configuration. | `uninstall_totally package-name` |
| `update` | Updates APT indexes and installs available upgrades automatically. **Needs sudo.** | `update` |
| `week` | Shows the current ISO week number. | `week` |
| `datetime` | Prints a filename-friendly date and time. | `datetime` |

These argument-aware helpers live in the aliases module but are functions:

| Function | What it does | Example |
|---|---|---|
| `ipaddress_local` | Shows the computer's currently detected local-network IP addresses. | `ipaddress_local` |
| `findfile` | Recursively finds file or folder names containing literal text, case-insensitively. | `findfile invoice` |
| `findtext_insidefiles` | Recursively searches file contents for literal text and skips `.git`. | `findtext_insidefiles "customer number"` |

## System, files and processes

### General helpers and numbers

| Function | What it does | Example or use case |
|---|---|---|
| `reload` | Reloads `~/bin/bash.addins` in the current shell after an update. | `reload` |
| `all` | Filters piped names so only regular files in the current directory remain. | `printf '%s\n' * | all` |
| `countdown_minutes` | Displays a minute-by-minute countdown. | `countdown_minutes 5` |
| `randomnumber` | Prints an integer between the inclusive minimum and maximum. | `randomnumber 5 250` |
| `sleeprandom` | Waits a random zero to nine seconds; useful between automation actions. | `sleeprandom` |
| `is_number` | Returns success when its argument is a supported non-negative decimal number. Mainly used by other functions. | `if is_number 12.5; then echo valid; fi` |
| `diffnum` | Subtracts the second decimal number from the first, with eight decimal places. | `diffnum 5 3.24` → `1.76000000` |
| `numgt` | Tests whether number 1 is greater than number 2. | `if numgt 2.2 0.1; then echo greater; fi` |
| `numge` | Tests greater-than-or-equal. | `if numge 5 5; then echo yes; fi` |
| `numlt` | Tests less-than. | `if numlt 0.01 1; then echo yes; fi` |
| `numle` | Tests less-than-or-equal. | `if numle 1 1; then echo yes; fi` |
| `whatnext` | Asks whether to continue. Choosing No exits the current script or shell. | `whatnext` |
| `whatdate` | Calculates a date in the past or future using GNU `date`. | `whatdate 2 months 3 days ago` |
| `datetimenow` | Prints `DD.MM.YYYY_HH.MM`. | `datetimenow` |
| `timer` | Waits until a date/time and then prints `Timer finished`. | `timer tomorrow 20:00` |

### Reminders

`reminderd` watches a text file and sends matching reminders through an ntfy topic. It **runs continuously**.

```bash
reminderd "$HOME/reminders.txt" my-private-topic
```

Example `reminders.txt`:

```text
# One specific date
ONCE 23.06.2027 08:00|Car repair

# Every day
DAILY 08:00|Take vitamins

# Every Monday
WEEKLY Mon 09:00|Weekly planning

# First day of every month
MONTHLY 1 10:00|Pay bills
```

Run it in the background:

```bash
nohup bash -c 'source ~/.bashrc; reminderd "$HOME/reminders.txt" my-private-topic' \
  >"$HOME/reminderd.log" 2>&1 &
```

| Function | Notes |
|---|---|
| `reminderd` | Stores sent-reminder keys in `~/reminderd.sent`, avoiding repeated delivery during the matching minute. Requires `curl`, internet access and an ntfy topic. |

### System information, power and disks

| Function | What it does | Example or warning |
|---|---|---|
| `systeminfo` | Shows OS, kernel, uptime, hostname, CPU, memory and disk information; Linux Mint support dates are retrieved online when available. | `systeminfo` |
| `freememory` | Shows available and total RAM and swap. | `freememory` |
| `freespace` | Shows free space on mounted local filesystems. | `freespace` |
| `battery_left` | Shows the first detected laptop battery percentage. | `battery_left` |
| `battery_ntfy_watch` | Watches battery charge and sends cooldown-controlled ntfy warnings while discharging. **Runs continuously.** | `battery_ntfy_watch mytopic 15 30` |
| `nvmehealth` | Reads NVMe SMART data and warns about heat, wear and errors. Requires `nvme-cli` and sudo. | `nvmehealth /dev/nvme0n1` |
| `diskhealth` | Uses `nvmehealth` for NVMe or `smartctl` for SATA/SAS disks. Requires sudo. | `diskhealth /dev/sda` |

SMART warnings should be investigated; they do not automatically prove that a drive will fail immediately. Keep backups of important files regardless of SMART status.

### RAM drive

`ramdrive` creates a very fast temporary filesystem in RAM at `/mnt/ramdrive`. Its contents disappear after unmounting, power loss or reboot.

```bash
# Create and mount a temporary 4 GB RAM drive
ramdrive create 4GB

# Create one that is automatically mounted after boot
ramdrive create 4.5GB permanent

ramdrive mount
ramdrive unmount
```

The function validates the size, checks currently available memory, reserves at least 1 GiB or 10% of RAM for the system, uses restrictive mount options, backs up `/etc/fstab` before a permanent change, and asks before discarding mounted contents.

> [!WARNING]
> Unmounting a RAM drive permanently destroys everything stored in it. Copy wanted files elsewhere first.

### Processes and file management

| Function | What it does | Example or warning |
|---|---|---|
| `process_check` | Reports whether an exact process name is running. | `process_check firefox` |
| `process_kill` | Sends a graceful `SIGTERM` to processes with an exact executable name. | `process_kill chromium` |
| `kill_zombieprocesses_chromium` | Force-kills parents of Chromium zombie processes. Use only when Chromium is stuck. | `kill_zombieprocesses_chromium` |
| `bigfiles` | Recursively lists files larger than a chosen size, largest first. | `bigfiles +500M` |
| `list` | Performs one action for every path written in a text file. | `list files.txt size` |
| `findfiles` | Finds files matching a case-insensitive glob below the current directory. | `findfiles "*.lock"` |
| `replace_extension` | Renames matching files in the current folder from one extension to another. **Changes files.** | `replace_extension jpg.txt txt` |
| `replace_spaces` | Replaces spaces with underscores in filenames in one folder. Refuses to overwrite a collision. | `replace_spaces ~/Downloads` |
| `replace_nordic_chars` | Replaces `äüõö`/uppercase equivalents in filenames with ASCII letters. | `replace_nordic_chars ~/Downloads` |
| `choicelist` | Turns piped lines into an interactive numbered choice menu. | `selected=$(printf '%s\n' *.mp3 | choicelist)` |
| `syncit` | Copies newer files with `rsync`, retains destination extras, and writes a log in the source folder. | `syncit ~/Pictures /media/backup/Pictures` |
| `foldersize` | Shows the total size of one folder. | `foldersize ~/Downloads` |
| `foldersizes` | Shows sizes of immediate subfolders, largest first. | `foldersizes ~/Downloads` |

`list` supports these actions:

```bash
list files.txt echo
list files.txt size
list files.txt basename
list files.txt dirname
list files.txt exists
list files.txt copy /tmp/backup
list files.txt move ~/Archive
list files.txt chmod 644
list files.txt exec sha256sum
```

> [!CAUTION]
> `list files.txt delete` deletes every listed path. Review the list first with `list files.txt echo`.

### Wait-until helpers

These are useful in automation scripts. Unless noted otherwise, they keep waiting until the condition becomes true; press `Ctrl+C` to cancel.

| Function | Waits for… | Example |
|---|---|---|
| `wait4download` | A Chromium `.crdownload` file to disappear and its final file to exist. | `wait4download ~/Downloads` |
| `wait4process_start` | An exact process name to start. | `wait4process_start firefox` |
| `wait4process_stop` | An exact process name to stop. | `wait4process_stop firefox` |
| `wait4window` | A window title to appear under X11. | `wait4window "Telegram"` |
| `wait4window_close` | A matching X11 window to close. | `wait4window_close "Telegram"` |
| `wait4file` | A path or glob to appear. Quote a glob if the shell must not expand it yet. | `wait4file "$HOME/Downloads/*.mp4"` |
| `wait4file_gone` | All matching files to disappear. | `wait4file_gone "$HOME/Downloads/*.tmp"` |
| `wait4file_ready` | A file's size to stabilize and for no process to hold it open. | `wait4file_ready render.mp4` |
| `wait4file_gone_ext` | A named file pattern to disappear below a directory. | `wait4file_gone_ext ~/Downloads '*.crdownload'` |
| `wait4network` | Ping to `8.8.8.8` to succeed. | `wait4network` |
| `wait4updates_apt` | Common APT/dpkg locks to be released. | `wait4updates_apt` |
| `wait4mount` | A path to become a mount point. | `wait4mount /media/usb` |
| `wait4unmount` | A path to stop being a mount point. | `wait4unmount /media/usb` |
| `wait4cpu_idle` | Overall CPU use to fall below a percentage. | `wait4cpu_idle 15` |
| `wait4app_idle` | One exact process's CPU use to fall below a percentage. | `wait4app_idle kdenlive 5` |
| `wait4time` | The clock to reach `HH:MM`; if already past, it waits until that time the next day. | `wait4time 16:00` |

### Desktop and login helpers

| Function | What it does | Example or warning |
|---|---|---|
| `press` | Sends one or more key combinations to the focused X11 window. | `press ctrl+l BackSpace` |
| `type_into` | Types supplied text into the focused X11 window. | `type_into "Hello world"` |
| `enter_text` | Same behavior as `type_into`. | `enter_text "Hello world"` |
| `screenoff` | Asks X11 DPMS to switch the display off. | `screenoff` |
| `lockscreen` | Locks a Cinnamon desktop session. | `lockscreen` |
| `autologin` | Enables or disables automatic login for LightDM, GDM or SDDM. Backs up changed configuration. **Needs sudo; reduces login security.** | `autologin "$USER" on` |

For SDDM, a session can be supplied explicitly:

```bash
autologin "$USER" on plasma
autologin "$USER" off
```

## Text and number processing

### Extracting recognizable data

| Function | Extracts | Example |
|---|---|---|
| `regex_email` | Email-like addresses. | `echo "Mail a@b.ee" | regex_email` |
| `regex_links_https` | HTTP and HTTPS links. | `cat page.html | regex_links_https` |
| `regex_htmltag` | HTML opening/standalone tags. | `cat page.html | regex_htmltag` |
| `regex_ipaddress` | Valid IPv4 addresses with octets `0–255`. | `echo "Router: 192.168.1.1" | regex_ipaddress` |
| `regex_price` | Digits and dots from each input line. | `echo 'Cost: $456.68' | regex_price` |
| `regex_number` | Runs of digits. | `echo "Room 12, floor 3" | regex_number` |
| `regex_phonenumber` | Common international/local phone-number shapes. | `cat contacts.txt | regex_phonenumber` |
| `regex_date` | `YYYY-MM-DD`, `DD.MM.YYYY` and similar formats. | `echo "14.05.2026" | regex_date` |
| `regex_time` | Valid `HH:MM` or `HH:MM:SS` times. | `echo "At 18:04:59" | regex_time` |
| `regex_usernamehandle` | ASCII handles beginning with `@`. | `echo "Ask @artto" | regex_usernamehandle` |
| `regex_hashtag` | ASCII hashtags beginning with `#`. | `echo "#Linux is nice" | regex_hashtag` |
| `regex_youtube_id` | An 11-character video ID from common YouTube URLs. | `echo 'https://youtu.be/dQw4w9WgXcQ' | regex_youtube_id` |
| `regex_sha256` | 64-character hexadecimal SHA-256 values. | `sha256sum file.iso | regex_sha256` |
| `regex_bitcoin` | Legacy Bitcoin addresses beginning with `1` or `3`; it does not validate checksums or extract Bech32 `bc1…` addresses. | `cat payment.txt | regex_bitcoin` |
| `regex_uuid` | UUID-shaped identifiers. | `cat log.txt | regex_uuid` |
| `regex_sql` | Simple semicolon-terminated SELECT/INSERT/UPDATE/DELETE snippets. | `cat dump.txt | regex_sql` |

These extractors recognize useful text patterns; they are not full validators for email ownership, phone reachability, cryptocurrency checksums, SQL grammar or calendar-valid dates.

### Cleaning and reshaping text

| Function | What it does | Example |
|---|---|---|
| `sed_comma2dot` | Replaces every comma with a dot. | `echo 1,23 | sed_comma2dot` |
| `sed_dot2comma` | Replaces every dot with a comma. | `echo 1.23 | sed_dot2comma` |
| `sed_space_removeextra` | Collapses repeated horizontal whitespace on each line. | `echo 'Too    many spaces' | sed_space_removeextra` |
| `sed_space_trim` | Removes whitespace at each line's beginning and end. | `cat list.txt | sed_space_trim` |
| `sed_space_removeall` | Removes all whitespace, including line breaks. | `cat code.txt | sed_space_removeall` |
| `sed_keep_textandnumbers` | Retains locale-recognized letters and digits. | `echo 'Õun #12!' | sed_keep_textandnumbers` |
| `sed_keep_numbers` | Retains digits only. | `echo 'Order A-123' | sed_keep_numbers` |
| `sed_keep_price` | Retains digits and dots; alias-like equivalent of `regex_price`. | `echo '$12.50' | sed_keep_price` |
| `sed_upper2lowercase` | Converts uppercase letters to lowercase using GNU sed. | `echo 'HELLO' | sed_upper2lowercase` |
| `sed_add2end` | Adds a literal suffix to every line. | `printf 'a\nb\n' | sed_add2end '.txt'` |
| `sed_cleantext` | Removes common ANSI SGR color sequences. | `some_colored_command | sed_cleantext` |
| `regex_until` | Keeps the part before the first occurrence of literal text. | `echo 'name:details' | regex_until ':'` |
| `regex_until_specialchar` | Same literal behavior as `regex_until`; retained for compatibility. | `echo 'one & two' | regex_until_specialchar '&'` |
| `regex_awk_seen` | Removes duplicate lines while preserving first-seen order. | `cat names.txt | regex_awk_seen` |
| `regex_awk_sum` | Adds the first numeric field from every line. | `printf '4.52\n2\n' | regex_awk_sum` |
| `regex_awk_remove_betweenwords` | Removes text from the first literal start marker through the following end marker. | `echo 'A [hide]secret[/hide] B' | regex_awk_remove_betweenwords '[hide]' '[/hide]'` |
| `regex_awk_keep_betweenwords` | Keeps the first literal start-to-end section, including markers. | `echo 'A [keep]yes[/keep] B' | regex_awk_keep_betweenwords '[keep]' '[/keep]'` |
| `regex_awk_removeprefixes` | Removes a line when it is an exact prefix of another longer input line. | `cat paths.txt | regex_awk_removeprefixes` |
| `sed_keep_between_xml` | Extracts text between a simple matching XML tag on one line. | `echo '<title>News</title>' | sed_keep_between_xml title` |

### Working with lines

| Function | What it does | Example |
|---|---|---|
| `sed_removelastline` | Deletes the final input line. | `cat list.txt | sed_removelastline` |
| `sed_removefirstline` | Deletes the first input line. | `cat list.txt | sed_removefirstline` |
| `sed_keeplastword` | Keeps text following the final whitespace on each line. | `echo 'some final word' | sed_keeplastword` |
| `sed_addemptyline` | Adds a blank line after every input line. | `cat notes.txt | sed_addemptyline` |
| `sed_removeemptylines` | Removes empty and whitespace-only lines. | `cat notes.txt | sed_removeemptylines` |
| `sed_joinlines` | Joins all lines with no separator. | `printf 'a\nb\n' | sed_joinlines` |
| `sed_joinlines_commasep` | Joins lines with comma-space. | `printf 'a\nb\n' | sed_joinlines_commasep` |
| `sed_joinlines_semicolonsep` | Joins lines with semicolon-space. | `printf 'a\nb\n' | sed_joinlines_semicolonsep` |
| `sed_keeplinesbetween` | Prints from the first line containing a literal start marker through a line beginning with the end marker. | `cat log.txt | sed_keeplinesbetween START END` |
| `sed_keeplines_after` | Keeps lines containing a marker with non-whitespace text after it. | `cat chat.txt | sed_keeplines_after '⟩ '` |
| `sed_keepline` | Prints one positive-numbered line. | `cat file.txt | sed_keepline 2` |
| `sed_keeplinesrange` | Prints an inclusive line range. | `cat file.txt | sed_keeplinesrange 10 20` |
| `sed_removeline` | Deletes one positive-numbered line. | `cat file.txt | sed_removeline 3` |
| `sed_removelinesrange` | Deletes an inclusive line range. | `cat file.txt | sed_removelinesrange 3 6` |
| `row` | Keeps or deletes one line, an inclusive range, `first`, or `last`. | `cat file.txt | row keep 2,5` |

### Numbers, JSON and sorting

| Function | What it does | Example |
|---|---|---|
| `regex_keep_number` | Extracts decimals that contain digits on both sides of a dot. | `echo 'Price 0.54' | regex_keep_number` |
| `regex_keep_numberof_decimals` | Extracts decimal numbers, retaining at most the selected decimal count. | `echo 0.24005 | regex_keep_numberof_decimals 2` |
| `regex_jq` | Filters an array or object by exact-string (`=`) or regex (`~`) conditions and prints one field. Requires `jq`. | `cat people.json | regex_jq where status=active get name` |
| `sortdown_colnum` | Sorts comma-separated rows numerically by a column, most negative first. | `cat data.csv | sortdown_colnum 3` |
| `sortup_colnum` | Sorts comma-separated rows numerically by a column, most positive first. | `cat data.csv | sortup_colnum 3` |
| `sortdown_abs_colnum` | Sorts by absolute numeric magnitude, closest to zero first. | `cat data.csv | sortdown_abs_colnum 3` |
| `sortup_abs_colnum` | Sorts by absolute numeric magnitude, furthest from zero first. | `cat data.csv | sortup_abs_colnum 3` |
| `sort_col` | Sorts a comma-separated numeric or text column using `up`, `down`, `upabs` or `downabs`. | `cat data.csv | sort_col 2 up` |
| `prefix_suffix_to_lines` | Reads a file and adds a prefix and optional suffix to each non-empty line. | `prefix_suffix_to_lines names.txt 'https://example.com/' '.html'` |

More `regex_jq` examples:

```bash
cat items.json | regex_jq where id=79997538 get name
cat items.json | regex_jq where 'name~1080p.*HEVC' get info_hash
cat items.json | regex_jq where status=vip and seeders=5 get name
cat items.json | regex_jq where status=vip or status=trial get name
```

## Media and documents

Media conversion functions do not intentionally overwrite an existing output. When the source already has the target extension, names such as `_converted.mp4` are used.

### Audio and video

| Function | What it does | Example |
|---|---|---|
| `exa` | Extracts and re-encodes an audio interval as 192 kbit/s MP3, choosing the next `_clip_N.mp3` name. | `exa interview.mp3 00:14:17 00:19:22` |
| `exc` | Extracts an interval with stream copying, which is fast but may start at a nearby keyframe. | `exc video.mp4 00:01:00 00:02:30` |
| `to_mp3` | Converts one or more audio files to stereo 256 kbit/s MP3. | `to_mp3 *.wav` |
| `to_mp4` | Converts video to H.264/AAC MP4 at a chosen video bitrate in kbit/s. | `to_mp4 3000 video.mov` |
| `audio_removemetadata` | Atomically removes audio metadata, chapters and embedded artwork while retaining encoded audio. **Replaces the original after success.** | `audio_removemetadata *.mp3` |
| `audiosync` | Creates `_synced.mp4` using the module's fixed 0.2666667-second offset. | `audiosync video.mp4` |
| `to_gif` | Converts up to the first ten seconds of video to a 640-pixel-wide, 15 fps GIF. | `to_gif clip.mp4` |
| `is_audio_playing` | Waits for PulseAudio playback, then calls `window close` for the detected application. **This closes an application window.** | `is_audio_playing` |
| `muteaudio` | Toggles mute for the default PulseAudio/PipeWire-Pulse output. | `muteaudio` |
| `ding` | Plays the standard desktop completion sound. | `ding` |
| `ding_laptop_speakers` | Prefers an analog/laptop-speaker sink for the completion sound. | `ding_laptop_speakers` |

### Images, scanning and QR codes

| Function | What it does | Example or warning |
|---|---|---|
| `to_png` | Converts images to PNG; same-format input becomes `_converted.png`. | `to_png photo.jpg` |
| `to_jpg` | Converts images to JPEG and replaces transparency with white. | `to_jpg logo.png` |
| `generateQR` | Creates `~/QR.png` from text or a URL. | `generateQR 'https://qortal.dev'` |
| `scan_jpg` | Scans one 300-DPI color page into `~/Scanned` as JPEG. | `scan_jpg` |
| `scan_pdf` | Scans one 300-DPI color page into `~/Scanned` as PDF. | `scan_pdf` |
| `OCR_recursively_alljpg2txt` | Creates Estonian OCR `.txt` files beside JPG/JPEG images recursively, skipping existing text. | `OCR_recursively_alljpg2txt` |
| `resize50` | Recursively replaces matching images with atomically generated half-resolution versions. **Changes originals.** | `resize50 jpg` |
| `jpg2txt_allincwd` | OCRs supplied files, or JPG/JPEG/PNG/PDF files in the current folder when no arguments are supplied. | `jpg2txt_allincwd *.jpg` |
| `toclipboard` | Copies piped text, a PNG image, or a JPEG converted to PNG into the X11 clipboard. | `printf '%s\n' photo.png | toclipboard` |

### PDF and office documents

| Function | What it does | Example or warning |
|---|---|---|
| `pdf_rotate_clockwise` | Creates `rotated_FILENAME.pdf` using Ghostscript. | `pdf_rotate_clockwise document.pdf` |
| `pdf_rotate_allinfolder_clockwise` | Atomically rotates every lowercase `*.pdf` in the current folder. **Replaces originals after success.** | `pdf_rotate_allinfolder_clockwise` |
| `pdf_compress_allinfolder` | Atomically compresses every lowercase `*.pdf` using Ghostscript `/screen` quality. **Replaces originals and may reduce image quality.** | `pdf_compress_allinfolder` |
| `pdf2txt_OCR` | OCRs an image or every rendered page of a PDF into an adjacent `.txt` file using Estonian language data. | `pdf2txt_OCR scanned.pdf` |
| `pdf2txt_OCR_allin` | Runs PDF OCR for every lowercase `*.pdf` in the current folder. | `pdf2txt_OCR_allin` |
| `xlsx2pdf` | Converts an Excel workbook to PDF with headless LibreOffice. | `xlsx2pdf budget.xlsx` |
| `ods2xlsx` | Converts an OpenDocument spreadsheet to XLSX. | `ods2xlsx budget.ods` |
| `pdf2docx` | Asks LibreOffice to convert a PDF to DOCX in a chosen directory; results vary with PDF complexity. | `pdf2docx file.pdf ~/Documents` |

### Downloads

| Function | What it does | Example |
|---|---|---|
| `yt-downloadthumbnail` | Extracts a YouTube video ID and downloads the best available standard thumbnail. | `yt-downloadthumbnail 'https://youtu.be/dQw4w9WgXcQ'` |
| `wget_batch` | Downloads listed filenames below one base URL, from arguments or a text file. Rejects unsafe parent/absolute paths. | `wget_batch https://example.com/files filelist.txt` |

### Screen and audio recording

| Function | What it does | Example |
|---|---|---|
| `get_default_resolution` | Prints the first preferred XRandR resolution. Mainly used internally. | `get_default_resolution` |
| `get_default_mic` | Prefers a Blue/Yeti input, otherwise prints the default PulseAudio source. | `get_default_mic` |
| `get_default_audio_output_monitor` | Prints the default sink's monitor source, with a fallback to the first monitor. | `get_default_audio_output_monitor` |
| `record_screen` | Starts background X11 screen recording with desktop audio and microphone into `~/Videos/*.mkv`. | `record_screen` |
| `record_audio_output` | Records desktop audio into a WAV file in `~/Videos`. | `record_audio_output` |
| `record_audio_input` | Records the default microphone into a WAV file in `~/Videos`. | `record_audio_input` |
| `record_stop` | Verifies stored recorder PIDs and sends FFmpeg `SIGINT` so files are finalized cleanly. | `record_stop` |

Recorder functions require an X11/PulseAudio-compatible environment. PipeWire commonly works when its PulseAudio compatibility service is enabled.

## GUI and window management

These functions control X11 windows. A window name may match the window title or WM class depending on the function.

| Function | What it does | Example |
|---|---|---|
| `focus_window` | Activates the first visible window matching an X11 class. | `focus_window firefox` |
| `minimize_app` | Minimizes the first visible window whose title matches. | `minimize_app Firefox` |
| `maximize_app` | Activates and resizes the first visible matching window to 100% × 100%. | `maximize_app Firefox` |
| `get_window_info` | Focuses a class and prints/stores its active window coordinates and size in `x`, `y`, `width`, `height`. | `get_window_info firefox` |
| `screenshot_window` | Focuses a matching window and saves it under `~/Screen-shots`. | `screenshot_window firefox` |
| `get_window_info_titled` | Lists `wmctrl` windows containing literal title text. | `get_window_info_titled 'LibreOffice'` |
| `screenshot_window_titled` | Captures the first window containing literal title text into `~/Screen-shots`. | `screenshot_window_titled 'Budget.ods'` |
| `window` | Focuses, closes, maximizes or minimizes a window via i3 or `wmctrl`. | `window focus Firefox` |

Examples:

```bash
window maximize Firefox
window minimize Telegram
window close "Untitled document"
```

> [!WARNING]
> `window close …` asks the window manager to close the application. Unsaved work may be lost if the application does not prompt you.

## Fancy Terminal output

| Function | What it does | Example |
|---|---|---|
| `gradient_progress_bar` | Draws a 50-cell true-color bar for a percentage. Mainly an internal helper. | `gradient_progress_bar 75` |
| `gradient_in` | Prints text transitioning between two RGB colors. Mainly an internal helper. | `gradient_in 'Hello' 35 206 255 100 112 240` |
| `gradient_text` | Prints text in the default blue-purple gradient. | `gradient_text 'Setup complete!'` |
| `wget_progressbar` | Downloads an HTTP/HTTPS URL while displaying a gradient percentage bar; returns failure when `wget` fails. | `wget_progressbar 'https://example.com/archive.zip'` |

True-color output depends on the terminal and font; unsupported glyphs may appear differently.

## RSS feeds

These functions use `curl` and Python's XML parser, so they support namespaced and minified RSS/Atom feeds and decode XML entities.

| Function | What it does | Example |
|---|---|---|
| `rss_youtube_lastvideo` | Shows the date and title of the newest video in a YouTube channel feed. | `rss_youtube_lastvideo UCDr1XkQaCr4IgrMVN0_28yg` |
| `rss_github_latestcommits` | Prints title/update fields from a GitHub branch's Atom commit feed. | `rss_github_latestcommits arrrtto/bash.addins main` |
| `rss_titles` | Prints all title/update fields from an HTTP/HTTPS RSS or Atom feed. | `rss_titles 'https://trends.google.com/trending/rss'` |

## Cryptocurrency

| Function | What it does | Example |
|---|---|---|
| `crypto_fearandgreedindex` | Retrieves the current Alternative.me Crypto Fear & Greed Index and classification. | `crypto_fearandgreedindex` |

This index is general market sentiment information, not financial advice or a trading signal.

## Dependencies

The installer attempts to install the main packages on Debian-family systems and skips packages unavailable from enabled repositories. Many functions use standard GNU/Linux commands already present on most systems.

Common dependency groups:

| Purpose | Commands/packages commonly required |
|---|---|
| Network and structured data | `curl`, `wget`, `jq`, `python3` |
| Audio/video | `ffmpeg`, `sox` |
| Images and scanning | ImageMagick (`convert`), `sane-utils`, `qrencode` |
| OCR and PDFs | `tesseract-ocr`, Estonian Tesseract language data, `ghostscript`, `poppler-utils`, `pdftk`, MuPDF |
| Office documents | LibreOffice, `unoconv`, Python spreadsheet/ODF libraries |
| X11 desktop control | `xdotool`, `wmctrl`, `xclip`, `x11-apps`, `x11-xserver-utils` |
| Audio desktop control | `pactl`/`paplay` from `pulseaudio-utils` or compatible PipeWire services |
| Disk/system tools | `smartmontools`, `nvme-cli`, `rsync`, `lsof`, `psmisc`, `lsb-release` |

If a function reports that a command is missing, install the named Debian package, or rerun the current BASH Addins installer after updating it.

## Getting help

Start with:

```bash
showallfunctions
showaliases
```

For bugs, feature requests or documentation improvements, use the project's GitHub issue/discussion facilities or the contact details in `README.md`.
