#!/bin/sh
# ~/.xinitrc — used when starting X with `startx` (no display manager).
[ -f ~/.xprofile ] && . ~/.xprofile
# Per-machine X settings (e.g. Xft.dpi for scaling); the repo ships none.
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources
exec i3
