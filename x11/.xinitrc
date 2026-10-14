#!/bin/sh
# ~/.xinitrc — used when starting X with `startx` (no display manager).
[ -f ~/.xprofile ] && . ~/.xprofile
[ -f ~/.Xresources ] && xrdb -nocpp -merge ~/.Xresources
exec i3
