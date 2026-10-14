#!/bin/sh
# Restartable polybar launcher (called from i3's exec_always).
killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 0.2; done
polybar main >/tmp/polybar.log 2>&1 &
