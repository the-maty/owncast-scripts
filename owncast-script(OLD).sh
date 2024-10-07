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

function ssh_ip_extraction()
{
    # Kontrola zda ip local_ip stejna jako v configu VPS
    line_on_server=$(ssh $SSH_user@$SSH_host "sed '$line_number_ip!d' $SSH_ip_path")

    # Extrakce IP adresy
    ip_on_server=$(echo $line_on_server | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
}

# Function to restart the Traefik container
function reboot_traefik() {
    local ssh_user=$1
    local ssh_host=$2

    ssh $ssh_user@$ssh_host "docker restart traefik"
    echo "Traefik container has been restarted."
    sleep 1
}

# Function to add the comment symbol (#) to the beginning of the specified line if it does not exist
function add_comment_symbol() {
    local line_number_symbol=$1
    local ssh_user=$2
    local ssh_host=$3
    local ssh_ip_path=$4

    line_content=$(ssh $ssh_user@$ssh_host "sed -n '${line_number_symbol}p' $ssh_ip_path")

    if echo "$line_content" | grep -Fq 'block-all'; then
        if ! echo "$line_content" | grep -q '^#'; then
            # Add the comment symbol (#) to the beginning of the specified line
            ssh $ssh_user@$ssh_host "sed -i '${line_number_symbol}s/^/#/' $ssh_ip_path"
            echo "The comment symbol (#) has been added to the beginning of line $line_number_symbol because it contains 'block-all'."
        else
            echo "The line already starts with a comment symbol (#). No changes made."
        fi
    elif echo "$line_content" | grep -Fq 'middlewares:'; then
        if ! echo "$line_content" | grep -q '^#'; then
            # Add the comment symbol (#) to the beginning of the specified line
            ssh $ssh_user@$ssh_host "sed -i '${line_number_symbol}s/^/#/' $ssh_ip_path"
            echo "The comment symbol (#) has been added to the beginning of line $line_number_symbol because it contains 'middlewares:'."
        else
            echo "The line already starts with a comment symbol (#). No changes made."
        fi
    else
        echo "The line does not contain 'block-all' or 'middlewares:'. No changes made."
    fi
}

# Function to remove the comment symbol (#) from the beginning of a specified line
function remove_comment_symbol() {
    local line_number_symbol=$1
    local ssh_user=$2
    local ssh_host=$3
    local ssh_ip_path=$4

    # Fetch the specified line
    line_content=$(ssh $ssh_user@$ssh_host "sed -n '${line_number_symbol}p' $ssh_ip_path")

    # Check if the line starts with a comment symbol (#) or contains "middlewares:"
    if [[ $line_content == \#* ]] || [[ $line_content == *"middlewares:"* ]]; then
        # Remove the comment symbol (#) from the beginning of the line
        ssh $ssh_user@$ssh_host "sed -i '${line_number_symbol}s/^#//' $ssh_ip_path"
        echo "The comment symbol (#) has been removed from line $line_number_symbol."
    else
        echo "The line $line_number_symbol is not commented and does not contain 'middlewares:'. No changes made."
    fi
}

# Check if Owncast is running
if pgrep -f owncast > /dev/null; then
    echo -e "${RED}Owncast is already running.${RESET}"
    echo
    echo -n -e "${PURPLE}Do you want to stop the server? (y/n) ${RESET}"
    read stop_server

    if [ "$stop_server" = "y" ]; then
        echo -e "${CYAN}Stopping Owncast...${RESET}"
        pkill -9 -f owncast

        echo
        # Traefik remove comment symbol (#) function call for 3 different lines, after restart
        remove_comment_symbol $domain_line_comment_1 $SSH_user $SSH_host $SSH_ip_path
        remove_comment_symbol $domain_line_comment_2 $SSH_user $SSH_host $SSH_ip_path
        remove_comment_symbol $domain_line_comment_3 $SSH_user $SSH_host $SSH_ip_path
        reboot_traefik $SSH_user $SSH_host

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

# Zavolej funkci pro ziskani informaci o pripojeni      # disabled?
get_connection_info

if [ "$interface_id" == "utun4" ]; then
  echo -e "${CYAN}Making Owncast accessible over${RESET} ${UNDERLINE}Wi-Fi${RESET}${CYAN}...${RESET}"
  echo -e "${CYAN}Checking local IPv4 adress...${RESET}"
  sleep 2

else
  echo -e "${CYAN}Making Owncast accessible over${RESET} ${UNDERLINE}Ethernet${RESET}${CYAN}...${RESET}"
  echo -e "${CYAN}Checking local IPv4 adress...${RESET}"
  sleep 2
fi

# Lokalni ip adresa
#local_ip=$(ipconfig getifaddr $interface_id)    # Temp disabled local fixed value
local_ip="10.66.66.2"

function launch_owncast() {

  # Traefik add comment symbol (#) function call for 3 different lines, after restart
  add_comment_symbol $domain_line_comment_1 $SSH_user $SSH_host $SSH_ip_path
  add_comment_symbol $domain_line_comment_2 $SSH_user $SSH_host $SSH_ip_path
  add_comment_symbol $domain_line_comment_3 $SSH_user $SSH_host $SSH_ip_path
  reboot_traefik $SSH_user $SSH_host

  #ssh_ip_extraction     # Temp disabled extraction function

    if [ "$local_ip" == "10.66.66.2" ]; then        # Edited pro fixed wireguard IP it was local_ip var
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

        # Konec pri spravnem provedeni skriptu
        echo
        echo -e "${ORANGE}-------------------------- DONE --------------------------${RESET}"
        sleep 2

        # Ukonceni terminalu
        exit
    else 
        echo -e "${RED}Error: Traefik IP is now ${RESET}${UNDERLINE}$ip_on_server${RESET}"
        echo -e "${RED}Error: It is necessary the IPv4 address to be changed to${RESET} ${UNDERLINE}$local_ip${RESET}"
        echo

        # Otazka jestli chceme pokracovat
        echo -ne "${PURPLE}Do you want to proceed? (y/n) ${RESET}"
        read proceed

        if [[ "$proceed" == "y" || "$proceed" == "Y" ]]; then
        
            # Remote edit IP address on VPS
            ssh $SSH_user@$SSH_host "sed -i '${line_number}s/${ip_on_server}/${local_ip}/' $SSH_ip_path"

            echo
            echo -e "${CYAN}${local_ip} successfully inserted inside ${SSH_ip_path} on line ${line_number}.${RESET}"
            echo -e "${CYAN}Reruning script in 5 sec...${RESET}"
            sleep 5
            # Rerun script after change of IP on VPS
            launch_owncast
        else
            echo -e "${RED}Error: Script was terminated...${RESET}"

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
    fi
}

# Asi neni uplne v poho, ale it works like that
launch_owncast