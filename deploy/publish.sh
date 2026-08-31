#!/usr/bin/env bash
#
# publish.sh — copy the static site files into a clean dist/ directory
# suitable for Cloudflare Pages (or any static host).
#
# Usage:
#   bash deploy/publish.sh          # writes to ./dist
#
# The script is idempotent: it removes the target directory before copying.
# It copies only: index.html, css/, js/, assets/.
# It does NOT touch Docker, Git, or any credentials.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# dist/ is a generated artifact and is safe to recreate on every build.
DIST_DIR="${ROOT}/dist"

echo "==> Clean output directory: ${DIST_DIR}"
rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}/css" "${DIST_DIR}/js" "${DIST_DIR}/assets"

echo "==> Copying site files..."
cp "${ROOT}/index.html" "${DIST_DIR}/index.html"
cp -r "${ROOT}/css/."      "${DIST_DIR}/css/"
cp -r "${ROOT}/js/."       "${DIST_DIR}/js/"

# assets/ may contain subdirectories (icons, images/…), preserve structure.
cp -r "${ROOT}/assets/."   "${DIST_DIR}/assets/"

# Remove any stray .gitkeep files — Cloudflare Pages should not serve them.
find "${DIST_DIR}" -name '.gitkeep' -delete 2>/dev/null || true

echo "==> Published to ${DIST_DIR}"
echo "    Contents:"
find "${DIST_DIR}" -type f | sed 's|^|      |'
