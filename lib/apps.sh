#!/usr/bin/env bash
# Optional app helpers — metadata from apps/*.manifest.yaml / registry.json

APPS_DIR="${COMMUNITYOS_ROOT}/apps"
APPS_STATE="${COMMUNITYOS_ROOT}/runtime/apps"
REGISTRY="${APPS_DIR}/registry.json"

app_list_ids() {
  if [[ -f "${REGISTRY}" ]] && command -v python3 >/dev/null 2>&1; then
    python3 -c "import json; print('\\n'.join(json.load(open('${REGISTRY}'))))" 2>/dev/null && return
  fi
  printf '%s\n' kiwix maps jellyfin nextcloud peertube
}

app_is_enabled() {
  local id="$1"
  [[ -f "${APPS_STATE}/${id}.enabled" ]]
}

app_enable() {
  local id="$1"
  mkdir -p "${APPS_STATE}"
  touch "${APPS_STATE}/${id}.enabled"
}

app_disable_flag() {
  local id="$1"
  rm -f "${APPS_STATE}/${id}.enabled"
}

# Print a field from the registry for an app id: name|description|url|domain|container|data|compose
app_meta() {
  local id="$1" field="$2"
  if [[ -f "${REGISTRY}" ]] && command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json,sys
r=json.load(open('${REGISTRY}'))
app=r.get('${id}') or {}
print(app.get('${field}','') or '')
" 2>/dev/null
    return
  fi
  # Fallback
  case "${id}:${field}" in
    kiwix:name) echo "Library" ;;
    kiwix:description) echo "Offline knowledge library" ;;
    kiwix:url) echo "https://library.community.home.arpa" ;;
    kiwix:container) echo "communityos-kiwix" ;;
    maps:name) echo "Maps" ;;
    maps:description) echo "Offline maps (Martin + MapLibre)" ;;
    maps:url) echo "https://maps.community.home.arpa" ;;
    maps:container) echo "communityos-martin" ;;
    jellyfin:name) echo "Media" ;;
    jellyfin:description) echo "Local media server" ;;
    jellyfin:url) echo "https://media.community.home.arpa" ;;
    jellyfin:container) echo "communityos-jellyfin" ;;
    nextcloud:name) echo "Files" ;;
    nextcloud:description) echo "Personal and shared file storage (Nextcloud)" ;;
    nextcloud:url) echo "https://files.community.home.arpa" ;;
    nextcloud:domain) echo "files.community.home.arpa" ;;
    nextcloud:container) echo "communityos-nextcloud" ;;
    peertube:name) echo "Streaming" ;;
    peertube:description) echo "Community video hosting and live streaming" ;;
    peertube:url) echo "https://stream.community.home.arpa" ;;
    peertube:domain) echo "stream.community.home.arpa" ;;
    peertube:container) echo "communityos-peertube" ;;
    *:data) echo "${COMMUNITYOS_ROOT}/data/${id}" ;;
    *:compose) echo "apps/${id}.yaml" ;;
    *) echo "" ;;
  esac
}

app_aliases_resolve() {
  # friendly names -> app ids
  case "$1" in
    library) echo kiwix ;;
    media) echo jellyfin ;;
    files) echo nextcloud ;;
    streaming|stream) echo peertube ;;
    *) echo "$1" ;;
  esac
}

compose_with_apps() {
  local args=()
  local id
  args+=(-f "${COMMUNITYOS_ROOT}/compose.yaml")
  for id in $(app_list_ids); do
    if app_is_enabled "${id}"; then
      local cf
      cf="$(app_meta "${id}" compose)"
      [[ -z "${cf}" ]] && cf="apps/${id}.yaml"
      if [[ -f "${COMMUNITYOS_ROOT}/${cf}" ]]; then
        args+=(-f "${COMMUNITYOS_ROOT}/${cf}")
      elif [[ -f "${COMMUNITYOS_ROOT}/apps/${id}.yaml" ]]; then
        args+=(-f "${COMMUNITYOS_ROOT}/apps/${id}.yaml")
      fi
    fi
  done
  docker compose "${args[@]}" --env-file "${COMMUNITYOS_ROOT}/.env" "$@"
}

app_update_dns() {
  local conf="${COMMUNITYOS_ROOT}/runtime/dnsmasq.conf"
  local ip=""
  if [[ -f "${COMMUNITYOS_ROOT}/.env" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "${COMMUNITYOS_ROOT}/.env" 2>/dev/null || true
    set +a
    ip="${SERVER_IP:-}"
  fi
  [[ -z "${ip}" ]] && return 0
  mkdir -p "${COMMUNITYOS_ROOT}/runtime"
  if [[ ! -f "${conf}" ]]; then
    cat > "${conf}" <<DNS
domain-needed
bogus-priv
no-resolv
server=1.1.1.1
server=8.8.8.8
address=/community.home.arpa/${ip}
DNS
  fi
  local id domain
  for id in $(app_list_ids); do
    domain="$(app_meta "${id}" domain)"
    [[ -z "${domain}" ]] && continue
    if ! grep -q "address=/${domain}/" "${conf}" 2>/dev/null; then
      echo "address=/${domain}/${ip}" >> "${conf}"
    fi
  done
  if docker exec communityos-dns true >/dev/null 2>&1; then
    docker restart communityos-dns >/dev/null 2>&1 || true
  fi
}
