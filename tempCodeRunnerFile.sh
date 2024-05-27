#!/bin/bash

# ANSI color codes // light colors
RED='\033[91m'
PURPLE='\033[95m'
ORANGE='\033[38;2;255;165;0m'
CYAN='\033[96m'
UNDERLINE='\033[4m'
RESET='\033[0m'

# Check interface --> networksetup -listallhardwareports

# Get script directory for loading config.sh file
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Loading config.sh that is located in the same directory as scripts
source "$SCRIPT_DIR/config.sh" 

clear
echo -e "${ORANGE}"
echo -e "  ___                               _   ";
echo -e " / _ \__      ___ __   ___ __ _ ___| |_ ";
echo -e "| | | \ \ /\ / / '_ \ / __/ _' / __| __|";
echo -e "| |_| |\ V  V /| | | | (_| (_| \__ \ |_ ";
echo -e " \___/  \_/\_/ |_| |_|\___\__,_|___/\__|";
echo -e "               _       _                                          ";
echo -e " ___  ___ _ __(_)_ __ | |_                                        ";
echo -e "/ __|/ __| '__| | '_ \| __|                                       ";
echo -e "\__ \ (__| |  | | |_) | |_                                        ";
echo -e "|___/\___|_|  |_| .__/ \__|                                       ";
echo -e "                |_|                                               ";
echo -e "${RESET}"

# Check if Owncast is running
if pgrep -f owncast > /dev/null; then
    echo -e "${RED}Owncast is already running.${RESET}"
    echo -n -e "${PURPLE}Do you want to stop the server? (y/n) ${RESET}"
    read stop_server

    if [ "$stop_server" = "y" ]; then
        echo -e "${CYAN}Stopping Owncast...${RESET}"
        pkill -9 -f owncast
        echo
        echo -e "${ORANGE}-------------------------- DONE --------------------------${RESET}"
        sleep 2
        exit
    else
        echo -e "${CYAN}Terminating script...${RESET}"
        sleep 2
        exit 1
    fi
fi

# Funkce pro ziskani informaci o pripojeni
get_connection_info()
{
  echo
  echo -e "${PURPLE}Choose the connection type:${RESET}"
  echo -e "${PURPLE}  1) Wi-Fi${RESET}"
  echo -e "${PURPLE}  2) Ethernet${RESET}"
  echo -n -e "${PURPLE}Choose an option (1 / 2): ${RESET}"
  read choice

  case "$choice" in
    1)
      interface_id="en0"
      ;;
    2)
      interface_id="en9"
      ;;
    *)
      echo
      echo -e "${RED}Error: Invalid choice. Enter 1 for Wi-Fi or 2 for Ethernet.${RESET}"
      get_connection_info
      ;;
  esac

  # Kontrola existence zadaneho rozhrani
  if ! networksetup -listallhardwareports | grep -q "$interface_id"; then
    echo
    echo -e "${RED}Error: The specified interface${RESET} ${UNDERLINE}$interface_id${RESET} ${RED}does not exist...${RESET}"
    
    # Clean up kdyz je error 
    cleanup()
    {
      echo && echo
      printf "Press Enter to close the terminal..."
      read -r dummy
    }

    # Trap vola clean up a ukoncuje skript
    trap cleanup EXIT

    # Exit terminalu pri chybe
    exit 1
  fi

  echo -e "${ORANGE}Using interface:${RESET} ${UNDERLINE}$interface_id${RESET}"
}

# Zavolej funkci pro ziskani informaci o pripojeni
get_connection_info

if [ "$interface_id" == "en0" ]; then
  echo -e "${CYAN}Making Owncast accessible over${RESET} ${UNDERLINE}Wi-Fi${RESET}${CYAN}...${RESET}"
  echo -e "${CYAN}Checking local IPv4 adress...${RESET}"
  sleep 3

else
  echo -e "${CYAN}Making Owncast accessible over${RESET} ${UNDERLINE}Ethernet${RESET}${CYAN}...${RESET}"
  echo -e "${CYAN}Checking local IPv4 adress...${RESET}"
  sleep 3
fi

# Ziskani aktualni lokalni IP adresy na macOS
local_ip=$(ipconfig getifaddr $interface_id)

# Kontrola zda ip local_ip stejna jako v configu VPS
line_on_server=$(ssh $SSH_user@$SSH_host "sed '$line_number!d' $SSH_ip_path")

# Extrakce IP adresy
ip_on_server=$(echo $line_on_server | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

if [ "$local_ip" == "$ip_on_server" ]; then  #               # KDYZ SPRAVNA IP
    clear
    echo

    # Prejit do adresaree "$owncast_dir" a spustit "./owncast" na pozadi
    cd "$owncast_dir" && nohup ./owncast > /dev/null 2>&1 &
    
    echo
    echo -e "${CYAN}owncast successfully launched in the background.${RESET}"
    echo

    # Na konci spusteni OBS
    echo
    echo -e "${CYAN}Openning OBS...${RESET}"
    open -a OBS

    # Start Trakt Discord Presence python script
    if [ "$Trakt_DcRP" = "true" ]; then

        if pgrep -f DiscTrakt > /dev/null; then
            echo -e "${ORANGE}The Trakt script is already running.${RESET}"
            echo
            echo -e "${CYAN}Restarting Trakt Discord Presence detection...${RESET}"
            pkill -f DiscTrakt
            sleep 2
            nohup python3 /Users/maty/DEV/TraktDiscordRP/DiscTrakt > /dev/null 2>&1 &
        else
            echo -e "${CYAN}Starting Trakt Discord Presence detection...${RESET}"
            nohup python3 /Users/maty/DEV/TraktDiscordRP/DiscTrakt > /dev/null 2>&1 &
        fi
    else
        echo -e "${CYAN}Skipping discord presence Trakt function${RESET}"
        echo -e "${CYAN}not configured in config.sh...${RESET}"
    fi

# Konec pri spravnem provedeni skriptu
echo
echo -e "${ORANGE}-------------------------- DONE --------------------------${RESET}"
sleep 2

# Ukonceni terminalu
exit
        # KDYZ SPATNA IP

echo -e "${RED}Error: It is necessary the IPv4 address to be changed to${RESET} ${UNDERLINE}$local_ip${RESET}"
# Ask the user if they want to proceed
echo -e "${CYAN}Do you want to proceed? (y/n) ${RESET}"
read proceed

if [[ "$proceed" == "y" || "$proceed" == "Y" ]]; then
    
    # Remote edit IP address on VPS
    ssh $SSH_user@$SSH_host "sed -i '${line_number}s/${ip_on_server}/${local_ip}/' $SSH_ip_path"

    echo -e "${CYAN}${local_ip} successfully inserted inside ${SSH_ip_path} on line ${line_number}.${RESET}"
    sleep 3

    # Open OBS
    echo -e "${CYAN}Opening OBS...${RESET}"
    open -a OBS

else
    echo -e "${RED}Error: check your config.sh file if its configured correctly...${RESET}"
    # Terminate terminal with error
    # Clean up when there is an error 
    cleanup()
    {
      echo && echo
      printf "Press Enter to close the terminal..."
      read -r dummy
    }

    # Trap calls clean up and terminates script
    trap cleanup EXIT

    # Exit terminal on error
    exit 1
fi
