# dimarch-sddm-theme

Premium frosted-glass SDDM login theme for DimArch OS.

## Features

- Frosted-glass login card with drop shadow
- Real-time clock (top-right)
- User avatar with priority chain: `.face.icon` → `.face` → `ThemeAvatar` if configured → `DA` fallback
- Session selector popup (capped at 5 visible items, scrollable)
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

# Both at once
sudo /usr/share/sddm/themes/dimarch/scripts/update-theme.sh --name "DimArch OS" --locale ru
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

## UI Scale

UI scale is detected automatically at SDDM startup based on monitor height:

| Resolution | Scale |
|------------|-------|
| 4K (≥2160) | 1.5x  |
| 1440p      | 1.2x  |
| 1080p      | 1.0x  |
| <1080p     | 0.85x |

To override, set `UiScale` in `theme.conf`:
```ini
UiScale=1.3
```

## Multi-monitor

The theme exposes `PrimaryX`, `PrimaryY`, `PrimaryWidth` and `PrimaryHeight` in `theme.conf`,
but these options are experimental.

SDDM may create a separate greeter view per monitor, so global monitor coordinates
may behave differently depending on the backend and display setup.

Recommended default — leave at `0` unless you have tested your exact SDDM monitor mapping:
```ini
PrimaryX=0
PrimaryY=0
PrimaryWidth=0
PrimaryHeight=0
```

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
- **update-theme.sh:** removed xrandr dependency — UI scale detected automatically at SDDM startup
- **install.sh:** excluded `.git`, `install.sh`, `.gitkeep` and docs from theme installation

### 1.2.0
- Multi-monitor support: `PrimaryX/Y/Width/Height` in `theme.conf`
- Auto UI scale based on monitor height
- All sizes scaled consistently across every component

### 1.1.0
- Localization system: all UI strings moved to `theme.conf`
- Added `locale/en.conf` and `locale/ru.conf`
- `update-theme.sh` replaces `update-system-name.sh` — handles both name and locale
- Auto-detect locale on install via `$LANG` / `/etc/locale.conf`

### 1.0.0
- Initial release
