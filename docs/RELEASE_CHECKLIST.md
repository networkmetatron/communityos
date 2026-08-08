# CommunityOS release checklist

- [ ] Fresh Debian 13 install
- [ ] DNS enabled (Y)
- [ ] DNS disabled (n)
- [ ] Android client
- [ ] Windows client
- [ ] Firefox
- [ ] Chrome
- [ ] Certificate installation (one CA for all names)
- [ ] WAN disconnected — local services still work
- [ ] Optional app install / remove
- [ ] Automatic Caddy reload and DNS update on app install
- [ ] Host resolver restore (Y → 127.0.0.1 after functional DNS check; n → original/conventional)
- [ ] Stale /etc/hosts warning (install + doctor)

## Source vs release artifact

- `~/communityos` (or any clone) is the **Git working tree**. Never delete `.git` or extract a ZIP over it.
- Build the release with `./scripts/package-release.sh` from the repository root.
- Ship `~/releases/communityos-vX.Y.Z.zip` (or the printed path).
- For package testing, extract under `~/releases/…`, not over the Git tree.
- Production runtime remains `/opt/communityos`.
