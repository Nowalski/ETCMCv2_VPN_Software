# ETCMCv2 VPN Software

Official VPN client and server manager for the ETCMC ecosystem — powered by Ethereum Classic NFT licenses.

## Downloads

Get the latest installers from the [Releases](https://github.com/Nowalski/ETCMCv2_VPN_Software/releases) page.

| Software | Tag Format | Description |
|---|---|---|
| VPN Client | `client-v2.0.x` | Windows VPN client, NFT gated) |
| Server Manager | `sm-v2.0.x` | Windows app to deploy & manage your VPN server |

## How to Use

### VPN Client (end users)

1. Download `ETCMCv2-VPN-Client-Setup.exe` from the latest `client-v*` release
2. Run the installer (requires admin)
3. On first launch, connect your ETC wallet via WalletConnect
4. Your NFT license is verified on-chain — no account needed
5. Select a server and connect

### Server Manager (server operators / sharers)

1. Download `ETCMC-Server-Manager-Setup.exe` from the latest `sm-v*` release
2. Run the installer and launch the app
3. Use **Get a server** to deploy a Shadowbox VPN server via a cloud provider (DigitalOcean, etc.)
4. Enable the **ETC Sharer** feature to earn ETCPOWv2 rewards for running the server
5. Share your access key with VPN client users

### Install VPN Server on Linux (manual)

If you want to set up a VPN server on your own Linux machine without using the Server Manager:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Nowalski/ETCMCv2_VPN_Software/main/install_server.sh)
```


After the script completes it will output a JSON string. Copy it into the Server Manager under **Add a server**.

to Manage the Server on ur VM a Manage Server Script was made

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Nowalski/ETCMCv2_VPN_Software/main/manage.sh)
```
## Requirements

### VPN Client
- Windows 10 / 11 (64-bit)
- Admin rights (needed to install the VPN service and TAP adapter on first run)
- An ETC wallet with a valid VPNLicense NFT
- Layer 1 Existing Reworked,
All DNS requests are forced through the tunnel and use security-focused resolvers

• Quad9 (9.9.9.9) – blocks malware, phishing, botnets, and C2 domains
• Cloudflare Family (1.1.1.3) – blocks malware and adult content

This automatically prevents connections to a large number of known abuse domains.

Layer 2 NEW  Automatic traffic filtering
When the VPN connects, the client temporarily applies Windows Firewall rules that block common abuse traffic such as:

• SMTP ports (prevents spam relays)
• BitTorrent / P2P ports
• IRC botnet channels
• SOCKS proxy abuse

These rules are automatically removed when the VPN disconnects.

Layer 3 NEW  Domain blocking
The client also temporarily blocks a number of well-known torrent trackers and piracy index sites through a hosts file filter.

This creates a first layer of protection for server operators before traffic even leaves the client.

### Server Manager
- Windows 10 / 11
- A cloud provider account (DigitalOcean recommended) **or** a Linux server you control

### Linux VPN Server
- Ubuntu 20.04+ / Debian 11+ (x86_64)
- Docker installed (script can install it for you)
- Ports open: management API port + access key port (TCP/UDP)

## Update Notifications

Both the VPN Client and Server Manager automatically check this repo for new releases on startup. When a new version is available you will see an in-app notification with a link to the release page.


## License

ETCMCv2 VPN is a heavy modifiied version based on [Outline VPN] by Jigsaw, licensed under the Apache License 2.0.
