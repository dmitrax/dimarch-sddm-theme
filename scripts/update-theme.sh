#!/usr/bin/env bash
# =============================================================================
# DimArch SDDM Theme — update-theme.sh
# Updates SystemName, locale strings and primary monitor geometry in theme.conf
#
# Usage:
#   sudo ./update-theme.sh                          # auto-detect everything
#   sudo ./update-theme.sh --name "DimArch OS"     # set name explicitly
#   sudo ./update-theme.sh --locale ru              # set locale explicitly
#   sudo ./update-theme.sh --monitor DP-1           # set monitor explicitly
#   sudo ./update-theme.sh --monitor primary        # use xrandr primary monitor
#
# After system changes (language, monitors):
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
ARG_MONITOR=""

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
        --monitor)
            ARG_MONITOR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--name <SystemName>] [--locale <en|ru>] [--monitor <name|primary>]" >&2
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

# ── Detect primary monitor via xrandr ─────────────────────────────────────────
#
# xrandr output example:
#   DP-1 connected primary 3840x2160+1920+0 (normal left inverted right x axis y axis) 600mm x 340mm
#   DP-2 connected 1920x1080+0+0 (normal left inverted right x axis y axis) 530mm x 300mm
#
# Geometry format: WxH+X+Y

parse_monitor_geometry() {
    # $1 = monitor name, or "primary" to auto-pick xrandr primary
    local target="$1"
    local xrandr_out

    if ! command -v xrandr &>/dev/null; then
        echo "Warning: xrandr not found — cannot auto-detect monitor geometry." >&2
        return 1
    fi

    xrandr_out=$(xrandr --query 2>/dev/null) || {
        echo "Warning: xrandr failed — display server may not be running." >&2
        return 1
    }

    local line
    if [[ "$target" == "primary" ]]; then
        # Pick the monitor marked as primary by xrandr
        line=$(echo "$xrandr_out" | grep " connected primary " | head -1)
        if [[ -z "$line" ]]; then
            # No primary flag — fall back to first connected monitor
            line=$(echo "$xrandr_out" | grep " connected " | head -1)
        fi
    else
        # Pick by name (e.g. DP-1, HDMI-1)
        line=$(echo "$xrandr_out" | grep "^${target} connected " | head -1)
        if [[ -z "$line" ]]; then
            echo "Warning: monitor '${target}' not found or not connected." >&2
            echo "Connected monitors:" >&2
            echo "$xrandr_out" | grep " connected " | awk '{print "  "$1}' >&2
            return 1
        fi
    fi

    if [[ -z "$line" ]]; then
        echo "Warning: no connected monitor found via xrandr." >&2
        return 1
    fi

    # Extract WxH+X+Y geometry token
    local geo
    geo=$(echo "$line" | grep -oP '\d+x\d+\+\d+\+\d+' | head -1)

    if [[ -z "$geo" ]]; then
        echo "Warning: could not parse geometry from: $line" >&2
        return 1
    fi

    # Parse into components
    local w h x y
    w=$(echo "$geo" | grep -oP '^\d+')
    h=$(echo "$geo" | grep -oP '(?<=x)\d+(?=\+)')
    x=$(echo "$geo" | grep -oP '(?<=\+)\d+' | sed -n '1p')
    y=$(echo "$geo" | grep -oP '(?<=\+)\d+' | sed -n '2p')

    local mon_name
    mon_name=$(echo "$line" | awk '{print $1}')

    echo "${mon_name} ${w} ${h} ${x} ${y}"
    return 0
}

detect_monitor() {
    # Auto-detect: prefer xrandr primary, fall back to 0 (full screen)
    local result
    result=$(parse_monitor_geometry "primary") || {
        echo ""
        return 1
    }
    echo "$result"
}

apply_monitor() {
    local target="$1"   # monitor name or "primary"
    local result

    result=$(parse_monitor_geometry "$target") || return 1

    local mon_name w h x y
    read -r mon_name w h x y <<< "$result"

    patch_key "PrimaryX"      "$x"
    patch_key "PrimaryY"      "$y"
    patch_key "PrimaryWidth"  "$w"
    patch_key "PrimaryHeight" "$h"

    echo "  Monitor     → ${mon_name}  ${w}×${h} at +${x}+${y}"
    return 0
}

# ── Main ──────────────────────────────────────────────────────────────────────

echo "DimArch SDDM Theme — update-theme.sh"
echo "────────────────────────────────────"

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

# Resolve and apply monitor geometry
if [[ -n "$ARG_MONITOR" ]]; then
    # Explicit monitor name or "primary"
    if apply_monitor "$ARG_MONITOR"; then
        :
    else
        echo "  Monitor     → skipped (not found)"
    fi
else
    # Auto-detect via xrandr primary
    if apply_monitor "primary"; then
        :
    else
        echo "  Monitor     → 0,0 auto (xrandr not available or no display)"
    fi
fi

echo ""
echo "Done. Restart SDDM to apply: sudo systemctl restart sddm"
