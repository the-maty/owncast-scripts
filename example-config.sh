# Rename to config.sh
# chmod 600 config.sh

export providerURL="TRAEFIK-DASHBOARD-URL-HERE";     # Cloudflare One Dashboard URL to get you there

export owncast_dir="OWNCAST-DIRECTORY-HERE";         # Where is your owncast exe located

#SSH access
export SSH_ip_path="path/to/file/on/VPS/file.txt"   # Those works when you are declaring in config file of traefik on VPS
export SSH_user="username"                          # I am checking against local_ip but you can change it in script for your needs
export SSH_host="host-ip"
export line_number_ip="Line-where-is-ip-located"
export domain_line_comment_1="Line-where-is-block-all-declared"
export domain_line_comment_2="2nd-line-where-is-block-all-declared"
export domain_line_comment_3="3rd-line-where-is-block-all-declared"