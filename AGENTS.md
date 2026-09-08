# Repository Guidelines

## Structure and Style

- `shell.qml` composes `Bar/`, `AppLauncher/`, `Notifications/`, `Osd/`, `Wallpaper/`, `MonitorManager/`, and `IdleInhibitor/`.
- Keep module entry files at the module root, UI components in `components/`, and data/state/helpers in `services/`.
- `services/BrightnessService.qml` shares brightness state between `Bar` and `Osd`; include the root `services/` directory when installing either module.
- The shared palette is the `DefaultTheme.qml` singleton. Preserve `import"../../themes" as Themes` and `property var theme: Themes.DefaultTheme` in entry components; use theme colors.
- Use PascalCase for QML files and components, camelCase for properties and functions. Preserve surrounding indentation and UI/service separation; avoid unrelated formatting.
- Keep `README.md` in Russian and `AGENTS.md` in English. Document installation, dependencies, and commands in the README, checking them against the code. Quote paths in shell commands.

## Running and Validation

This configuration runs directly in Quickshell, with no build step or automated test framework. Dependencies are listed in `README.md`.

- `./install.sh` — install without `sudo` into `~/.config/quickshell/`, backing up the previous configuration. Some services explicitly use this path.
- `quickshell -p "$HOME/.config/quickshell"` — run the installed configuration in a Hyprland session.
- `bash -n install.sh` — check syntax when changing the installer.
- Manually check changed modules for QML errors, opening/closing, keyboard interaction, theme colors, and relevant IPC commands, such as `qs ipc call launcher toggle` or `qs ipc call monitors refresh`.
- For documentation-only changes, verify against the code and run `git diff --check`.

## Changes and Side Effects

- Preserve existing user changes. Keep commits focused with short, descriptive subjects.
- PRs should explain behavior changes, list checks and unavailable dependencies, and include screenshots for visible changes.
- Do not commit runtime state: `wallpaper.conf` or `monitor-manager.conf`.
- Applying monitor settings changes the live display configuration and may overwrite `~/.config/hypr/monitors.conf` or `monitors.lua`; account for these effects during validation.
