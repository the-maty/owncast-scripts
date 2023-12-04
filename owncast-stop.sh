#!/bin/bash

# ANSI color codes  // light colors
ORANGE='\033[38;2;255;165;0m'
CYAN='\033[96m'
RESET='\033[0m'

clear
echo
echo -e "${CYAN}Stopping owncast...${RESET}"
# Wait 3 sec
sleep 3
# Force terminate OwnCast
pkill -9 -f owncast

echo
echo -e "${CYAN}Stopping Cloudflare Tunnel and exiting Docker...${RESET}"

# Stop Docker container named Cloudflare_Tunnel
docker container stop Cloudflare_Tunnel
sleep 3

# Forcefully terminate Docker processes
pkill -9 -f Docker

echo
echo -e "${ORANGE}-------------------------- DONE --------------------------${RESET}"
sleep 5
# Exit the terminal
exit
