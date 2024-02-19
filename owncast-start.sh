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
echo -e " ____  _             _      ___                               _   ";
echo -e "/ ___|| |_ __ _ _ __| |_   / _ \__      ___ __   ___ __ _ ___| |_ ";
echo -e "\___ \| __/ _' | '__| __| | | | \ \ /\ / / '_ \ / __/ _' / __| __|";
echo -e " ___) | || (_| | |  | |_  | |_| |\ V  V /| | | | (_| (_| \__ \ |_ ";
echo -e "|____/ \__\__,_|_|   \__|  \___/  \_/\_/ |_| |_|\___\__,_|___/\__|";
echo -e "               _       _                                          ";
echo -e " ___  ___ _ __(_)_ __ | |_                                        ";
echo -e "/ __|/ __| '__| | '_ \| __|                                       ";
echo -e "\__ \ (__| |  | | |_) | |_                                        ";
echo -e "|___/\___|_|  |_| .__/ \__|                                       ";
echo -e "                |_|                                               ";
echo -e "${RESET}"

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

# Kontrola, zda je lokalni IP adresa spravna    
if [ "$local_ip" = "$your_desired_ip" ]; then  # <---- Uprava IP adresy ZDE            # KDYZ SPRAVNA IP
    clear
    echo

    # Prejit do adresaree "$owncast_dir" a spustit "./owncast" na pozadi
    cd "$owncast_dir" && nohup ./owncast > /dev/null 2>&1 &

    if [ "$RemoteAccess" = "true" ]; then

      # Commands to be executed on the remote machine
      command_to_execute="sudo tailscale up"

      # SSH connection and command execution
      ssh -i "$ssh_key_path" "$remote_user@$remote_host" "$command_to_execute"

    else
        echo -e "${CYAN}Skipping remote access function${RESET}"
        echo -e "${CYAN}not configured in config.sh...${RESET}"
    fi
    
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

else                                                                                # KDYZ SPATNA IP
    echo
    echo -e "${RED}Error: It is necessary to change the IPv4 address to${RESET} ${UNDERLINE}$local_ip${RESET}"
    echo -e "${RED}If you are changing on CF dashboard, change it in your config.sh too.${RESET}"
    
    echo
    echo -e "${CYAN}Openning dashboard...${RESET}"
    sleep 3
    
    # Pouziti open na macOS / xdg-open na Linuxu
    if command -v open &> /dev/null; then
        open "$cloudflare_url"
    elif command -v xdg-open &> /dev/null; then     # Upravena kompatibilita
        xdg-open "$cloudflare_url"
    else
        echo
        echo -e "${RED}Error: Unable to open the URL. Please open it manually in your web browser.${RESET}"
        echo -e "${ORANGE}$cloudflare_url${RESET}"
    fi

    # Ukonceni terminalu s chybou
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
