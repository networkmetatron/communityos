#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
export COMMUNITYOS_ROOT="${COMMUNITYOS_ROOT:-/opt/communityos}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run:  sudo ./install.sh"
  exit 1
fi

# Bootstrap tools on minimal Debian (curl often missing)
need=()
command -v curl >/dev/null 2>&1 || need+=(curl)
command -v openssl >/dev/null 2>&1 || need+=(openssl)
dpkg -s ca-certificates >/dev/null 2>&1 || need+=(ca-certificates)
if [[ "${#need[@]}" -gt 0 ]]; then
  echo "Installing bootstrap tools: ${need[*]}"
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${need[@]}"
fi

# Copy package into /opt/communityos without requiring rsync
mkdir -p /opt/communityos/{lib,bin,scripts,static/welcome,runtime,backups}
if [[ "${ROOT}" != "/opt/communityos" ]]; then
  for item in compose.yaml Caddyfile config.json VERSION PRINCIPLES.md README.md CHANGELOG.md \
              bin lib scripts static apps data; do
    if [[ -e "${ROOT}/${item}" ]]; then
      cp -a "${ROOT}/${item}" /opt/communityos/
    fi
  done
fi
install -m 755 /opt/communityos/bin/communityos /usr/local/bin/communityos
# Ensure install-engine from this package tree is used (not a stale /opt copy alone)
export COMMUNITYOS_PKG="${ROOT}"
export COMMUNITYOS_ROOT=/opt/communityos
exec communityos install "$@"
