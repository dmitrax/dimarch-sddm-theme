# dimarch-sddm-theme

Premium frosted-glass SDDM login theme for DimArch OS.

## Features

- Frosted-glass login card with drop shadow
- Real-time clock (top-right)
- User avatar with priority chain: `.face.icon` → `.face` → theme default
- Session selector popup
- Power panel (shutdown / reboot / session)
- Multi-language: English and Russian included
- All visual parameters configurable via `theme.conf`

## Installation

```bash
git clone https://github.com/dmitrax/dimarch-sddm-theme
cd dimarch-sddm-theme
./install.sh
```

The installer auto-detects your system name (`/etc/os-release`) and locale (`$LANG`).

## After system language change

```bash
sudo /usr/share/sddm/themes/dimarch/scripts/update-theme.sh
```

## Manual overrides

```bash
# Set system name explicitly
sudo /usr/share/sddm/themes/dimarch/scripts/update-theme.sh --name "DimArch OS"

# Set locale explicitly
sudo /usr/share/sddm/themes/dimarch/scripts/update-theme.sh --locale ru

# Set login monitor explicitly
sudo /usr/share/sddm/themes/dimarch/scripts/update-theme.sh --monitor DP-1

# All at once
sudo /usr/share/sddm/themes/dimarch/scripts/update-theme.sh --name "DimArch OS" --locale ru --monitor DP-1
```

## Available locales

| Code | Language |
|------|----------|
| `en` | English  |
| `ru` | Русский  |

Add more by dropping a `<code>.conf` file into `locale/`.

## Background

Place your background image at:
```
/usr/share/sddm/themes/dimarch/backgrounds/login-lock.jpg
```

Or change `BgSource` in `theme.conf`.

## Test mode

```bash
sddm-greeter --test-mode --theme /usr/share/sddm/themes/dimarch
```

## Changelog

### 1.3.1
- **Scale fix:** auto thresholds revised — 4K→1.5x, 1440p→1.2x, 1080p→1.0x, <1080p→0.85x
- **UiScale** override in `theme.conf` — set explicitly if auto-detect is wrong
- **SessionPopup:** capped at 5 visible items with proper scrolling for long lists
- **Shadow quality:** `samples = 2 * radius + 1` — smooth, no cutoff artifacts
- **update-theme.sh:** removed xrandr dependency — UI scale detected automatically at SDDM startup via QML

### 1.2.0
- Multi-monitor support: `PrimaryX/Y/Width/Height` in `theme.conf`
- Auto UI scale: 1x at 1080p, 1.5x at 1440p, 2x at 4K — no manual config needed
- All sizes scaled consistently across every component

### 1.1.0
- Localization system: all UI strings moved to `theme.conf`
- Added `locale/en.conf` and `locale/ru.conf`
- `update-theme.sh` replaces `update-system-name.sh` — handles both name and locale
- Auto-detect locale on install via `$LANG` / `/etc/locale.conf`

### 1.0.0
- Initial release
