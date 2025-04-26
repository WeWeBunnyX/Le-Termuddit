#!/bin/bash

source config.sh

# 2. Get access token
access_token=$(bash authenticate.sh | grep "Access Token" | awk '{print $3}')

# 3. Debug token
echo "Access Token: $access_token"

# 4. Fetch posts and display relevant information
curl -s -H "Authorization: Bearer $access_token" \
     -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
     "https://oauth.reddit.com/r/PakLounge/hot?limit=100" | jq -r '.data.children[] | "\(.data.title) \n \(.data.url) \n Author: \(.data.author)\n\(.data.selftext)\n"'
