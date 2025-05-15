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


posts=$(curl -s -H "Authorization: Bearer $access_token" \
     -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
     "https://oauth.reddit.com/r/$subreddit/hot?limit=$limit" | jq -r '
.data.children[] |
    [.data.title, .data.author, .data.selftext] |
    @tsv')


# Color VARs
TITLE_COLOR='\e[96m'
AUTHOR_COLOR='\e[93m'
BODY_COLOR='\e[92m'
RESET='\e[0m'


echo "$posts" | while IFS=$'\t' read -r title author selftext; do
    echo -e "${TITLE_COLOR}🔸 $title${RESET}"
    echo -e "${AUTHOR_COLOR}👤 Author: $author${RESET}"
    echo -e "${BODY_COLOR}📝 $selftext${RESET}"
    echo -e "─────────────────────────────"
done
