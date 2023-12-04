# Owncast Server Control Scripts

This repository contains scripts to conveniently start and stop the Owncast server on macOS and Linux platforms.

## Getting Started

### Prerequisites

- Owncast server installed on your machine. You can find more information on how to install Owncast [here](https://owncast.online/docs/).
- A pre-configured Cloudflare Tunnel is required for optimal functionality. Installation instructions can be found [here](https://www.linkedin.com/pulse/cloudflare-tunnel-setup-docker-christian-rune).

### Installation

1. Clone this repository to your local machine.

   ```bash
   git clone https://github.com/the-maty/owncast-server-scripts.git
   ```

2. Check file, provide your URL and IPv4 adress of your machine.

## Usage

### Starting Owncast Server

To start the Owncast server including Cloudflare Tunnel, use the following command:

```bash
./start-owncast.sh
```
### Stopping Owncast Server

To gracefully stop the Owncast server, execute the following command:

```bash
./stop-owncast.sh
```

## Compatibility

These scripts are designed to work seamlessly on both macOS and Linux platforms.

- **macOS:** Tested on macOS version 10.15 and later.
- **Linux:** Successfully tested on Ubuntu 18.04 and later.

Feel free to use these scripts on your preferred operating system, ensuring a consistent experience across compatible environments.

```markdown
## Contributing
