# my quickshell config
a personal Hyprland desktop config built with [Quickshell](https://quickshell.outfoxxed.me/). status bar, app launcher, notification daemon, OSD, wallpaper manager, monitor manager, and caffeine toggle. each piece is its own module and works independently, so feel free to grab only the parts you need.

i hope it's helpful as a starting point or reference. if you have questions or ide

as, don't hesitate to open an issue - happy to chat.

<img width="1920" height="111" alt="image" src="https://github.com/user-attachments/assets/06d824ae-cf21-4c78-919c-1604f1c0a2dc" />
<br/>
<img width="405" height="146" alt="image" src="https://github.com/user-attachments/assets/40c9b11a-abf2-4e9b-bf85-ec44ea67d69d" />
<br/>
<img width="601" height="495" alt="image" src="https://github.com/user-attachments/assets/40c46613-dc24-461a-9075-33ffea221716" />


https://github.com/user-attachments/assets/55c47c05-34b6-402c-aea7-42a369b86828


## what's included

| Module | What it does |
|--------|-------------|
| **Bar** | clock, workspaces, active window title, volume, brightness, network, battery, system tray, now-playing indicator |
| **App Launcher** | rofi drun-style application launcher |
| **Notifications** | dunst-style notification daemon with popups |
| **OSD** | on-screen display for volume and brightness changes, auto-hides |
| **Wallpaper Manager** | grid picker for wallpapers, preview, supports hyprpaper and swww |
| **Monitor Manager** | visual `hyprctl` front-end for arranging, scaling, rotating, mirroring, and disabling displays |
| **Caffeine Toggle** | keeps the screen from locking or dimming while it's on - a corner badge you switch on for stretches where you're reading more than typing |

## prerequisites

these are needed regardless of which modules you use:

- [Quickshell](https://quickshell.outfoxxed.me/) + Qt 6
- [Hyprland](https://hyprland.org/)
- a [Nerd Font](https://www.nerdfonts.com/) (i use Hack Nerd Font - swap it in the QML files if you prefer another)

optional, depending on which modules you use:

- `brightnessctl` - for brightness display and control in the bar and OSD
- `nmcli` - for Wi-Fi names in the bar; `ip` (iproute2) detects connections not managed by NetworkManager
- `/sys/class/power_supply/` - for battery info (standard on most laptops)
- `hyprpaper` or `swww` - for the wallpaper manager
- `hyprctl` / Hyprland - for the monitor manager

## installing everything

if you'd like the full setup:

```bash
git clone https://github.com/ezhov93/quickshell.git
cd quickshell
./install.sh
quickshell -p ~/.config/quickshell
```

Run `./install.sh` without sudo. It copies the QML files and shared theme into `~/.config/quickshell/`, backs up an existing configuration as `~/.config/quickshell.backup.*`, and reports missing dependencies. Install dependencies separately. The script does not start the shell or change Hyprland settings. Re-running it creates a fresh backup; running it from the installed directory is a no-op.

## installing individual modules

modules share the root `DefaultTheme.qml` singleton. To install individual modules, also copy `DefaultTheme.qml` into your quickshell config directory, next to `shell.qml`, and keep module folders directly beneath it. Here's how to set up the parts you want.

### bar

the status bar - clock, workspaces, window title, volume, brightness, network, battery, system tray, and a now-playing indicator.

**extra dependencies:** `brightnessctl`, `nmcli`, `/sys/class/power_supply/`

1. copy `Bar/` into your quickshell config directory
2. in your `shell.qml`, add:

```qml
import "Bar"

Bar {}
```

the bar will use its built-in Nordic colors by default. to supply custom colors, pass `theme: yourThemeObject`.

you can also toggle the bar via IPC:
```
qs ipc call bar toggle
```

The right side shows the main keyboard's active layout (for example, `EN` or `RU`), updated on Hyprland layout changes. It requires `hyprctl` and follows the bar theme.

Click the network indicator to open `nmtui` in the default terminal (`x-terminal-emulator`). Install `nmtui` and a terminal; override `Bar.networkSettingsCommand` if needed, for example `["kitty", "nmtui"]`.

### app launcher

a rofi drun-style launcher overlay. searches by name, description, keywords, and categories. keyboard navigation with arrow keys, enter, and escape.

1. copy `AppLauncher/` into your quickshell config directory
2. in your `shell.qml`, add:

```qml
import "AppLauncher"

AppLauncher {}
```

3. bind a key in `hyprland.conf`:

```
bind = SUPER, D, exec, qs ipc call launcher toggle
```

### notifications

a built-in notification daemon - replaces dunst/mako. popups appear in the top-right corner with urgency-based styling and auto-expire timers.

**note:** only one notification daemon can own `org.freedesktop.Notifications` on D-Bus at a time. please stop dunst/mako before using this.

1. copy `Notifications/` into your quickshell config directory
2. in your `shell.qml`, add:

```qml
import "Notifications"

NotificationPopup {}
```

3. optionally bind IPC commands in `hyprland.conf`:

```
bind = SUPER, N, exec, qs ipc call notifications dismiss_all
bind = SUPER SHIFT, N, exec, qs ipc call notifications dnd_toggle
```

features:
- urgency-based accent colors (critical, normal, low)
- app icons for common apps (discord, firefox, spotify, etc.)
- action buttons from the notification
- progress bar showing time until auto-dismiss
- click to dismiss, close button per notification
- max 5 visible notifications at a time
- do not disturb mode

### osd

a vertical pill overlay that appears on the right side of the screen when volume or brightness changes, then auto-hides after 1.5 seconds.

**extra dependencies:** `brightnessctl`

1. copy `Osd/` into your quickshell config directory
2. in your `shell.qml`, add:

```qml
import "Osd"

OSD {}
```

no IPC needed - it reacts automatically to PipeWire volume changes and backlight changes.

### wallpaper manager

a grid-based wallpaper picker that scans `~/Pictures/Wallpapers` and `~/Pictures`. click to apply, right-click to preview. auto-detects swww or hyprpaper as backend. persists current wallpaper to `wallpaper.conf`.

**extra dependencies:** `hyprpaper` or `swww`

1. copy `Wallpaper/` into your quickshell config directory
2. in your `shell.qml`, add:

```qml
import "Wallpaper"

WallpaperManager {}
```

3. bind a key in `hyprland.conf`:

```
bind = SUPER, W, exec, qs ipc call wallpaper toggle
```

### monitor manager

an ARandR-style visual monitor editor for Hyprland. it queries `hyprctl -j monitors all`, draws the current layout, and lets you adjust resolution, scale, rotation, position, mirroring, and enabled state before applying a batched `hyprctl keyword monitor ...` layout. persists across reboots to `~/.config/hypr/monitors.conf`.

1. copy `MonitorManager/` into your quickshell config directory
2. in your `shell.qml`, add:

```qml
import "MonitorManager"

MonitorManager {}
```

3. bind a key in `hyprland.conf`:

```
bind = SUPER, O, exec, qs ipc call monitors toggle
bind = SUPER SHIFT, O, exec, qs ipc call monitors refresh
```

4. add this line to your `hyprland.conf` so your layout is restored on login:

```
source = ~/.config/hypr/monitors.conf
```

features:
- visual layout canvas with drag-to-arrange monitors
- per-output resolution, scale, rotation, position, enable/disable, and mirror controls

### caffeine toggle

a small toggle that keeps the screen from locking or dimming while it's switched on. i added this for the stretches where i'm mostly reading rather than typing (vibe-coding?) - long enough that the lock screen would otherwise kick in when i'd rather it didn't. it shows up as a small badge in the corner only while it's active, so the rest of the time it's out of the way.

no extra dependencies - it wraps Quickshell's own `IdleInhibitor` type, which talks directly to the Wayland `idle-inhibit` protocol Hyprland already supports. nothing external to install or accidentally leave running.

1. copy `IdleInhibitor/` into your quickshell config directory
2. in your `shell.qml`, add:

```qml
import "IdleInhibitor"

CaffeineToggle {}
```

3. bind a key in `hyprland.conf`:

```
bind = SUPER, C, exec, qs ipc call idle toggle
```

features:
- corner badge that fades in only while active, and fades back out a couple seconds after you toggle it
- click the badge to turn it off without reaching for the keybind
- deliberately doesn't persist across restarts - i'd rather re-toggle it once in a while than have a shell crash quietly leave the screen from sleeping forever

## tweaking

- **colors** - edit the root `DefaultTheme.qml` to update all modules, or pass a custom theme object to its entry component.
- **font** - edit the default `font: "Your Font"` at the top of the entry file.
- **layout** - rearrange widgets in `Bar/Bar.qml`.
- **polling rate** - change the interval in `Bar/SystemInfo.qml` (default 2s).
- **extra bar widgets** - CPU, memory, and temperature widgets are already written in `Bar/Bar.qml` but commented out. uncomment them if you'd like them back (requires `top` and `free`; CPU temperature is read directly from `/sys`).
- **adding a module** - create a folder with an entry QML file, add `import ".." as Shared` and `property var theme: Shared.DefaultTheme`, and wire it in `shell.qml`.

## acknowledgments

this wouldn't exist without the wonderful work behind [Quickshell](https://quickshell.outfoxxed.me/), [Hyprland](https://hyprland.org/), and the theme creators:

- [Nordic GTK](https://github.com/EliverLara/Nordic) by EliverLara and the [Nord palette](https://www.nordtheme.com/) - the built-in module colors

thank you all.
