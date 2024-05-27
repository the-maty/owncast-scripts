# Owncast Server Control Scripts

This repository contains scripts to conveniently start and stop the Owncast server on macOS and Linux platforms.

## What does it do?

This script is designed to manage and configure an Owncast server, which is a self-hosted live video and web chat server for use with existing popular broadcasting software. Here's a summary of what the script does:

1. It starts by defining some ANSI color codes for console output.

2. It then determines the directory of the script and loads a configuration file (`config.sh`) from the same directory.

3. The script checks if an Owncast server is already running. If it is, it asks the user if they want to stop the server. If the user chooses to stop the server, it kills the Owncast process and exits. If the user chooses not to stop the server, the script simply terminates.

4. If the Owncast server is not running, the script proceeds to get information about the network connection. It asks the user to choose between Wi-Fi and Ethernet, and sets the `interface_id` variable accordingly.

5. The script then checks if the chosen network interface exists. If it doesn't, it prints an error message and exits.

6. The script then retrieves the local IP address of the chosen network interface.

7. The script defines a function `launch_owncast` which does the following:

   - It checks if the local IP address matches the IP address in the configuration of a remote VPS (Virtual Private Server). If they match, it starts the Owncast server in the background, opens OBS (Open Broadcaster Software), and optionally starts a Trakt Discord Presence Python script. It then exits.
   
   - If the local IP address does not match the IP address in the VPS configuration, it asks the user if they want to proceed. If the user chooses to proceed, it changes the IP address in the VPS configuration to the local IP address, and then reruns the `launch_owncast` function. If the user chooses not to proceed, it prints an error message and exits.

8. Finally, the script calls the `launch_owncast` function to start the Owncast server.

In summary, this script is used to manage an Owncast server, ensuring that it is properly configured with the correct IP address and network interface, and that it is not already running before starting it. It also provides options to stop a running Owncast server and to change the IP address in a remote VPS configuration.

### Prerequisites

- Owncast server installed on your machine. You can find more information on how to install Owncast [here](https://owncast.online/docs/).
- A pre-configured Cloudflare Tunnel is required for optimal functionality. Installation instructions can be found [here](https://www.linkedin.com/pulse/cloudflare-tunnel-setup-docker-christian-rune).
- If you want to have shortcuts on your desktop with a nice icon, [here](https://www.iconfinder.com/icons/103344/stop_server_icon) and [here](https://www.iconfinder.com/icons/103341/run_server_icon) are the icons that I use.

### Installation

1. Clone this repository to your local machine.

   ```bash
   git clone https://github.com/the-maty/owncast-server-scripts.git
   ```

2. Create your config.sh file from example-config.sh .

## Usage

### Starting Owncast Server

To start the Owncast server including Cloudflare Tunnel, use the following command:

```bash
chmod 600 config.sh
chmod +x owncast-script.sh
./owncast-script.sh
```
### Stopping Owncast Server

To gracefully stop the Owncast server, execute the following command:

```bash
chmod +x owncast-stop.sh
./owncast-stop.sh
```

## Compatibility

These scripts are designed to work seamlessly on both macOS and Linux platforms.

- **macOS:** Tested on macOS version 10.15 and later.
- **Linux:** Successfully tested on Ubuntu 18.04 and later.

Feel free to use these scripts on your preferred operating system, ensuring a consistent experience across compatible environments.

```markdown
## Contributing
