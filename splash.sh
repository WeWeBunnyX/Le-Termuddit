#!/bin/bash

# Get system info
distro=$(grep ^PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
kernel=$(uname -r)
host=$(hostname)


clear

# Load Message with OS Info
echo "Loading Termuddit @ $host ($distro)"
echo "Kernel: $kernel"
echo ""


bar_width=40
echo -n "["
for ((i = 0; i <= bar_width; i++)); do
    sleep 0.05

    filled=$(printf "%0.s#" $(seq 1 $i))
    empty=$(printf "%0.s-" $(seq 1 $((bar_width - i))))
    percent=$((i * 100 / bar_width))

    echo -ne "\r[$filled$empty] $percent%"

done


echo -e "\n\n"
sleep 0.5

# Welcome Banner/Screen
figlet "Welcome To Termuddit"
echo -e "\e[36mReddit CLI Client - Bash Edition\e[0m"
