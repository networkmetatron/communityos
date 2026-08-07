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
