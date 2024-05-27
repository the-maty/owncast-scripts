# Rename to config.sh
# chmod 600 config.sh

export providerURL="CLOUDFLARE-ONE-URL-HERE";     # Cloudflare One Dashboard URL to get you there
export your_desired_ip="YOUR-LOCAL-IP-HERE";         # Local IP that you want to use for access over Cloudflare Tunnel
export owncast_dir="OWNCAST-DIRECTORY-HERE";         # Where is your owncast exe located
export Trakt_DcRP=""                                 # Trakt Discord Rich Presence function from python script
                                                     # To enable insert = true // leave empty to disable function (default)
#SSH access
export SSH_ip_path="path/to/file/on/VPS/file.txt"   # Those works when you are declaring in config file of traefik on VPS
export SSH_user="username"                          # I am checking against local_ip but you can change it in script for your needs
export SSH_host="host-ip"
export line_number="Line-where-is-ip-located"