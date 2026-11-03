#!/bin/sh
# Network interface picker — the same thing Kali's top-bar nm-applet gives
# you: pick a device, flip it on/off. Any device NetworkManager manages
# (ethernet, wifi, ...) shows up here, since a VM is usually plain ethernet,
# not wifi. Talks to nmcli directly — NetworkManager's own CLI, the same
# backend nm-applet itself uses — instead of reinventing per-device
# enable/disable logic (and the sudo/polkit plumbing that needs).
list=$(nmcli -t -f DEVICE,TYPE,STATE device status |
    awk -F: '$3 != "unmanaged" && $2 != "loopback" && $2 != "bridge" && $2 != "tun" && $2 != "wifi-p2p"')
[ -n "$list" ] || exit 0

choice=$(printf '%s\n' "$list" |
    awk -F: '{printf "%-15s %-10s %s\n", $1, $2, $3}' |
    rofi -dmenu -p "network")
[ -n "$choice" ] || exit 0

iface=$(printf '%s' "$choice" | awk '{print $1}')
state=$(printf '%s\n' "$list" | awk -F: -v i="$iface" '$1 == i {print $3}')

case "$state" in
    connected*) nmcli device disconnect "$iface" ;;
    *)          nmcli device connect "$iface" ;;
esac
