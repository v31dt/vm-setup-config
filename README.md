# vm-setup-config

Minimal **i3 (X11)** setup for a throwaway pentest / HTB testing VM on Arch.

Tiling WM + a simple status bar (workspaces · CPU · MEM · VOL · VPN · NET · clock),
`urxvt` terminal, `rofi` launcher, and the env tweak that stops **Ghidra/Burp**
from rendering blank. No idle/lock, night light, pomodoro, or other daily-driver
cruft — just a working tiling desktop.

Ported from a Sway config; keybinds kept approximately the same (`$mod` = Super).

## 1. Install packages

```sh
sudo pacman -S --needed \
  i3-wm i3status rxvt-unicode rofi polybar \
  xorg-server xorg-xinit xorg-xsetroot xorg-xrdb \
  maim xclip xdotool wmname \
  ttf-dejavu ttf-jetbrains-mono-nerd \
  pulseaudio-alsa pavucontrol firefox
```

- `pulseaudio-alsa` → if your VM uses PipeWire instead, swap for
  `pipewire-pulse` (the bar's `pulseaudio` module and `pactl` keys work with
  either).
- `ttf-jetbrains-mono-nerd` is the urxvt font; drop it and the `URxvt.font`
  line falls back to DejaVu.

## 2. Copy the config files

```sh
# from the repo root
mkdir -p ~/.config/i3 ~/.config/polybar/scripts ~/Pictures

cp i3/config              ~/.config/i3/config
cp polybar/config.ini     ~/.config/polybar/config.ini
cp polybar/launch.sh      ~/.config/polybar/launch.sh
cp polybar/scripts/*.sh   ~/.config/polybar/scripts/
cp x11/Xresources         ~/.Xresources
cp x11/.xprofile          ~/.xprofile
cp x11/.xinitrc           ~/.xinitrc

chmod +x ~/.config/polybar/launch.sh ~/.config/polybar/scripts/*.sh
```

## 3. Start it

**No display manager (simplest for a VM):**

```sh
startx
```

`~/.xinitrc` sources `~/.xprofile`, merges `~/.Xresources`, and launches i3.

**With a display manager** (e.g. `ly`, `lightdm`): pick the **i3** session at
login. Display managers source `~/.xprofile` automatically.

## 4. Ghidra / Burp (Java/Swing) — the blank-window fix

Java GUI apps show a grey/blank window on tiling WMs. This is handled two ways,
you don't need to do anything:

- `~/.xprofile` exports `_JAVA_AWT_WM_NONREPARENTING=1`
- `i3/config` runs `wmname LG3D` as a fallback

If a Java app *still* renders blank, run it once with:

```sh
_JAVA_AWT_WM_NONREPARENTING=1 ./ghidraRun
```

(Burp's installer-bundled JRE obeys the same var.)

## 5. VM graphics note

If i3/X won't start or the cursor is invisible under the VM's virtual GPU, these
usually fix it (hypervisor-dependent):

- Install the guest driver: `xf86-video-qxl` (QEMU/SPICE) or
  `virtualbox-guest-utils` (VirtualBox).
- Or force software rendering: `export LIBGL_ALWAYS_SOFTWARE=1` in `~/.xprofile`.

## Keybinds (`$mod` = Super)

| Key | Action |
|-----|--------|
| `$mod+Return` | terminal (urxvt) |
| `$mod+Space` | launcher (rofi) |
| `$mod+b` | firefox |
| `$mod+q` | close window |
| `$mod+Shift+q` | force-kill focused window |
| `$mod+h/j/k/l` / arrows | focus left/down/up/right |
| `$mod+Shift+h/j/k/l` | move window |
| `$mod+Ctrl+h/j/k/l` | resize (40px steps) |
| `$mod+1..9` | switch workspace |
| `$mod+Shift+1..9` | move window to workspace & follow |
| `$mod+f` | fullscreen |
| `$mod+Shift+f` | toggle floating |
| `$mod+p` | toggle split direction |
| `$mod` + drag | move (L) / resize (R) a float |
| `Print` / `$mod+Print` | screenshot region / full → clipboard + `~/Pictures` |
| `$mod+Shift+c` / `$mod+Shift+r` | reload / restart i3 |
| `$mod+Shift+e` | exit i3 |

Note: `l` is **focus-right** here (on the laptop it was lock — not needed on a VM).

## Files

```
i3/config                 i3 window manager + keybinds
polybar/config.ini        bar layout and modules
polybar/launch.sh         restartable bar launcher
polybar/scripts/ip.sh     primary IPv4 (NET module)
polybar/scripts/vpn.sh    tun0/tap0 IP (VPN module)
x11/Xresources            urxvt (font, dark-blue theme, clipboard)
x11/.xprofile             Java-on-tiling fix, login env
x11/.xinitrc              startx entry point
```
