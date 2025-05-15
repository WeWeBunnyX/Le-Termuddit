#!/bin/bash

# Get Access Token
access_token=$(cat access_token.txt)

# Fetch posts
curl -s -H "Authorization: Bearer $access_token" \
     -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
     "https://oauth.reddit.com/r/PakLounge/hot?limit=1000" | jq -r '
.data.children[] |
  "🔸 \(.data.title)\n🌐 \(.data.url)\n👤 Author: \(.data.author)\n📝 \(.data.selftext)\n─────────────────────────────"
'
