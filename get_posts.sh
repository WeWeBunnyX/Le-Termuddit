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
    [.data.name[3:], 
     .data.title, 
     .data.author, 
     .data.selftext, 
     .data.num_comments,
     (.data.url | select(contains(".jpg") or contains(".png") or contains(".gif")))] |
    @tsv')

# Color VARs
TITLE_COLOR='\e[96m'
AUTHOR_COLOR='\e[93m'
BODY_COLOR='\e[92m'
COMMENT_INFO_COLOR='\e[94m'
RESET='\e[0m'

post_number=1
while IFS=$'\t' read -r id title author selftext num_comments image_url; do
    echo -e "${TITLE_COLOR}[$post_number] 🔸 $title${RESET}"
    echo -e "${AUTHOR_COLOR}👤 Author: $author${RESET}"
    
    # Convert and display image as ASCII (if available)
    if [[ -n "$image_url" ]]; then
        echo -e "${BODY_COLOR}🖼️  Image:${RESET}"
        # Download and Display Flags
        curl -s "$image_url" | chafa \
            --size=80x40 \
            --symbols=block+ascii+space-extra \
            --color-space=rgb \
            --dither=diffusion \
            --dither-intensity=1.0 \
            --color-extractor=average
    fi
    
    echo -e "${BODY_COLOR}📝 $selftext${RESET}"
    echo -e "${COMMENT_INFO_COLOR}💬 Comments: $num_comments${RESET}"
    echo -e "─────────────────────────────"
    
    
    post_ids[$post_number]=$id
    ((post_number++))
done <<< "$posts"


# View Comments Option
while true; do
    echo -e "\nOptions:"
    echo "Enter post number to view its comments"
    echo "r - Refresh posts"
    echo "q - Return to main menu"
    echo -n "Choose an option: "
    read -r selection

    case $selection in
        [0-9]*)
            if [[ -n "${post_ids[$selection]}" ]]; then
                bash get_comments.sh "${post_ids[$selection]}"
                # After viewing comments, redisplay posts
                clear
                while IFS=$'\t' read -r id title author selftext num_comments image_url; do
                    echo -e "${TITLE_COLOR}[$post_number] 🔸 $title${RESET}"
                    echo -e "${AUTHOR_COLOR}👤 Author: $author${RESET}"
                    
                    # Convert and display image as ASCII if available
                    if [[ -n "$image_url" ]]; then
                        echo -e "${BODY_COLOR}🖼️  Image:${RESET}"
                        # Download and display with enhanced settings
                        curl -s "$image_url" | chafa \
                            --size=80x40 \
                            --symbols=block+ascii+space-extra \
                            --color-space=rgb \
                            --dither=diffusion \
                            --dither-intensity=1.0 \
                            --color-extractor=average
                    fi
                    
                    echo -e "${BODY_COLOR}📝 $selftext${RESET}"
                    echo -e "${COMMENT_INFO_COLOR}💬 Comments: $num_comments${RESET}"
                    echo -e "─────────────────────────────"
                    ((post_number++))
                done <<< "$posts"
            else
                echo "Invalid post number!"
                sleep 1
            fi
            ;;
        r|R)
            clear
            # Refresh posts
            posts=$(curl -s -H "Authorization: Bearer $access_token" \
                 -H "User-Agent: bash:termuddit:v1.0 (by /u/WeWeBunnyX)" \
                 "https://oauth.reddit.com/r/$subreddit/hot?limit=$limit" | jq -r '
            .data.children[] |
                [.data.name[3:], .data.title, .data.author, .data.selftext, .data.num_comments] |
                @tsv')
            # Reset post counter and redisplay
            post_number=1
            while IFS=$'\t' read -r id title author selftext num_comments image_url; do
                echo -e "${TITLE_COLOR}[$post_number] 🔸 $title${RESET}"
                echo -e "${AUTHOR_COLOR}👤 Author: $author${RESET}"
                
                # Convert and display image as ASCII if available
                if [[ -n "$image_url" ]]; then
                    echo -e "${BODY_COLOR}🖼️  Image:${RESET}"
                    # Download and Display Flags
                    curl -s "$image_url" | chafa \
                        --size=80x40 \
                        --symbols=block+ascii+space-extra \
                        --color-space=rgb \
                        --dither=diffusion \
                        --dither-intensity=1.0 \
                        --color-extractor=average
                fi
                
                echo -e "${BODY_COLOR}📝 $selftext${RESET}"
                echo -e "${COMMENT_INFO_COLOR}💬 Comments: $num_comments${RESET}"
                echo -e "─────────────────────────────"
                post_ids[$post_number]=$id
                ((post_number++))
            done <<< "$posts"
            ;;
        q|Q)
            exit 0
            ;;
        *)
            echo "Invalid option!"
            sleep 1
            ;;
    esac
done
