#!/bin/sh
# ~/.config/i3/autoresize.sh — poll fallback for VM host-window resize.
# Applies the hypervisor's preferred mode when it differs from the current
# one, then repaints the wallpaper to fit (feh only draws it once, at
# startup size).
while :; do
    outs=$(xrandr --current | awk '
        / connected/ { out = $1 }
        /\*/         { cur[out] = $1 }
        /\+/         { pref[out] = $1 }
        END { for (o in pref) if (pref[o] != cur[o]) print o }
    ')
    if [ -n "$outs" ]; then
        for out in $outs; do
            xrandr --output "$out" --auto
        done
        feh --no-fehbg --bg-fill ~/.config/i3/wallpaper.jpg 2>/dev/null \
            || xsetroot -solid "#0b1220"
    fi
    sleep 1
done
