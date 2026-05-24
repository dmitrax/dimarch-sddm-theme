#!/usr/bin/env bash
set -euo pipefail

THEME_NAME="dimarch"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DST_DIR="/usr/share/sddm/themes/${THEME_NAME}"

echo "[→] Installing ${THEME_NAME} SDDM theme..."

sudo mkdir -p "$DST_DIR"
sudo rsync -a --delete \
    --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='install.sh' \
    --exclude='*.md' \
    --exclude='**/.gitkeep' \
    "$SRC_DIR/" "$DST_DIR/"
sudo chmod -R a+rX "$DST_DIR"
sudo chmod +x "$DST_DIR/scripts/update-theme.sh"

sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf >/dev/null <<SDDMEOF
[Theme]
Current=${THEME_NAME}
CursorTheme=Bibata-Modern-Classic
CursorSize=24
SDDMEOF

# Auto-detect system name and locale, apply to theme.conf
sudo "$DST_DIR/scripts/update-theme.sh"

echo ""
echo "[✓] Installed: $DST_DIR"
echo ""
echo "[→] Background expected at: $DST_DIR/backgrounds/login-lock.jpg"
echo ""
echo "[→] To update after system changes:"
echo "    sudo $DST_DIR/scripts/update-theme.sh"
echo "    sudo $DST_DIR/scripts/update-theme.sh --name \"DimArch OS\""
echo "    sudo $DST_DIR/scripts/update-theme.sh --locale ru"
echo ""
echo "[→] Test mode: sddm-greeter --test-mode --theme $DST_DIR"
