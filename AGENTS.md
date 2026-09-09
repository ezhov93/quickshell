# Repository Guidelines

## Read Before Changing

1. Read `docs/project-context.md` and `docs/architecture.md`.
2. Use `docs/README.md` to locate the relevant OpenSpec capability, its row in `docs/spec-status.md`, testing guidance, and accepted ADRs.
3. For an OpenSpec change, use the CLI status/instructions for that exact change and read every context artifact they list. Do not guess between multiple active changes.
4. Inspect the affected implementation and available checks. A capability may span dependencies, configuration, services, UI, session, and deployment rather than one source directory.
5. Before editing, state the files in scope, behavior that must remain unchanged, and verification. This does not require renewed permission for normal tasks already authorized by the user.

Baseline specs are the current normative contract. A change delta is proposed behavior until synced. Architecture and accepted ADRs explain decisions; `docs/spec-status.md` records evidence and gaps but does not waive requirements. Source code shows implementation and does not automatically override a spec. Roadmaps, examples, and `PLANS.md` are not implementation authorization.

If code, a spec, and the requested work conflict, report the exact conflict. Fix it when the agreed scope resolves it; otherwise stop that branch and request a decision. Do not silently weaken a requirement, preserve an obvious defect as desired behavior, or add roadmap work to the current change.

## Product and Performance

- Product scope is the complete LPDE, but the current installer deploys only the Quickshell QML. Do not claim package/session deployment already exists.
- Target hardware is Intel Celeron N3450 with 6 GB RAM; the current reference system is Arch Linux with Hyprland and systemd-boot. Arch and Debian are targets, not both verified distributions yet.
- Prioritize responsive behavior and low CPU/memory cost. Avoid unnecessary daemons, polling, effects, and dependencies. Prefer reliable event-driven updates.
- Polling requires a provider, reason, interval, consumers, and stop condition. A hidden OSD may still be an active consumer when it must detect an external brightness change.
- A new owned daemon requires an architectural justification covering alternatives, privileges, lifecycle, failures, and resource cost.

## Current Structure and QML Style

- `shell.qml` composes `modules/Bar`, `AppLauncher`, `Notifications`, `Osd`, `Wallpaper`, `MonitorManager`, and `IdleInhibitor` in one Quickshell process.
- Keep module entry files at module roots, reusable UI in `components/`, and feature state/helpers in `services/`. Shared QML services are in root `services/`; they are not system daemons.
- `services/Brightness.qml` shares brightness state between Bar and OSD. Include root `services/` when installing a module that imports `qs.services`.
- Shared settings and palette are `config/Config.qml` and `config/Theme.qml`, imported through `qs.config`. Use theme colors.
- Modules use components and services; reusable components must not depend on their modules. Services may use native Quickshell APIs directly; add an adapter only when it has a concrete responsibility.
- UI may own focus, hover, selection, and uncommitted editor state. Shared system state and system operations belong in a service/controller boundary.
- Use PascalCase for QML files/components and camelCase for properties/functions. Preserve surrounding indentation and avoid unrelated formatting.
- Keep project documentation and OpenSpec prose in Russian. Keep `AGENTS.md` in English and preserve canonical OpenSpec headings required by the validator.

## Running and Validation

There is no build step, automated test framework, or CI yet. Use `docs/testing.md`; report a check as passed, failed, not run, or blocked. A missing environment never counts as a pass.

- `./install.sh` installs without `sudo` into `~/.config/quickshell/` and backs up the previous directory. It does not install packages or Hyprland configuration.
- `quickshell -p "$HOME/.config/quickshell"` runs the installed shell in a prepared Hyprland session.
- Run `openspec validate "<change>" --strict` for a change and `openspec validate --specs --strict` for baseline specs.
- Run `bash -n "install.sh"` when the installer changes. This checks syntax only.
- Run `git diff --check` for tracked edits and separately check newly created untracked files.
- Manually verify changed QML modules for load errors, open/close/reopen, keyboard behavior, theme colors, failure paths, and relevant IPC. Record unavailable runtime checks.

## Safety and Handoff

- Preserve user changes and keep changes scoped. Do not mark a partial or unverified task complete.
- Do not commit runtime state such as `wallpaper.conf` or generated monitor settings.
- Applying monitor settings changes live displays and may overwrite `~/.config/hypr/monitors.conf` or `monitors.lua`; use a controlled session with recovery available.
- Installer tests must not replace the real user's config. Use a separate environment/account or a future explicitly supported destination override.
- PRs and handoffs must state behavior changes (or explicitly say none), checks with their status, known gaps, unavailable dependencies, and screenshots for visible changes.
