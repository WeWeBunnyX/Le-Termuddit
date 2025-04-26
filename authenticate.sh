#!/bin/bash
source config.sh

# Get the access token
access_token=$(curl -s -u "$client_id:$client_secret" \
  -d grant_type=client_credentials \
  -A "$user_agent" \
  https://www.reddit.com/api/v1/access_token | jq -r '.access_token')

# Print the access token in a way that can be easily parsed
echo "Access Token: $access_token"
