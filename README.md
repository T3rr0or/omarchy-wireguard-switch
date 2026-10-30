# WireGuard Switch

An Omarchy bar widget for NetworkManager WireGuard connections.

- The icon shows the active tunnel's name and highlights while one is up.
- Left click opens the Omarchy menu with every WireGuard connection plus **Off**.
- Picking a connection takes any active WireGuard tunnel down first, so two
  full-tunnel configs (`AllowedIPs = 0.0.0.0/0`) are never up at the same time.
- Middle click refreshes.

## Requirements

- NetworkManager (1.16 or newer has WireGuard built in; `wireguard-tools` is not needed)
- Omarchy's shell and `omarchy-menu-select`
- `notify-send` for error messages

No root, no helper, no network access beyond `nmcli`. Everything runs as your
user; NetworkManager's polkit rules decide whether you may bring connections
up and down (an active desktop session normally may).

## Install

```bash
omarchy plugin add https://github.com/T3rr0or/omarchy-wireguard-switch.git --enable
```

## Adding connections

Import a wg-quick config into NetworkManager. The connection is named after the
file, and interface names are limited to 15 characters:

```bash
cp WireGuard-Office.conf office.conf
nmcli connection import type wireguard file office.conf
nmcli connection modify office connection.autoconnect no
nmcli connection down office   # import brings it up right away
```

## Settings

| Key | Default | Meaning |
|-----|---------|---------|
| `intervalSec` | `3` | How often the bar checks the active connection |

## Files

- `BarWidget.qml`: the bar icon and status poll
- `switch.sh`: the picker; also usable from a terminal or a keybinding
