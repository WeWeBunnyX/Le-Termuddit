#!/bin/bash

CREDENTIALS_FILE="credentials.txt"

function input_credentials() {
    echo "Enter Client ID:"
    read -r client_id
    echo "Enter Client Secret:"
    read -r client_secret
    echo -e "$client_id\n$client_secret" > "$CREDENTIALS_FILE"
    echo "Credentials saved to $CREDENTIALS_FILE."
}

function authenticate() {
    bash authenticate.sh
    sleep 1
    clear
    bash get_posts.sh
}

function usage_menu() {
    echo -e "\n" 

    echo "===== Termuddit Usage Menu ====="
    echo "1) Start by inputting new credentials"
    if [[ -f "$CREDENTIALS_FILE" ]]; then
        echo "2) Continue with existing credentials"
    fi
    echo "3) Quit"
    echo "================================"
    echo -n "Choose an option (1-3): "
    read -r choice

    case $choice in
        1)
            input_credentials
            authenticate
            ;;
        2)
            if [[ -f "$CREDENTIALS_FILE" ]]; then
                echo "Using existing credentials."
                authenticate
            else
                echo "No existing credentials found. Please input new credentials."
                input_credentials
                authenticate
            fi
            ;;
        3)
            echo "Exiting Termuddit."
            exit 0
            ;;
        *)
            echo "Invalid option. Try again."
            sleep 1
            usage_menu
            ;;
    esac
}

bash splash.sh

usage_menu
