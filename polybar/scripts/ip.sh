#!/bin/sh
# Primary non-loopback IPv4 — the VM's reachable address.
ip=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
[ -z "$ip" ] && ip=$(hostname -I 2>/dev/null | awk '{print $1}')
[ -n "$ip" ] && echo "NET $ip" || echo "NET down"
