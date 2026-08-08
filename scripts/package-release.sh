#!/usr/bin/env bash
# Build a release ZIP from the current Git (or source) tree.
# Does not modify .git or delete the working tree.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

VERSION="$(tr -d '[:space:]' < VERSION 2>/dev/null || echo "0.0.0")"
NAME="communityos-v${VERSION}"

OUT_DIR="${HOME}/releases"
mkdir -p "${OUT_DIR}" 2>/dev/null || OUT_DIR="${ROOT}/dist"
mkdir -p "${OUT_DIR}"

STAGE="$(mktemp -d)"
cleanup() { rm -rf "${STAGE}"; }
trap cleanup EXIT

mkdir -p "${STAGE}/communityos"
# Copy tree excluding VCS and local-only paths
if command -v git >/dev/null 2>&1 && git -C "${ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "${ROOT}" archive --format=tar HEAD | tar -x -C "${STAGE}/communityos"
else
  # Fallback: rsync-like copy without .git
  tar -C "${ROOT}" \
    --exclude='.git' \
    --exclude='dist' \
    --exclude='*.zip' \
    -cf - . | tar -x -C "${STAGE}/communityos"
fi

# Ensure scripts are executable in the artifact
chmod 755 "${STAGE}/communityos/install.sh" 2>/dev/null || true
chmod 755 "${STAGE}/communityos/bin/communityos" 2>/dev/null || true
chmod 755 "${STAGE}/communityos/scripts/"*.sh 2>/dev/null || true
chmod 755 "${STAGE}/communityos/update.sh" 2>/dev/null || true

ZIP="${OUT_DIR}/${NAME}.zip"
rm -f "${ZIP}"
(cd "${STAGE}" && zip -qr "${ZIP}" communityos)

echo "Created: ${ZIP}"
echo
echo "This archive is for release/testing only."
echo "Do not extract it over a Git working tree (e.g. ~/communityos)."
echo "Extract under ~/releases/ if you need to test the package."
