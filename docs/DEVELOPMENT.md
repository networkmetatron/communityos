# CommunityOS development workflow

## Permanent Git tree

On a development server, keep the project as a **persistent Git repository**:

```text
~/communityos/          # Git working tree (never delete this)
  .git/
  .gitignore
  compose.yaml
  bin/
  ...
```

**Never** replace this directory by extracting a release ZIP over it.

## Release ZIPs

Release archives are **build artifacts**, not the source of truth.

```text
Git repository  →  package  →  communityos-vX.Y.Z.zip
```

End users and test installs may extract the ZIP, but **not** into `~/communityos`.

### Packaging from the Git tree

From the repository root:

```bash
cd ~/communityos
./scripts/package-release.sh
```

This writes something like:

```text
~/releases/communityos-v1.1.0.zip
```

(or `./dist/` if `~/releases` is unavailable). It does not modify `.git`.

### Testing a release ZIP

Extract to a **separate** directory:

```bash
mkdir -p ~/releases
cd ~/releases
unzip -o ~/releases/communityos-v1.1.0.zip
# results in e.g. ~/releases/communityos/ or versioned folder
sudo ~/releases/communityos/install.sh
```

Or:

```bash
mkdir -p ~/releases/communityos-v1.1.0
cd ~/releases/communityos-v1.1.0
unzip -o /path/to/communityos-v1.1.0.zip
# if the archive top-level is "communityos/", use that subfolder
sudo ./communityos/install.sh
```

The installer copies into `/opt/communityos`. The extract location is only a bootstrap path.

## Updating the development tree

```bash
cd ~/communityos
git pull
# develop, commit, push as usual
```

To deploy local changes to the running install without a ZIP:

```bash
cd ~/communityos
sudo cp compose.yaml /opt/communityos/compose.yaml
sudo cp bin/communityos /opt/communityos/bin/communityos
sudo cp bin/communityos /usr/local/bin/communityos
# copy other changed files as needed
cd /opt/communityos && sudo docker compose --env-file .env up -d
```

## Forbidden workflow

```text
ZIP  →  rm -rf ~/communityos  →  unzip into ~/communityos
```

That destroys `.git` and forces `git init` / recommit / force-push. Do not do this.

## Summary

| Path | Role |
|------|------|
| `~/communityos` | Permanent Git working tree |
| `~/releases/` | ZIP artifacts and optional extract-for-test trees |
| `/opt/communityos` | Installed runtime (production data + config) |
