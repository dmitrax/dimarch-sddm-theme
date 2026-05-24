#!/usr/bin/env bash
# =============================================================================
# DimArch SDDM Theme — update-theme.sh
# Updates SystemName and locale strings in theme.conf.
#
# UI scale is determined automatically at SDDM startup via QML (root.height).
# Monitor geometry (PrimaryX/Y/Width/Height) can be set manually if needed
# for multi-monitor setups — it does NOT require xrandr.
#
# Usage:
#   sudo ./update-theme.sh                          # auto-detect everything
#   sudo ./update-theme.sh --name "DimArch OS"     # set name explicitly
#   sudo ./update-theme.sh --locale ru              # set locale explicitly
#   sudo ./update-theme.sh --name "My OS" --locale en
#
# After system language change:
#   sudo /usr/share/sddm/themes/dimarch/scripts/update-theme.sh
#
# For multi-monitor — set primary monitor manually in theme.conf:
#   PrimaryX=1920
#   PrimaryY=0
#   PrimaryWidth=3840
#   PrimaryHeight=2160
# =============================================================================

set -euo pipefail

# ── Paths ─────────────────────────────────────────────────────────────────────

THEME_DIR="/usr/share/sddm/themes/dimarch"
THEME_CONF="${THEME_DIR}/theme.conf"
LOCALE_DIR="${THEME_DIR}/locale"

# ── Permission check ──────────────────────────────────────────────────────────

if [[ $EUID -ne 0 ]]; then
    echo "Error: this script must be run as root (sudo)." >&2
    exit 1
fi

if [[ ! -f "$THEME_CONF" ]]; then
    echo "Error: theme.conf not found at ${THEME_CONF}" >&2
    echo "Is the theme installed? Run install.sh first." >&2
    exit 1
fi

# ── Argument parsing ──────────────────────────────────────────────────────────

ARG_NAME=""
ARG_LOCALE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)
            ARG_NAME="$2"
            shift 2
            ;;
        --locale)
            ARG_LOCALE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--name <SystemName>] [--locale <en|ru>]" >&2
            exit 1
            ;;
    esac
done

# ── Helper: patch a key=value in theme.conf ───────────────────────────────────

patch_key() {
    local key="$1"
    local value="$2"
    local escaped
    escaped=$(printf '%s\n' "$value" | sed 's/[[\.*^$()+?{|]/\\&/g')
    sed -i "s|^${key}=.*|${key}=${escaped}|" "$THEME_CONF"
}

# ── Detect SystemName ─────────────────────────────────────────────────────────

detect_system_name() {
    local name=""
    if [[ -f /etc/os-release ]]; then
        name=$(grep -Po '^PRETTY_NAME="\K[^"]+' /etc/os-release 2>/dev/null || true)
        [[ -z "$name" ]] && \
            name=$(grep -Po '^NAME="\K[^"]+' /etc/os-release 2>/dev/null || true)
    fi
    [[ -z "$name" ]] && name=$(hostname 2>/dev/null || echo "Linux")
    echo "$name"
}

# ── Detect locale ─────────────────────────────────────────────────────────────

detect_locale() {
    local lang="${LANG:-}"
    if [[ -z "$lang" && -f /etc/locale.conf ]]; then
        lang=$(grep -Po '^LANG=\K\S+' /etc/locale.conf 2>/dev/null || true)
    fi
    if [[ "$lang" == ru_* ]]; then echo "ru"; else echo "en"; fi
}

# ── Apply locale strings ──────────────────────────────────────────────────────

apply_locale() {
    local locale="$1"
    local locale_file="${LOCALE_DIR}/${locale}.conf"

    if [[ ! -f "$locale_file" ]]; then
        echo "Warning: locale file not found: ${locale_file}" >&2
        echo "Available: $(ls "${LOCALE_DIR}"/*.conf 2>/dev/null | \
            xargs -n1 basename | sed 's/\.conf//' | tr '\n' ' ')" >&2
        return 1
    fi

    while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
        key="${key// /}"
        patch_key "$key" "$value"
    done < <(grep -v '^\s*#' "$locale_file" | grep -v '^\s*$')

    return 0
}

# ── Main ──────────────────────────────────────────────────────────────────────

echo "DimArch SDDM Theme — update-theme.sh"
echo "────────────────────────────────────"

# Auto-detect background file (any image in backgrounds/)
BG_DIR="${THEME_DIR}/backgrounds"
BG_FILE=""
for ext in jpg jpeg png webp; do
    if [[ -f "${BG_DIR}/login-lock.${ext}" ]]; then
        BG_FILE="backgrounds/login-lock.${ext}"
        break
    fi
done
if [[ -n "$BG_FILE" ]]; then
    patch_key "BgSource" "$BG_FILE"
    echo "  Background  → ${BG_FILE}"
else
    echo "  Background  → not found in ${BG_DIR} (skipped)"
fi

# Resolve and apply SystemName
if [[ -n "$ARG_NAME" ]]; then
    SYSTEM_NAME="$ARG_NAME"
    NAME_SOURCE="argument"
else
    SYSTEM_NAME=$(detect_system_name)
    NAME_SOURCE="auto-detected from /etc/os-release"
fi
patch_key "SystemName" "$SYSTEM_NAME"
echo "  SystemName  → ${SYSTEM_NAME}  (${NAME_SOURCE})"

# Resolve and apply locale
if [[ -n "$ARG_LOCALE" ]]; then
    LOCALE_CODE="$ARG_LOCALE"
    LOCALE_SOURCE="argument"
else
    LOCALE_CODE=$(detect_locale)
    LOCALE_SOURCE="auto-detected from \$LANG"
fi
if apply_locale "$LOCALE_CODE"; then
    echo "  Locale      → ${LOCALE_CODE}  (${LOCALE_SOURCE})"
else
    echo "  Locale      → skipped"
fi

echo ""
echo "  UI scale and monitor geometry are detected automatically at SDDM startup."
echo "  To override, edit theme.conf manually:"
echo "    UiScale=1.5         # explicit scale (0 = auto)"
echo "    PrimaryX=1920       # for multi-monitor setups"
echo "    PrimaryWidth=3840"
echo "    PrimaryHeight=2160"
echo ""
echo "Done. Restart SDDM to apply: sudo systemctl restart sddm"
