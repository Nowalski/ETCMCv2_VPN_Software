# ETCMCv2 VPN Software

Official VPN client and server manager for the ETCMCv2 ecosystem — powered by Ethereum Classic NFT licenses.

## Downloads

Get the latest installers from the [Releases](https://github.com/Nowalski/ETCMCv2_VPN_Software/releases) page.

| Software | Tag Format | Description |
|---|---|---|
| VPN Client | `client-v2.0.x` | Windows VPN client, NFT license gated |
| Server Manager | `sm-v2.0.x` | Windows app to deploy and manage your VPN server |

---

## How to Use

### VPN Client (end users)

1. Download `ETCMCv2-VPN-Client-2.0.0.exe` from the latest `client-v*` release
2. Run the installer (requires admin)
3. On first launch, connect your ETC wallet via WalletConnect or MetaMask
4. Your NFT license is verified on-chain — no account or registration needed
5. The client binds to your device and loads the ETCMCv2 server list automatically
6. Select a server and connect

### Server Manager (server operators)

1. Download `ETCMC.Server.Manager.2.0.0.exe` from the latest `sm-v*` release
2. Run the installer and launch the app
3. Use **Get a server** to deploy a Shadowbox VPN server via a cloud provider (DigitalOcean, etc.)
4. Enable the **ETC Sharer** feature to earn ETCPOWv2 rewards for running the server
5. Your server is registered with the ETCMCv2 backend and made available to licensed clients automatically

### Install VPN Server on Linux (manual)

If you want to set up a VPN server on your own Linux machine:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Nowalski/ETCMCv2_VPN_Software/main/install_server.sh)
```

After the script completes it will output a JSON string. Copy it into the Server Manager under **Add a server**.

To manage the server on your VM, a management script is also available:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Nowalski/ETCMCv2_VPN_Software/main/manage.sh)
```

---

## Requirements

### VPN Client
- Windows 10 / 11 (64-bit)
- Admin rights (required to install the VPN service and TAP adapter)
- An ETC Classic wallet with a valid VPNLicense NFT

### Server Manager
- Windows 10 / 11
- A cloud provider account (DigitalOcean recommended) or a Linux server you control

### Linux VPN Server
- Ubuntu 20.04+ / Debian 11+ (x86_64)
- Docker installed (the install script can handle this)
- Ports open: management API port + access key port (TCP/UDP)

---

## Architecture

### License Flow

```
Wallet connects (WalletConnect / MetaMask)
        |
        v
NFT ownership verified on-chain (ETC Classic)
        |
        v
Client signs a message with wallet --> Backend issues 7-day JWT
        |
        v
Device binding recorded (one device per license)
        |
        v
Server list loaded automatically -- client connects
```

### Server Discovery

VPN servers are registered by operators running the Server Manager. The ETCMCv2 backend holds the list of live servers. After a valid license is confirmed, the client fetches this list automatically and adds servers without any manual entry. The list refreshes every 2 minutes to reflect servers going online or offline.

### Device Binding

Each NFT license is tied to one device at a time. When you authenticate, the backend records your device ID. If you switch machines, you can unlink your old device from the License tab in the client or Dashboard. Admins can also force-unlink a device.

---

## Security

ETCMCv2 VPN uses a layered approach to prevent abuse — both at the network level and at the platform level.

### Layer 1 — Encrypted DNS

All DNS requests are forced through the VPN tunnel and resolved by security-focused resolvers:

- **Quad9 (9.9.9.9)** — blocks malware, phishing, botnets, and command-and-control domains
- **Cloudflare Family (1.1.1.3)** — blocks malware and adult content

This stops the majority of known malicious domains before any connection is made.

### Layer 2 — Automatic Traffic Filtering

When the VPN connects, the client applies Windows Firewall rules that block common abuse traffic:

- SMTP ports — prevents spam relay
- BitTorrent and P2P ports — prevents torrent abuse
- IRC botnet channels
- SOCKS proxy abuse ports

These rules are applied automatically on connect and removed automatically on disconnect.

### Layer 3 — Domain Blocking

The client applies a hosts file filter that blocks well-known torrent trackers and piracy index sites for the duration of the VPN session. This is a client-side first line of defence before traffic reaches the server.

### Layer 4 — Wallet-Based Ban System

Server operators can report abusive client users through the ETCMCv2 abuse report portal. ETCMCv2 can ban a wallet address from the network at the backend level.

When a wallet is banned:

- The ban takes effect within minutes — the next automatic server list refresh detects it
- If the client is actively connected to a server, the VPN tunnel is disconnected immediately
- All ETCMCv2 servers are removed from the client's server list
- The client is locked cannot navigate or reconnect
- The ban message is shown immediately in the License tab

Bans are enforced at various independent checkpoints on the backend:


This means a ban is effective even if the client already holds a valid JWT.

### Layer 5 — NFT License Gate

Access to the VPN network requires ownership of a valid VPNLicense NFT on ETC Classic. The verification is on-chain — there is no central account system that can be bypassed. Expired or invalid licenses are rejected before any server list is loaded.

---

## Update Notifications

Both the VPN Client and Server Manager automatically check this repository for new releases on startup. When a new version is available, an in-app notification appears with a link to the release page.

---

## License

ETCMCv2 VPN is a heavily modified fork of [Outline](https://getoutline.org) by Jigsaw, licensed under the Apache License 2.0.
