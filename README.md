# Owncast Server Control Scripts

This repository contains scripts to conveniently start and stop the Owncast server on macOS and Linux platforms.

## Getting Started

### Prerequisites

- Owncast server installed on your machine. You can find more information on how to install Owncast [here](https://owncast.online/docs/).
- A pre-configured Cloudflare Tunnel.

### Installation

1. Clone this repository to your local machine.

   ```bash
   git clone https://github.com/your-username/owncast-server-scripts.git
   ```
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
