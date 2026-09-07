# Repository Guidelines

## Project Structure & Module Organization

`shell.qml` composes the desktop modules using the shared root theme. Feature directories are `Bar/`, `AppLauncher/`, `Notifications/`, `Osd/`, `Wallpaper/`, `MonitorManager/`, and `IdleInhibitor/`. Each has an entry component; all modules import the root theme.

The shared palette lives in the root `DefaultTheme.qml` singleton. There is no dedicated test or bundled image-assets directory. See `README.md` for installation and module dependencies.

## Build, Test, and Development Commands

This configuration runs directly in Quickshell; there is no compilation step or package-manager workflow. Install Quickshell, Qt 6, Hyprland, and a Nerd Font. The documented setup places the repository at `~/.config/quickshell/`; several services explicitly reference that location.

- `./install.sh` — install the configuration with a backup of the previous version.
- `bash -n install.sh` — check installer syntax.
- `quickshell` — start the installed configuration in a Hyprland session.
- `qs ipc call launcher toggle` — exercise the application launcher.
- `qs ipc call monitors refresh` — refresh monitor information.

## Coding Style & Naming Conventions

Use PascalCase QML filenames and component names, camelCase properties/functions, and PascalCase module directories. Match the surrounding indentation: existing QML uses both two and four spaces. Avoid unrelated reformatting; no formatter or linter configuration is checked in.

Keep colors behind the shared theme interface and preserve `property var theme: Shared.DefaultTheme` with `import ".." as Shared` for entry components. Follow the existing separation between UI components and service/helper files. Quote paths in shell commands.

## Testing Guidelines

There is no automated test framework or coverage threshold. Manually exercise changed modules, check runtime output for QML errors, and verify relevant IPC commands. For UI changes, check opening/closing, keyboard interaction, and built-in theme colors. Verify shared theme imports when changing theme integration. Describe checks and unavailable dependencies in the PR.

## Commit & Pull Request Guidelines

History uses short, descriptive subjects such as `fix theme borders with Lua Hyprland`; no strict commit prefix convention is evident. Keep commits focused. PRs should explain the behavior change, link relevant issues, list validation, and include screenshots for visible changes.

## Configuration Hygiene

Do not commit runtime state: `wallpaper.conf` or `monitor-manager.conf`. Monitor actions can update files under `~/.config/hypr/`; account for these side effects during manual testing.
