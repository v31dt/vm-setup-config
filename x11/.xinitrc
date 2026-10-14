#!/bin/sh
# ~/.xinitrc — used when starting X with `startx` (no display manager).
[ -f ~/.xprofile ] && . ~/.xprofile
exec i3
