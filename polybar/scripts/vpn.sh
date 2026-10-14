#!/bin/sh
# HTB/OpenVPN tunnel IP when a tun/tap interface is up; "VPN off" otherwise.
for dev in tun0 tun1 tap0; do
    ip=$(ip -4 addr show "$dev" 2>/dev/null | awk '/inet /{print $2; exit}' | cut -d/ -f1)
    [ -n "$ip" ] && { echo "VPN $ip"; exit 0; }
done
echo "VPN off"
