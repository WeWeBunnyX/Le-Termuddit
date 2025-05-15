#!/bin/bash

# Define color codes
ORANGE='\033[38;5;208m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Get system info
distro=$(grep ^PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
kernel=$(uname -r)
host=$(hostname)

clear

# Load Message with OS Info 
echo -e "Loading ${ORANGE}Termuddit${NC} @ $host (${YELLOW}$distro${NC})"
echo -e "Kernel: ${RED}$kernel${NC}"
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
echo -e "${ORANGE}"
figlet "Welcome To Termuddit"
echo -e "${CYAN}Reddit CLI Client - Bash Edition${NC}"
