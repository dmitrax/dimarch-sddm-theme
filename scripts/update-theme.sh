#!/usr/bin/env bash
# =============================================================================
# DimArch SDDM Theme — update-theme.sh
# Updates SystemName and/or locale strings in theme.conf
#
# Usage:
#   sudo ./update-theme.sh                          # auto-detect everything
#   sudo ./update-theme.sh --name "DimArch OS"     # set name explicitly
#   sudo ./update-theme.sh --locale ru              # set locale explicitly
#   sudo ./update-theme.sh --name "My OS" --locale en
#
# After system language change:
#   sudo /usr/share/sddm/themes/dimarch/scripts/update-theme.sh
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
    # Escape special sed chars in value
    local escaped
    escaped=$(printf '%s\n' "$value" | sed 's/[[\.*^$()+?{|]/\\&/g')
    sed -i "s|^${key}=.*|${key}=${escaped}|" "$THEME_CONF"
}

# ── Detect SystemName ─────────────────────────────────────────────────────────

detect_system_name() {
    local name=""

    # Try /etc/os-release first
    if [[ -f /etc/os-release ]]; then
        name=$(grep -Po '^PRETTY_NAME="\K[^"]+' /etc/os-release 2>/dev/null || true)
        [[ -z "$name" ]] && \
            name=$(grep -Po '^NAME="\K[^"]+' /etc/os-release 2>/dev/null || true)
    fi

    # Fallback to hostname
    [[ -z "$name" ]] && name=$(hostname 2>/dev/null || echo "Linux")

    echo "$name"
}

# ── Detect locale ─────────────────────────────────────────────────────────────

detect_locale() {
    local lang="${LANG:-}"

    # If LANG is empty, try /etc/locale.conf
    if [[ -z "$lang" && -f /etc/locale.conf ]]; then
        lang=$(grep -Po '^LANG=\K\S+' /etc/locale.conf 2>/dev/null || true)
    fi

    # Map to supported locale code
    if [[ "$lang" == ru_* ]]; then
        echo "ru"
    else
        echo "en"
    fi
}

# ── Apply locale strings from locale/*.conf ───────────────────────────────────

apply_locale() {
    local locale="$1"
    local locale_file="${LOCALE_DIR}/${locale}.conf"

    if [[ ! -f "$locale_file" ]]; then
        echo "Warning: locale file not found: ${locale_file}" >&2
        echo "Available locales: $(ls "${LOCALE_DIR}"/*.conf 2>/dev/null | \
            xargs -n1 basename | sed 's/\.conf//' | tr '\n' ' ')" >&2
        return 1
    fi

    # Read each key=value from locale file (skip comments and empty lines)
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
        # Trim whitespace
        key="${key// /}"
        patch_key "$key" "$value"
    done < <(grep -v '^\s*#' "$locale_file" | grep -v '^\s*$')

    return 0
}

# ── Main ──────────────────────────────────────────────────────────────────────

echo "DimArch SDDM Theme — update-theme.sh"
echo "────────────────────────────────────"

# Resolve name
if [[ -n "$ARG_NAME" ]]; then
    SYSTEM_NAME="$ARG_NAME"
    NAME_SOURCE="argument"
else
    SYSTEM_NAME=$(detect_system_name)
    NAME_SOURCE="auto-detected from /etc/os-release"
fi

# Resolve locale
if [[ -n "$ARG_LOCALE" ]]; then
    LOCALE_CODE="$ARG_LOCALE"
    LOCALE_SOURCE="argument"
else
    LOCALE_CODE=$(detect_locale)
    LOCALE_SOURCE="auto-detected from \$LANG"
fi

# Apply name
patch_key "SystemName" "$SYSTEM_NAME"
echo "  SystemName  → ${SYSTEM_NAME}  (${NAME_SOURCE})"

# Apply locale
if apply_locale "$LOCALE_CODE"; then
    echo "  Locale      → ${LOCALE_CODE}  (${LOCALE_SOURCE})"
else
    echo "  Locale      → skipped (locale file missing)"
fi

echo ""
echo "Done. Restart SDDM to apply: sudo systemctl restart sddm"
