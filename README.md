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

# Both at once
sudo /usr/share/sddm/themes/dimarch/scripts/update-theme.sh --name "DimArch OS" --locale en
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

### 1.1.0
- Localization system: all UI strings moved to `theme.conf`
- Added `locale/en.conf` and `locale/ru.conf`
- `update-theme.sh` replaces `update-system-name.sh` — handles both name and locale
- Auto-detect locale on install via `$LANG` / `/etc/locale.conf`

### 1.0.0
- Initial release
