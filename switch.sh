#!/usr/bin/env bash
# Pick a NetworkManager WireGuard connection. Active tunnels are taken down
# first, so two full-tunnel configs never fight over the default route.
set -u

mapfile -t vpns < <(nmcli -t -f NAME,TYPE connection show | awk -F: '$2 == "wireguard" { print $1 }' | sort)
if [ ${#vpns[@]} -eq 0 ]; then
  notify-send "WireGuard" "No WireGuard connections in NetworkManager. Import one with: nmcli connection import type wireguard file <conf>"
  exit 0
fi

choice=$(omarchy-menu-select WireGuard "${vpns[@]}" Off) || exit 0
[ -n "$choice" ] || exit 0

nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2 == "wireguard" { print $1 }' |
  while IFS= read -r name; do
    [ "$name" = "$choice" ] && continue
    nmcli connection down id "$name" >/dev/null
  done

[ "$choice" = Off ] && exit 0
if ! out=$(nmcli connection up id "$choice" 2>&1); then
  notify-send "WireGuard: $choice failed" "$out"
  exit 1
fi
