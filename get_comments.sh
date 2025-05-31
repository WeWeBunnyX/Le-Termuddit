#!/bin/bash

post_id=$1
access_token=$(cat access_token.txt)

# Color VARs
COMMENT_COLOR='\e[95m'
AUTHOR_COLOR='\e[93m'
SCORE_COLOR='\e[94m'
DEPTH_COLOR='\e[90m'
RESET='\e[0m'

print_comment() {
    local depth=$1
    local indent=$(printf "%*s" "$((depth*2))" "")
    
    echo -e "${DEPTH_COLOR}$indent${AUTHOR_COLOR}👤 $author ${SCORE_COLOR}(↑ $score)${RESET}"
    echo -e "${DEPTH_COLOR}$indent${COMMENT_COLOR}$body${RESET}"
    echo -e "${DEPTH_COLOR}$indent─────────────────────────────${RESET}"
}

comments=$(curl -s -H "Authorization: Bearer $access_token" \
     -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
     "https://oauth.reddit.com/comments/$post_id" | \
     jq -r '.[1].data.children[].data | 
     [.author, .body, .score] | @tsv')

echo "$comments" | while IFS=$'\t' read -r author body score; do
    print_comment 0
done