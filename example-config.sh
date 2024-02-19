# Rename to config.sh
# chmod 600 config.sh

export cloudflare_url="CLOUDFLARE-ONE-URL-HERE";     # Cloudflare One Dashboard URL to get you there
export your_desired_ip="YOUR-LOCAL-IP-HERE";         # Local IP that you want to use for access over Cloudflare Tunnel
export owncast_dir="OWNCAST-DIRECTORY-HERE";         # Where is your owncast exe located
export Trakt_DcRP=""                                 # Trakt Discord Rich Presence function from python script
                                                     # To enable insert = true // leave empty to disable function (default)
#SSH access to server
export RemoteAccess=""                              # To enable insert = true // leave empty to disable function (default)
export RemoteAccess_user="username"
export RemoteAccess_host="host-ip"
export RemoteAccess_sshkey="path-to-ssh-key"