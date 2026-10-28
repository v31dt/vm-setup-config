#!/bin/sh
# ~/.config/i3/autoresize.sh — poll fallback for VM host-window resize.
#
# Guest agents (spice-vdagent, vmware-user, VBoxClient) are supposed to call
# RandR themselves when the host window resizes, but that depends on their
# own session plumbing (spice-vdagentd socket, vmtoolsd channel, …), which is
# flaky without a full desktop session driving it. i3 has no display daemon
# to fall back on either, so this polls for the mismatch directly: whenever
# an output's *preferred* mode (what the hypervisor just advertised) differs
# from its *current* mode, apply it. No-op — and no flicker — once they match.
while :; do
    xrandr --current | awk '
        / connected/ { out = $1 }
        /\*/         { cur[out] = $1 }
        /\+/         { pref[out] = $1 }
        END { for (o in pref) if (pref[o] != cur[o]) print o }
    ' | while read -r out; do
        xrandr --output "$out" --auto
    done
    sleep 1
done
