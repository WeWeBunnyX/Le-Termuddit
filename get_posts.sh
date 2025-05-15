#!/bin/bash

# 1. Authenticate (will also fetch and store token if needed)
bash authenticate.sh > /dev/null

# 2. Load the access token from file
access_token=$(cat access_token.txt)

# 3. Fetch posts
curl -s -H "Authorization: Bearer $access_token" \
     -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
     "https://oauth.reddit.com/r/PakLounge/hot?limit=1000" | jq -r '
.data.children[] |
  "🔸 \(.data.title)\n🌐 \(.data.url)\n👤 Author: \(.data.author)\n📝 \(.data.selftext)\n─────────────────────────────"
'
