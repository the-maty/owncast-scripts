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

# Force terminate OwnCast
pkill -9 -f owncast

if [ "$RemoteAccess" = "true" ]; then

    # Commands to be executed on the remote machine
    command_to_execute="sudo tailscale down"

    # SSH connection and command execution
    ssh -i "$ssh_key_path" "$remote_user@$remote_host" "$command_to_execute"

else
    echo -e "${CYAN}Skipping remote access function${RESET}"
    echo -e "${CYAN}not configured in config.sh...${RESET}"
fi

# Discord Trakt Presence detection turn off
# pkill -f DiscTrakt
# sleep 1

# if pgrep -f DiscTrakt > /dev/null; then
#     echo -e "${RED}Failed to terminate DiscTrakt.${RESET}"
#else
    echo
    echo -e "${ORANGE}-------------------------- DONE --------------------------${RESET}"

sleep 2
# Exit the terminal
exit
