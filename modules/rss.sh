#!/bin/bash

# RSS module
MODULE_NAME="rss"
MODULE_VERSION="1.00"
MODULE_DESCRIPTION="RSS feeds related"


function rss_youtube_lastvideo() {
# Outputs a YouTube channel last published video date and title.
# Example: rss_youtube_lastvideo UCDr1XkQaCr4IgrMVN0_28yg
channel_id="$1"
if [[ -z "$channel_id" ]]; then
   echo "Usage: rss_youtube_lastvideo channel_id"
   return 1
fi
xml=$(curl -s "https://www.youtube.com/feeds/videos.xml?channel_id=${channel_id}" | grep -E "<title>|<published>")
local title=$(echo "$xml" | sed_keep_between_xml "title" | tail -n 1)
local pubdate=$(echo "$xml" | sed_keep_between_xml "published" | tail -n 1 | regex_date)
gradient_text "$pubdate: $title"
}


function rss_github_latestcommits() {
local user_repo=$1
local branch=${2:-main}
curl -s "https://github.com/$user_repo/commits/$branch.atom" | grep -E "<title>|<updated>" | sed -E 's:.*<(title|updated)>(.*)</\1>.*:\2:'
}

