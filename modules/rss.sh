#!/bin/bash

# RSS module
MODULE_NAME="rss"
MODULE_VERSION="1.2"
MODULE_DESCRIPTION="RSS feeds related"


function rss_youtube_lastvideo() {
# Outputs a YouTube channel last published video date and title.
# Example: rss_youtube_lastvideo UCDr1XkQaCr4IgrMVN0_28yg
local channel_id="${1:-}" xml result pubdate title
if [[ ! "$channel_id" =~ ^UC[A-Za-z0-9_-]{22}$ ]]; then
   echo "Usage: rss_youtube_lastvideo channel_id"
   echo "Expected a 24-character YouTube channel ID beginning with UC." >&2
   return 2
fi
xml=$(curl -fLsS --retry 2 --connect-timeout 10 --max-time 30 \
  "https://www.youtube.com/feeds/videos.xml?channel_id=${channel_id}") || {
  echo "Could not download the YouTube RSS feed." >&2
  return 1
}

result=$(python3 -c '
import sys
import xml.etree.ElementTree as ET

try:
    root = ET.fromstring(sys.stdin.read())
    entry = next((e for e in root.iter() if e.tag.rsplit("}", 1)[-1] == "entry"), None)
    if entry is None:
        raise ValueError("feed contains no video entries")
    values = {}
    for element in entry:
        name = element.tag.rsplit("}", 1)[-1]
        if name in {"title", "published"} and name not in values:
            values[name] = " ".join("".join(element.itertext()).split())
    if not values.get("title") or not values.get("published"):
        raise ValueError("latest entry has no title or publication date")
    print(values["published"] + "\t" + values["title"])
except (ET.ParseError, ValueError) as error:
    print(f"Invalid YouTube feed: {error}", file=sys.stderr)
    sys.exit(1)
' <<< "$xml") || return 1

IFS=$'\t' read -r pubdate title <<< "$result"
pubdate="${pubdate%%T*}"
if declare -F gradient_text >/dev/null 2>&1; then
  gradient_text "$pubdate: $title"
else
  printf '%s: %s\n' "$pubdate" "$title"
fi
}


function rss_github_latestcommits() {
local user_repo="${1:-}"
local branch="${2:-main}"
if [[ ! "$user_repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ||
      ! "$branch" =~ ^[A-Za-z0-9._/-]+$ || "$branch" == *..* ]]; then
  echo "Usage: rss_github_latestcommits owner/repository [branch]" >&2
  return 2
fi
curl -fLsS --retry 2 --connect-timeout 10 --max-time 30 \
  "https://github.com/$user_repo/commits/$branch.atom" |
  python3 -c '
import sys
import xml.etree.ElementTree as ET
try:
    root = ET.parse(sys.stdin).getroot()
    for element in root.iter():
        if element.tag.rsplit("}", 1)[-1] in {"title", "updated"}:
            print(" ".join("".join(element.itertext()).split()))
except ET.ParseError as error:
    print(f"Invalid Atom feed: {error}", file=sys.stderr)
    sys.exit(1)
'
}


function rss_titles() {
# Example: rss_titles https://trends.google.com/trending/rss
local url="${1:-}"
[[ "$url" =~ ^https?://[^[:space:]]+$ ]] || {
  echo "Usage: rss_titles <http-or-https-feed-URL>" >&2
  return 2
}
curl -fLsS --retry 2 --connect-timeout 10 --max-time 30 "$url" |
  python3 -c '
import sys
import xml.etree.ElementTree as ET
try:
    root = ET.parse(sys.stdin).getroot()
    for element in root.iter():
        if element.tag.rsplit("}", 1)[-1] in {"title", "updated"}:
            print(" ".join("".join(element.itertext()).split()))
except ET.ParseError as error:
    print(f"Invalid RSS/Atom feed: {error}", file=sys.stderr)
    sys.exit(1)
'
}

