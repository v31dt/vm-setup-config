# vm-setup-config

Minimal **i3 (X11)** setup for a throwaway pentest / HTB testing VM. Written for
**Kali / Debian (apt)**; an Arch `pacman` line is noted at the end.

Tiling WM + a simple status bar (workspaces · CPU · MEM · VOL · VPN · NET · clock),
`alacritty` terminal, `rofi` launcher, and the env tweak that stops **Ghidra/Burp**
from rendering blank. No idle/lock, night light, pomodoro, or other daily-driver
cruft — just a working tiling desktop.

Ported from a Sway config; keybinds kept approximately the same (`$mod` = Super).

## 1. Install packages

```sh
sudo apt update && sudo apt install -y \
  i3-wm i3status alacritty rofi polybar autotiling \
  xserver-xorg xinit x11-xserver-utils \
  maim xclip xdotool feh \
  fonts-dejavu fonts-jetbrains-mono \
  pulseaudio-utils pavucontrol firefox-esr nautilus
```

Then add the **guest tools for your hypervisor** (host↔guest clipboard +
display auto-resize) — see section 6. In short:

```sh
# QEMU / KVM / SPICE:
sudo apt install -y spice-vdagent
# VMware:
sudo apt install -y open-vm-tools open-vm-tools-desktop
# VirtualBox:
sudo apt install -y virtualbox-guest-x11
```

The i3 autostart launches whichever agent is installed, so the same config
works on all three.

- `x11-xserver-utils` provides `xsetroot` (wallpaper fallback).
- `pulseaudio-utils` gives `pactl` for the volume keys; recent Kali runs
  PipeWire, and `pactl` + the bar's `pulseaudio` module both work with it.
- `firefox-esr` is Kali's Firefox package name (plain `firefox` won't resolve).
- `wmname` (the Java-fallback trick) isn't reliably packaged on Kali — skip it;
  the `_JAVA_AWT_WM_NONREPARENTING=1` env var in `~/.xprofile` does the job on
  its own. If `apt` *does* find it, install it and the i3 `wmname LG3D` line
  becomes a bonus fallback.
- Kali already ships zsh, maim, etc. — `apt` just skips anything present.

**Arch equivalent** (same tools, different names):

```sh
sudo pacman -S --needed i3-wm i3status alacritty rofi polybar autotiling \
  xorg-server xorg-xinit xorg-xsetroot maim xclip xdotool feh wmname \
  ttf-dejavu pulseaudio pavucontrol firefox nautilus
```

## 2. Copy the config files

```sh
# from the repo root
mkdir -p ~/.config/i3 ~/.config/polybar/scripts ~/Pictures

cp i3/config              ~/.config/i3/config
cp polybar/config.ini     ~/.config/polybar/config.ini
cp polybar/launch.sh      ~/.config/polybar/launch.sh
cp polybar/scripts/*.sh   ~/.config/polybar/scripts/
mkdir -p ~/.config/alacritty
cp alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
cp x11/.xprofile          ~/.xprofile
cp x11/.xinitrc           ~/.xinitrc
cp x11/autoresize.sh      ~/.config/i3/autoresize.sh
cp wallpaper.jpg          ~/.config/i3/wallpaper.jpg

chmod +x ~/.config/polybar/launch.sh ~/.config/polybar/scripts/*.sh ~/.config/i3/autoresize.sh
```

Make nautilus the default for opening folders (other apps' "open folder"):

```sh
xdg-mime default org.gnome.Nautilus.desktop inode/directory
```


**Scaling (per machine, optional).** On a high-res display everything is tiny
at the default 96 DPI. Set a DPI for this machine only and every app follows
it: i3, alacritty, rofi, polybar and Firefox read it directly, and
`~/.xprofile` derives the matching settings for GTK (Nautilus), Qt (Wireshark)
and Java (Burp, Ghidra) at login. 144 = 1.5x, 168 = 1.75x, 192 = 2x (GTK can
only scale its UI by whole numbers, so below 192 it just gets bigger text):

```sh
printf 'Xft.dpi: 192\nXcursor.size: 48\n' > ~/.Xresources
```

`~/.xinitrc` loads it on `startx`; display-manager logins load it too. Log out
and back in for it to take effect everywhere. Java will print "Picked up
_JAVA_OPTIONS" on start; that is just this setting being applied.

## 3. Start it

**No display manager (simplest for a VM):**

```sh
startx
```

`~/.xinitrc` sources `~/.xprofile` and launches i3.

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

- **VMware:** `sudo apt install open-vm-tools open-vm-tools-desktop
  xserver-xorg-video-vmware` (guest driver + clipboard/auto-resize).
- QEMU/SPICE: `xserver-xorg-video-qxl spice-vdagent`; VirtualBox:
  `virtualbox-guest-x11`.
- Last resort — force software rendering: `export LIBGL_ALWAYS_SOFTWARE=1` in
  `~/.xprofile`.

**Auto-resize on host window resize.** The guest agent started by `i3/config`
(whichever of spice-vdagent / vmware-user / VBoxClient-all is installed) is
*supposed* to apply the hypervisor's new screen size itself, by calling RandR
directly — that part of it doesn't need GNOME/KDE. In practice, on a bare i3
session that path is flaky (it depends on session plumbing a full desktop
normally sets up: the `spice-vdagentd` socket, the `vmtoolsd` channel, etc.).
`x11/autoresize.sh` is a dependency-free fallback for that: it polls
`xrandr` once a second and, whenever an output's *preferred* mode (what the
hypervisor is currently advertising) differs from its *current* mode, applies
it. It's a no-op — no flicker — once they already match, and it's harmless to
run alongside a working agent. i3's autostart launches it for you; nothing
else to configure.

## Keybinds (`$mod` = Super)

| Key | Action |
|-----|--------|
| `$mod+Return` | terminal (alacritty) |
| `$mod+Space` | launcher (rofi) |
| `$mod+b` | firefox |
| `$mod+e` | file manager (nautilus) |
| `$mod+q` | close window |
| `$mod+Shift+q` | force-kill focused window |
| `$mod+h/j/k/l` / arrows | focus left/down/up/right (pointer follows) |
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
alacritty/alacritty.toml  terminal (dark-blue theme, padding, cursor)
x11/.xprofile             Java-on-tiling fix, login env
x11/.xinitrc              startx entry point
x11/autoresize.sh         VM host-resize fallback (polls RandR)
wallpaper.jpg             desktop wallpaper (metadata stripped)
```
