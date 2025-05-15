#!/bin/bash

CRED_FILE="credentials.txt"

get_and_save_credentials() {
    echo "Enter Reddit App Client ID:"
    read client_id
    echo "Enter Reddit App Client Secret:"
    read client_secret

    echo "$client_id" > "$CRED_FILE"
    echo "$client_secret" >> "$CRED_FILE"
    echo "Credentials saved to $CRED_FILE"
}


if [[ -f "$CRED_FILE" ]]; then
    echo "Credentials file found: $CRED_FILE"
    read -p "Continue with existing credentials? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        client_id=$(sed -n '1p' "$CRED_FILE")
        client_secret=$(sed -n '2p' "$CRED_FILE")
    else
        get_and_save_credentials
    fi
else
    echo "No credentials file found. Please enter credentials."
    get_and_save_credentials
fi


user_agent="bash:termuddit:v1.0 (by /u/WeWeBunnyX)"


access_token=$(curl -s -u "$client_id:$client_secret" \
  -d grant_type=client_credentials \
  -A "$user_agent" \
  https://www.reddit.com/api/v1/access_token | jq -r '.access_token')


echo "$access_token" > access_token.txt

echo "Access Token saved to access_token.txt"
