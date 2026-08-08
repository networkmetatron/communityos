# CommunityOS

**Version 1.1.0**

> Take a clean Debian installation and turn it into a private, self-hosted community server with one command.

## Install

1. Install Debian 13.
2. On the server:

```bash
sudo ./install.sh
```

3. Answer a few questions.
4. DNS option during install:
   - **Y** — CommunityOS provides LAN DNS (`*.home.arpa`); set router DHCP DNS to this server.
   - **n** — You manage DNS yourself (Pi-hole, router, `/etc/hosts`, etc.).
5. **Reconnect clients** (Wi‑Fi off/on, Ethernet replug, or renew DHCP lease) so they pick up the new DNS.
6. Open **http://community.home.arpa**, install the **CommunityOS certificate once** (covers all services), then use HTTPS.

If `community.home.arpa` does not resolve:

- Disconnect and reconnect Wi‑Fi  
- **OR** unplug/reconnect Ethernet  
- **OR** renew the DHCP lease  

The device may still be using its previous DNS configuration.

## Certificate

CommunityOS uses one local CA for every hostname. Install `http://community.home.arpa/ca.crt` once on each device. After that, Website, Chat, Assistant, and optional apps should not show browser trust warnings.

## Assistant / Ollama

Ollama is installed with CommunityOS but **no model weights are downloaded**. Pull a model when ready:

```bash
sudo docker exec -it communityos-ollama ollama pull llama3.2
```

Then open https://ai.community.home.arpa and select the model. CPU-only hosts are supported; a GPU is optional.

## Optional apps

```bash
communityos apps
sudo communityos app install kiwix      # Library
sudo communityos app install maps       # Maps
sudo communityos app install jellyfin   # Media
sudo communityos app install nextcloud  # Files
sudo communityos app install peertube   # Streaming
```

Installing an app updates DNS (when CommunityOS DNS is enabled) and reloads Caddy so certificates stay consistent. The same CommunityOS CA is used.

| App | URL |
|-----|-----|
| Library (Kiwix) | https://library.community.home.arpa |
| Maps | https://maps.community.home.arpa |
| Media (Jellyfin) | https://media.community.home.arpa |
| Files (Nextcloud) | https://files.community.home.arpa |
| Streaming (PeerTube) | https://stream.community.home.arpa |

## Everyday commands

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
communityos matrix invite    # single-use Chat registration invitation
```

Chat registration is **invitation-only**: generate a token with `communityos matrix invite`, share the registration link and token, and the person creates their own Matrix account. Open registration without a token stays disabled.

## Services

| Address | Purpose |
|---------|---------|
| community.home.arpa | Website |
| chat.community.home.arpa | Chat |
| ai.community.home.arpa | Assistant (Open WebUI)
| 127.0.0.1:11434 (server only) | Ollama API |

Everything lives under `/opt/communityos`. Docker is an implementation detail. Images are pinned for reproducibility.

See [PRINCIPLES.md](PRINCIPLES.md).

## Offline / local-first check

With the router WAN disconnected (or WAN cable unplugged), verify local services still load:

- Website, Chat, Assistant  
- Any installed optional apps (Library, Maps, Media, Files, Streaming)

**Expected to fail offline:** Docker image pulls, internet-backed AI models, Matrix federation to the public network, external package updates.

**Expected to keep working:** LAN DNS (if enabled), HTTPS with the CommunityOS CA, local content and chat between devices on the LAN.

## Release validation (maintainers)

Before tagging a release:

- [ ] Fresh Debian 13 install  
- [ ] DNS enabled (Y) and DNS disabled (n)  
- [ ] Android + Windows clients; Firefox + Chrome  
- [ ] Certificate install from welcome page  
- [ ] Client reconnect / DHCP renewal guidance verified  
- [ ] WAN disconnected: core services still reachable on LAN  
- [ ] Optional app install/remove; Caddy reload; same CA trusted  
- [ ] `communityos doctor` healthy; no stale `/etc/hosts` surprises  

## Future install path

```bash
curl -fsSL https://communityos.org/install | sudo bash
```

Until then, copy the release onto the server and run `sudo ./install.sh`.

## Development

The install path is `/opt/communityos`. Developers keep source in a **Git clone** (e.g. `~/communityos`) and must not extract release ZIPs over that tree.

- Workflow: [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)
- Package a release: `./scripts/package-release.sh` → `~/releases/communityos-v*.zip`
- Test a ZIP under `~/releases/`, never by replacing the Git working tree
