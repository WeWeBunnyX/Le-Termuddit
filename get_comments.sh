#!/bin/bash

post_id=$1
access_token=$(cat access_token.txt)

# Color VARs
COMMENT_COLOR='\e[95m'
AUTHOR_COLOR='\e[93m'
SCORE_COLOR='\e[94m'
UPVOTE_COLOR='\e[92m' 
DEPTH_COLOR='\e[90m'
RED_COLOR='\e[91m'
RESET='\e[0m'


print_comment() {
    local depth=$1
    local indent=$(printf "%*s" "$((depth*2))" "")
    
    local score_display=""
    if ((score > 0)); then
        score_display="${UPVOTE_COLOR}( ↑${SCORE_COLOR}${score}${UPVOTE_COLOR} )${RESET}"
    else
        score_display="${SCORE_COLOR}( ${score} )${RESET}"
    fi
    
    echo -e "${DEPTH_COLOR}$indent${AUTHOR_COLOR}👤 $author ${score_display}${RESET}"
    echo -e "${DEPTH_COLOR}$indent${COMMENT_COLOR}$body${RESET}"
    echo -e "${DEPTH_COLOR}$indent─────────────────────────────${RESET}"
}

comments=$(curl -s -H "Authorization: Bearer $access_token" \
     -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
     "https://oauth.reddit.com/comments/$post_id?depth=10&limit=100&sort=top" | \
     jq -r '.[1].data.children[].data | 
     select(.author != null and .body != null and .body != "[removed]" and .body != "[deleted]") |
     [.author, .body, .score, (.depth // 0)] | @tsv')

# Display comment count
total_comments=$(echo "$comments" | wc -l)
echo -e "\n=== Comments ${RED_COLOR}(Showing $total_comments available comments)${RESET} ===\n"

# Display comments
if [[ -z "$comments" ]]; then
    echo "No comments found for this post."
else
    echo "$comments" | while IFS=$'\t' read -r author body score depth; do
        print_comment "$depth"
    done
fi


# Load more comments prompt
echo -e "\nPress 'm' to load more comments or Enter to return: "
read -r more

if [[ "$more" == "m" || "$more" == "M" ]]; then
    comments=$(curl -s -H "Authorization: Bearer $access_token" \
         -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
         "https://oauth.reddit.com/comments/$post_id?depth=10&limit=500&sort=top" | \
         jq -r '.[1].data.children[].data | 
         select(.author != null and .body != null and .body != "[removed]" and .body != "[deleted]") |
         [.author, .body, .score, (.depth // 0)] | @tsv')
    
    total_comments=$(echo "$comments" | wc -l)
    echo -e "\n=== Comments ${RED_COLOR}(Showing $total_comments available comments)${RESET} ===\n"
    
    echo "$comments" | while IFS=$'\t' read -r author body score depth; do
        print_comment "$depth"
    done
fi