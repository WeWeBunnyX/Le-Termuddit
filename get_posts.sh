#!/bin/bash

subreddit=$1
limit=$2

if [[ -z "$subreddit" ]]; then
    echo "No subreddit provided."
    exit 1
fi

if [[ -z "$limit" ]]; then
    limit=10  
fi

access_token=$(cat access_token.txt)

# Color VARs
TITLE_COLOR='\e[96m'
AUTHOR_COLOR='\e[93m'
BODY_COLOR='\e[92m'
RESET='\e[0m'

curl -s -H "Authorization: Bearer $access_token" \
     -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
     "https://oauth.reddit.com/r/$subreddit/hot?limit=$limit" | jq -r --arg TITLE_COLOR "$TITLE_COLOR" --arg AUTHOR_COLOR "$AUTHOR_COLOR" --arg BODY_COLOR "$BODY_COLOR" --arg RESET "$RESET" '
.data.children[] |
  "\($TITLE_COLOR)🔸 \(.data.title)\($RESET)\n\($AUTHOR_COLOR)👤 Author: \(.data.author)\($RESET)\n\($BODY_COLOR)📝 \(.data.selftext)\($RESET)\n─────────────────────────────"
'
