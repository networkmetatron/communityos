# CommunityOS

**Version 1.1.0**

> **CommunityOS is a local-first platform for running a digital community.**
>
> Install it on a clean Debian 13 server and get a website, chat, AI assistant, automatic HTTPS, and optional community apps with a single installation.

---

## Features

### Core

- 🌐 Website (WordPress)
- 💬 Chat (Matrix + Element)
- 🤖 AI Assistant (Open WebUI)
- 🔒 Automatic HTTPS (Caddy)
- 🌐 Optional LAN DNS (`*.home.arpa`)

### Optional apps

- 📚 Library (Kiwix)
- 🗺 Maps (Martin + MapLibre)
- 🎬 Media (Jellyfin)
- 📁 Files (Nextcloud)
- 📺 Streaming (PeerTube)

Everything lives under `/opt/communityos`.

Docker is an implementation detail.

Container images are pinned for reproducible installations.

---

# Installation

1. Install Debian 13.

2. Copy the CommunityOS release onto the server.

3. Run:

```bash
sudo ./install.sh
```

4. Answer a few installation questions.

5. DNS during installation:

- **Y** — CommunityOS provides LAN DNS (`*.home.arpa`).
  Configure your router's DHCP DNS server to point to CommunityOS.

- **n** — Use your existing DNS solution
  (router, Pi-hole, `/etc/hosts`, etc.)

6. Reconnect client devices:

- Disconnect/reconnect Wi-Fi
- OR unplug/reconnect Ethernet
- OR renew the DHCP lease

The device may still be using its previous DNS configuration.

7. Visit:

```
http://community.home.arpa
```

Install the CommunityOS certificate once.

Then use HTTPS for all services.

---

# Certificate

CommunityOS uses a single local Certificate Authority.

Download:

```
http://community.home.arpa/ca.crt
```

Install it once on every device.

The same CA secures:

- Website
- Chat
- Assistant
- Every installed optional app

---

# Optional Apps

List installed apps:

```bash
communityos apps
```

Install:

```bash
sudo communityos app install kiwix
sudo communityos app install maps
sudo communityos app install jellyfin
sudo communityos app install nextcloud
sudo communityos app install peertube
```

Installing an app automatically:

- updates DNS (when CommunityOS DNS is enabled)
- reloads Caddy
- refreshes HTTPS certificates

| App | URL |
|------|-----|
| Library | https://library.community.home.arpa |
| Maps | https://maps.community.home.arpa |
| Media | https://media.community.home.arpa |
| Files | https://files.community.home.arpa |
| Streaming | https://stream.community.home.arpa |

---

# Everyday Commands

```bash
communityos info
communityos status
communityos doctor
communityos logs
communityos update
communityos backup
communityos start
communityos stop
communityos uninstall
```

---

# Core Services

| Address | Purpose |
|----------|---------|
| https://community.home.arpa | Website |
| https://chat.community.home.arpa | Chat |
| https://ai.community.home.arpa | Assistant |

---

# Local-First

CommunityOS is designed to continue working even when the Internet is unavailable.

With the WAN disconnected, verify that:

- Website works
- Chat works
- Assistant works
- Installed optional apps work

Expected to continue working:

- LAN DNS (when enabled)
- HTTPS using the CommunityOS CA
- Local chat
- Local content
- Local media
- Local files

Expected to fail:

- Docker image downloads
- Internet-backed AI
- Matrix federation
- Package updates

---

# Release Validation

Before tagging a release:

- [ ] Fresh Debian 13 install
- [ ] DNS enabled (Y)
- [ ] DNS disabled (n)
- [ ] Android
- [ ] Windows
- [ ] Firefox
- [ ] Chrome
- [ ] Certificate installation
- [ ] DHCP renewal guidance verified
- [ ] WAN disconnected
- [ ] Optional app install/remove
- [ ] `communityos doctor` healthy

---

# Principles

See:

```
PRINCIPLES.md
```

---

# License

CommunityOS is free software licensed under the **GNU General Public License v3.0 (GPL-3.0)**.

See the `LICENSE` file for the complete license text.

---

# Future

Eventually CommunityOS will support one-command installation:

```bash
curl -fsSL https://communityos.org/install | sudo bash
```

Until then, copy the release onto the server and run:

```bash
sudo ./install.sh
```
