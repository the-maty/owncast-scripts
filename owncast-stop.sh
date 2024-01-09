#!/bin/bash

# ANSI color codes  // light colors
RED='\033[91m'
ORANGE='\033[38;2;255;165;0m'
CYAN='\033[96m'
RESET='\033[0m'

clear
echo -e "${ORANGE}"
echo -e " ____  _                 ___                               _   ";
echo -e "/ ___|| |_ ___  _ __    / _ \__      ___ __   ___ __ _ ___| |_ ";
echo -e "\___ \| __/ _ \| '_ \  | | | \ \ /\ / / '_ \ / __/ _' / __| __|";
echo -e " ___) | || (_) | |_) | | |_| |\ V  V /| | | | (_| (_| \__ \ |_ ";
echo -e "|____/ \__\___/| .__/   \___/  \_/\_/ |_| |_|\___\__,_|___/\__|";
echo -e "               |_|                                             ";
echo -e "               _       _                                       ";
echo -e " ___  ___ _ __(_)_ __ | |_                                     ";
echo -e "/ __|/ __| '__| | '_ \| __|                                    ";
echo -e "\__ \ (__| |  | | |_) | |_                                     ";
echo -e "|___/\___|_|  |_| .__/ \__|                                    ";
echo -e "                |_|                                            ";
echo -e "${RESET}"

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

sleep 3

# Discord Trakt Presence detection turn off
pkill -f DiscTrakt.py
sleep 1

if pgrep -f DiscTrakt.py > /dev/null; then
    echo -e "${RED}Failed to terminate DiscTrakt.py.${RESET}"
else
    echo
    echo -e "${ORANGE}-------------------------- DONE --------------------------${RESET}"
fi

sleep 5
# Exit the terminal
exit
