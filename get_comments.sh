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


# JQ Query for handling comments and replies
comments=$(curl -s -H "Authorization: Bearer $access_token" \
     -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
     "https://oauth.reddit.com/comments/$post_id?depth=100&limit=100&sort=top" | \
     jq -r '
     def walk_comments:
       if type == "object" then
         if .kind == "t1" and .data then
           (.data | select(.author != null and .body != null) |
           select(.body != "[removed]" and .body != "[deleted]") |
           [.author, .body, .score, (.depth // 0)] | @tsv),
           (.data.replies?.data?.children[]? | walk_comments)
         elif .data?.children then
           (.data.children[] | walk_comments)
         else empty
         end
       else empty
       end;
     .[] | walk_comments')

#Total Available Comments
total_comments=$(echo "$comments" | wc -l)
echo -e "\n=== Comments ${RED_COLOR}(Showing $total_comments available comments)${RESET} ===\n"


print_comment() {
    local depth=$1
    local indent=$(printf "%*s" "$((depth*4))" "") 
    local prefix=""
    
    # Indicate as Reply
    if ((depth > 0)); then
        prefix="${DEPTH_COLOR}└─${RESET}"
    fi
    
    local score_display=""
    if ((score > 0)); then
        score_display="${UPVOTE_COLOR}( ↑${SCORE_COLOR}${score}${UPVOTE_COLOR} )${RESET}"
    else
        score_display="${SCORE_COLOR}( ${score} )${RESET}"
    fi
    
    echo -e "${DEPTH_COLOR}$indent$prefix${AUTHOR_COLOR}👤 $author ${score_display}${RESET}"
    echo -e "${DEPTH_COLOR}$indent   ${COMMENT_COLOR}$body${RESET}"
    echo -e "${DEPTH_COLOR}$indent   ─────────────────────────────${RESET}"
}

while true; do
    # Display comments
    if [[ -z "$comments" ]]; then
        echo "No comments found for this post."
    else
        clear  # Clear screen for better readability
        total_comments=$(echo "$comments" | wc -l)
        echo -e "\n=== Comments ${RED_COLOR}(Showing $total_comments available comments)${RESET} ===\n"
        
        echo "$comments" | while IFS=$'\t' read -r author body score depth; do
            print_comment "$depth"
        done
    fi
    
    echo -e "\nOptions:"
    echo "m - Load more comments"
    echo "r - Refresh current comments"
    echo "q - Return to posts"
    echo -n "Choose an option: "
    read -r choice

    case $choice in
        m|M)
            comments=$(curl -s -H "Authorization: Bearer $access_token" \
                 -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
                 "https://oauth.reddit.com/comments/$post_id?depth=10&limit=500&sort=top" | \
                 jq -r '
                 def walk_comments:
                   if type == "object" then
                     if .kind == "t1" and .data then
                       (.data | select(.author != null and .body != null) |
                       select(.body != "[removed]" and .body != "[deleted]") |
                       [.author, .body, .score, (.depth // 0)] | @tsv),
                       (.data.replies?.data?.children[]? | walk_comments)
                     elif .data?.children then
                       (.data.children[] | walk_comments)
                     else empty
                     end
                   else empty
                   end;
                 .[] | walk_comments')
            ;;
        r|R)
            # Refresh current comments
            comments=$(curl -s -H "Authorization: Bearer $access_token" \
                 -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
                 "https://oauth.reddit.com/comments/$post_id?depth=10&limit=100&sort=top" | \
                 jq -r '
                 def walk_comments:
                   if type == "object" then
                     if .kind == "t1" and .data then
                       (.data | select(.author != null and .body != null) |
                       select(.body != "[removed]" and .body != "[deleted]") |
                       [.author, .body, .score, (.depth // 0)] | @tsv),
                       (.data.replies?.data?.children[]? | walk_comments)
                     elif .data?.children then
                       (.data.children[] | walk_comments)
                     else empty
                     end
                   else empty
                   end;
                 .[] | walk_comments')
            ;;
        q|Q)
            clear
            break
            ;;
        *)
            echo "Invalid option!"
            sleep 1
            ;;
    esac
done