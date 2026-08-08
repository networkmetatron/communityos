# Changelog

## v1.1.0

- Default install includes Ollama (no models). Open WebUI uses `OLLAMA_BASE_URL=http://ollama:11434`. API on `127.0.0.1:11434`.
- One CommunityOS CA for all hostnames; app install reloads Caddy and refreshes DNS.
- Stronger DHCP/DNS lease renewal guidance (installer, welcome page, doctor, README).
- Welcome page troubleshooting + certificate-covers-all messaging.
- Offline / local-first validation notes and release checklist.
- After install (when CommunityOS DNS is enabled), restore host `/etc/resolv.conf` to `nameserver 127.0.0.1` so the server resolves `*.home.arpa`.
- Jellyfin first-run admin seeded from CommunityOS admin credentials.
- Maps empty state is fully local (no CDN); clear “add tiles” guidance.
- Nextcloud data directory permissions fixed (www-data / uid 33).
- Optional **Streaming** app (PeerTube) → https://stream.community.home.arpa
  (`communityos app install peertube`); resource note for transcoding.
- Optional **Files** app (Nextcloud) → https://files.community.home.arpa
  (`communityos app install nextcloud`); files/sharing/WebDAV focused.
- App manifests (`apps/*.manifest.yaml` + `registry.json`) as single metadata source for CLI.
- Friendly pages when optional apps are not installed (instead of bare 502).
- `communityos apps` shows installed/running/available status.
- Optional apps framework: `communityos apps` / `communityos app install|remove|restart`
- **Kiwix** offline library → https://library.community.home.arpa
- **Maps** (Martin + MapLibre) → https://maps.community.home.arpa
- **Jellyfin** media → https://media.community.home.arpa
- DNS records for library / maps / media when CommunityOS DNS is enabled
- Caddy routes for optional apps (active when app containers are running)

## v1.0.2

- Improved first-run onboarding and DNS = n guidance
- Stronger IPv4 DNS setup for image pulls
- Interactive uninstall with y/yes and accurate summary
- Preserve DB passwords on reinstall
- Hardened health checks and doctor DNS diagnostics
