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

### 1.3.0
- `update-theme.sh` auto-detects primary monitor geometry via `xrandr`
- New `--monitor <name|primary>` flag for explicit monitor selection
- On single-monitor systems or when xrandr is unavailable: graceful fallback to full screen

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
