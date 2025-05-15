#!/bin/bash

subreddit=$1
limit=$2

if [[ -z "$subreddit" ]]; then
    echo "No subreddit provided."
    exit 1
fi

if [[ -z "$limit" ]]; then
    limit=100
fi

access_token=$(cat access_token.txt)

curl -s -H "Authorization: Bearer $access_token" \
     -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
     "https://oauth.reddit.com/r/$subreddit/hot?limit=$limit" | jq -r '
.data.children[] |
  "🔸 \(.data.title)\n🌐 \(.data.url)\n👤 Author: \(.data.author)\n📝 \(.data.selftext)\n─────────────────────────────"
'
