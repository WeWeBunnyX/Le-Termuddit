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
    [.data.name[3:], .data.title, .data.author, .data.selftext, .data.num_comments] |
    @tsv')

# Color VARs
TITLE_COLOR='\e[96m'
AUTHOR_COLOR='\e[93m'
BODY_COLOR='\e[92m'
COMMENT_INFO_COLOR='\e[94m'
RESET='\e[0m'

post_number=1
while IFS=$'\t' read -r id title author selftext num_comments; do
    echo -e "${TITLE_COLOR}[$post_number] 🔸 $title${RESET}"
    echo -e "${AUTHOR_COLOR}👤 Author: $author${RESET}"
    echo -e "${BODY_COLOR}📝 $selftext${RESET}"
    echo -e "${COMMENT_INFO_COLOR}💬 Comments: $num_comments${RESET}"
    echo -e "─────────────────────────────"
    
    
    post_ids[$post_number]=$id
    ((post_number++))
done <<< "$posts"


# View Comments Option
echo -e "\nEnter post number to view comments (or press Enter to return): "
read -r selection

if [[ -n "$selection" ]] && [[ "${post_ids[$selection]}" ]]; then
    bash get_comments.sh "${post_ids[$selection]}"
fi
