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
  # Regenerate runtime/dnsmasq.conf from .env SERVER_IP (source of truth).
  # Always rewrite — do not leave stale IPs after SERVER_IP changes.
  local conf="${COMMUNITYOS_ROOT}/runtime/dnsmasq.conf"
  local ip="" provide_dns="0"
  local domain_base="community.home.arpa"
  local domain_chat="chat.community.home.arpa"
  local domain_ai="ai.community.home.arpa"
  local id domain

  if [[ -f "${COMMUNITYOS_ROOT}/.env" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "${COMMUNITYOS_ROOT}/.env" 2>/dev/null || true
    set +a
    ip="${SERVER_IP:-}"
    provide_dns="${PROVIDE_DNS:-0}"
    domain_base="${DOMAIN_BASE:-$domain_base}"
    domain_chat="${DOMAIN_CHAT:-$domain_chat}"
    domain_ai="${DOMAIN_AI:-$domain_ai}"
  fi
  # Strip optional quotes from env values
  ip="${ip%\'}"; ip="${ip#\'}"
  provide_dns="${provide_dns%\'}"; provide_dns="${provide_dns#\'}"
  domain_base="${domain_base%\'}"; domain_base="${domain_base#\'}"
  domain_chat="${domain_chat%\'}"; domain_chat="${domain_chat#\'}"
  domain_ai="${domain_ai%\'}"; domain_ai="${domain_ai#\'}"

  if [[ -z "${ip}" ]]; then
    return 0
  fi

  mkdir -p "${COMMUNITYOS_ROOT}/runtime"
  {
    echo "# CommunityOS LAN DNS — generated from .env SERVER_IP=${ip}"
    echo "# Do not edit by hand; regenerated on start/restart and app install."
    echo "domain-needed"
    echo "bogus-priv"
    echo "no-resolv"
    echo "server=1.1.1.1"
    echo "server=8.8.8.8"
    echo "address=/${domain_base}/${ip}"
    echo "address=/${domain_chat}/${ip}"
    echo "address=/${domain_ai}/${ip}"
  } > "${conf}"

  if declare -F app_list_ids >/dev/null 2>&1; then
    for id in $(app_list_ids); do
      domain="$(app_meta "${id}" domain 2>/dev/null || true)"
      domain="${domain%\'}"; domain="${domain#\'}"
      [[ -z "${domain}" ]] && continue
      echo "address=/${domain}/${ip}" >> "${conf}"
    done
  else
    {
      echo "address=/library.community.home.arpa/${ip}"
      echo "address=/maps.community.home.arpa/${ip}"
      echo "address=/media.community.home.arpa/${ip}"
      echo "address=/files.community.home.arpa/${ip}"
      echo "address=/stream.community.home.arpa/${ip}"
    } >> "${conf}"
  fi

  # Validate: every address= line must use current SERVER_IP
  if grep -E '^address=/' "${conf}" | grep -vq "/${ip}$"; then
    if declare -F log_warn >/dev/null 2>&1; then
      log_warn "dnsmasq.conf still has records not pointing at ${ip}"
    fi
  fi

  # Reload DNS container if running (and DNS mode enabled)
  if [[ "${provide_dns}" == "1" ]] && docker exec communityos-dns true >/dev/null 2>&1; then
    docker restart communityos-dns >/dev/null 2>&1 || true
  fi
}


