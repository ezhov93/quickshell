# Project Context — Custom Desktop Environment

## Goal

We are building a **custom Desktop Environment (DE)**, but not from scratch.

The project assembles a complete desktop experience from existing Linux components and adds our own configuration, Quickshell-based shell, integrations, and potentially a few custom services.

Primary target environments:

- Arch Linux
- Debian

Main compositor and shell stack:

- Hyprland
- Quickshell

The DE should be lightweight and suitable for low-end hardware.

---

# Project Ownership Model

The project does **not** own or reimplement external components such as:

- Hyprland
- Quickshell runtime
- PipeWire
- WirePlumber
- NetworkManager
- BlueZ
- UPower
- systemd
- xdg-desktop-portal
- polkit

These are external dependencies provided by the distribution.

The project **does own**:

- system configuration;
- application configuration;
- Hyprland configuration;
- Quickshell QML code;
- shell UI/UX;
- integration adapters;
- package dependency declarations;
- systemd units created specifically for this DE;
- custom D-Bus contracts;
- custom daemons/services if needed;
- installer/deployment logic;
- specifications describing expected DE behavior.

Conceptually:

```text
Custom DE
=
distribution packages
+ system configuration
+ application configuration
+ Hyprland configuration
+ custom Quickshell shell
+ integrations
+ optional custom services
+ unified UX
```

---

# Main Architectural Principle

Treat the **Desktop Environment as the product**.

Hyprland and Quickshell are implementation components of the DE, not the boundaries of the project.

The repository therefore contains both:

1. machine/system configuration;
2. the custom shell implementation.

The project should not be treated merely as:

- a Quickshell project;
- a Hyprland config;
- a dotfiles repository.

It is a reproducible definition of the complete desktop environment.

---

# Repository Architecture

```text
my-de/
├── README.md
├── AGENTS.md
│
├── specs/
│   ├── product.md
│   ├── architecture.md
│   ├── dependencies.md
│   │
│   ├── features/
│   │   ├── audio/
│   │   │   ├── spec.md
│   │   │   ├── plan.md
│   │   │   └── tasks.md
│   │   ├── network/
│   │   ├── bluetooth/
│   │   ├── brightness/
│   │   ├── notifications/
│   │   ├── launcher/
│   │   └── power/
│   │
│   ├── shell/
│   │   ├── architecture.md
│   │   ├── bar.md
│   │   ├── quick-settings.md
│   │   └── desktop.md
│   │
│   ├── system/
│   │   ├── session.md
│   │   ├── packages.md
│   │   ├── applications.md
│   │   ├── theming.md
│   │   └── power-management.md
│   │
│   └── integrations/
│       ├── hyprland.md
│       ├── pipewire.md
│       ├── networkmanager.md
│       ├── bluez.md
│       ├── systemd.md
│       └── upower.md
│
├── packages/
│   ├── common.yaml
│   ├── arch.yaml
│   └── debian.yaml
│
├── configs/
│   ├── hyprland/
│   │   ├── hyprland.conf
│   │   ├── monitors.conf
│   │   ├── input.conf
│   │   ├── keybinds.conf
│   │   └── rules.conf
│   │
│   ├── quickshell/
│   │   ├── shell.qml
│   │   ├── GlobalStates.qml
│   │   │
│   │   ├── components/
│   │   │   ├── buttons/
│   │   │   ├── popups/
│   │   │   └── controls/
│   │   │
│   │   ├── modules/
│   │   │   ├── bar/
│   │   │   ├── launcher/
│   │   │   ├── notifications/
│   │   │   ├── quick-settings/
│   │   │   ├── workspaces/
│   │   │   └── wallpaper/
│   │   │
│   │   ├── services/
│   │   │   ├── Audio.qml
│   │   │   ├── Network.qml
│   │   │   ├── Bluetooth.qml
│   │   │   ├── Power.qml
│   │   │   └── Hyprland.qml
│   │   │
│   │   ├── integrations/
│   │   │   ├── pipewire/
│   │   │   ├── networkmanager/
│   │   │   ├── bluez/
│   │   │   ├── systemd/
│   │   │   └── hyprland/
│   │   │
│   │   ├── assets/
│   │   └── settings/
│   │
│   ├── foot/
│   ├── chromium/
│   ├── gtk/
│   ├── qt/
│   ├── mime/
│   └── fontconfig/
│
├── system/
│   ├── systemd/
│   │   ├── user/
│   │   └── system/
│   │
│   ├── environment/
│   ├── session/
│   ├── polkit/
│   ├── portals/
│   ├── udev/
│   └── tmpfiles/
│
├── services/
│   ├── taskd/
│   │   ├── src/
│   │   ├── dbus/
│   │   ├── systemd/
│   │   └── README.md
│   └── ...
│
├── shared/
│   ├── dbus/
│   └── schemas/
│
├── install/
│   ├── bootstrap.sh
│   ├── deploy.sh
│   ├── uninstall.sh
│   ├── arch/
│   └── debian/
│
├── tests/
│   ├── shell/
│   ├── integrations/
│   ├── services/
│   └── system/
│
└── scripts/
    ├── check-deps.sh
    ├── diagnose.sh
    └── format.sh
```

---

# Directory Responsibilities

## `specs/`

Contains the Spec-Driven Development layer.

Specifications describe **what the DE should do**, not where implementation files live.

A feature specification may affect several areas of the repository.

Example:

```text
specs/features/bluetooth/spec.md
```

may require changes to:

```text
packages/
configs/quickshell/modules/quick-settings/
configs/quickshell/services/
configs/quickshell/integrations/bluez/
system/systemd/
```

Therefore:

```text
feature != directory
```

A feature is a capability of the DE.

---

## `packages/`

Contains external dependency declarations.

Example responsibilities:

- required packages;
- optional packages;
- development dependencies;
- hardware-specific dependencies;
- distribution-specific package names.

Example:

```yaml
audio:
  arch:
    - pipewire
    - pipewire-pulse
    - wireplumber

  debian:
    - pipewire
    - pipewire-pulse
    - wireplumber
```

External packages themselves are never stored here.

---

## `configs/`

Contains configuration controlled by this project.

Examples:

```text
configs/hyprland/
configs/foot/
configs/chromium/
configs/gtk/
configs/qt/
```

Quickshell also lives here because the runtime loads the shell as configuration, even though the QML code can become a substantial software project.

---

# Quickshell Architecture

Recommended internal dependency direction:

```text
components
    ↓
modules
    ↓
services
    ↓
integrations
    ↓
external system APIs
```

## `components/`

Reusable visual primitives.

Examples:

- buttons;
- sliders;
- popups;
- controls;
- containers.

They should not directly interact with system binaries or D-Bus.

---

## `modules/`

User-facing shell features.

Examples:

- bar;
- launcher;
- notifications;
- quick settings;
- workspaces;
- wallpaper;
- lock/logout UI.

Modules should consume services rather than execute system commands directly.

---

## `services/`

Domain-facing state/API used by UI.

Examples:

```text
Audio.qml
Network.qml
Bluetooth.qml
Power.qml
Hyprland.qml
```

A UI module should ideally depend on an abstraction such as:

```text
AudioService
```

rather than directly depending on PipeWire internals.

---

## `integrations/`

Adapters to external APIs/providers.

Examples:

```text
PipeWire
NetworkManager
BlueZ
UPower
systemd
Hyprland IPC
```

Architecture:

```text
QuickSettings.qml
        ↓
Bluetooth service
        ↓
BlueZ integration
        ↓
org.bluez D-Bus API
```

---

# Quickshell Architectural Constraints

Preferred project-wide rules:

```text
- UI components MUST NOT execute shell commands directly.
- System interaction SHOULD go through services/integration adapters.
- Business/state logic SHOULD NOT live inside visual components.
- Prefer event-driven APIs over polling.
- Prefer native APIs, IPC, or D-Bus over spawning shell commands.
- Avoid unnecessary long-running background processes.
- New custom daemons require explicit justification.
- External implementation details should not leak into UI code.
```

For low-end hardware, minimizing polling and background processes is especially important.

---

# `system/`

Contains configuration of the operating system/session itself.

Examples:

- systemd units;
- environment variables;
- session initialization;
- polkit;
- portals;
- udev;
- tmpfiles;
- login/session behavior.

This differs from `configs/`, which primarily contains configuration for applications.

---

# `services/`

Contains only **custom software owned by this project**.

Examples:

```text
services/taskd/
services/hardware-helper/
```

Do not place external daemons here.

These are dependencies instead:

```text
NetworkManager
PipeWire
BlueZ
UPower
```

A custom service may expose D-Bus APIs and run under `systemd --user` or system-level systemd if required.

---

# `shared/`

Contains contracts shared between custom components.

Especially useful for D-Bus interfaces:

```text
shared/dbus/org.example.Tasks.xml
```

The same interface definition can then be consumed by:

- custom daemon;
- Quickshell;
- tests;
- generated bindings.

---

# `install/`

Responsible for bringing a machine to the desired DE state.

Typical flow:

```text
bootstrap
    ↓
install dependencies
    ↓
deploy configs
    ↓
install custom services
    ↓
configure system/session
    ↓
enable required systemd units
```

Arch/Debian differences should primarily be isolated here and in `packages/`.

Avoid distribution checks scattered throughout unrelated project files.

---

# SDD Model

The DE should be developed through feature-oriented specifications.

Typical lifecycle:

```text
idea
 ↓
spec.md
 ↓
plan.md
 ↓
tasks.md
 ↓
implementation
 ↓
verification
```

Example:

```text
specs/features/audio/
├── spec.md
├── plan.md
└── tasks.md
```

The feature may then modify:

```text
packages/arch.yaml
packages/debian.yaml

configs/quickshell/modules/quick-settings/
configs/quickshell/services/Audio.qml
configs/quickshell/integrations/pipewire/

system/environment/
```

The specification represents the **capability**, not a source directory.

---

# Specification Levels

Recommended hierarchy:

```text
product.md
    ↓
architecture.md
    ↓
feature / system / integration specifications
    ↓
implementation
```

## `product.md`

Defines what the DE is.

Examples:

- target users;
- supported distributions;
- target hardware;
- UX principles;
- performance goals;
- major capabilities.

## `architecture.md`

Defines global technical rules.

Examples:

- dependency directions;
- Quickshell architecture;
- D-Bus usage;
- process model;
- system/service boundaries;
- distribution abstraction rules.

## Feature specs

Describe user-visible capabilities.

Examples:

- audio;
- Wi-Fi;
- Bluetooth;
- launcher;
- notifications;
- brightness;
- power management.

## System specs

Describe desired machine/session behavior.

Examples:

- installed package capabilities;
- session startup;
- default applications;
- theming;
- power policy.

## Integration specs

Describe contracts with external systems.

Examples:

- NetworkManager D-Bus;
- BlueZ D-Bus;
- PipeWire;
- UPower;
- Hyprland IPC;
- systemd.

---

# Important Distinction: Specification vs Desired State

Specifications should describe intent and behavioral requirements.

Example specification:

```text
The audio subsystem must:
- expose current volume and mute state to the shell;
- allow changing volume;
- react to state changes without polling;
- support PulseAudio-compatible applications.
```

Implementation may currently be:

```text
PipeWire + WirePlumber
```

The product requirement should not unnecessarily hard-code the implementation.

Package/configuration declarations are the desired-state implementation of that specification.

---

# Example Feature: Bluetooth

Conceptually:

```text
Bluetooth feature
        ↓
package dependency: bluez
        ↓
bluetooth system service
        ↓
BlueZ D-Bus API
        ↓
Quickshell integration adapter
        ↓
Bluetooth service abstraction
        ↓
Quick Settings UI
```

A single feature can therefore span packages, system configuration, integration, services, and UI.

---

# Example Feature: Audio

```text
Audio feature
     ↓
PipeWire + WirePlumber packages
     ↓
system/session configuration
     ↓
PipeWire integration
     ↓
Audio service
     ↓
volume widget / quick settings
```

Again, the feature specification is not tied one-to-one to any directory.

---

# External Dependencies vs Owned Code

## External dependencies

Provided primarily through Arch/Debian packages:

```text
Hyprland
Quickshell
PipeWire
WirePlumber
NetworkManager
BlueZ
UPower
systemd
xdg-desktop-portal
polkit
```

## Configuration owned by this project

```text
Hyprland configs
application configs
systemd configuration
environment configuration
session configuration
package manifests
```

## Software owned by this project

```text
Quickshell QML
integration adapters
custom services/daemons
custom D-Bus contracts
installer/deployment tooling
```

---

# Relation to end-4 / dots-hyprland

The project has some conceptual similarity to `end-4/dots-hyprland`:

- one repository represents the desktop setup;
- Quickshell is only one part of the complete system;
- application/system configs belong in the same overall project;
- dependencies and installation mechanics are part of the desktop project.

However, this project should add a stronger architectural/SDD layer:

```text
specifications
+
dependency declarations
+
configs
+
owned software
+
deployment
```

Do not blindly copy the end-4 directory layout.

The important idea borrowed from that project is that the desktop is managed as a whole rather than treating Quickshell in isolation.

---

# Design Priorities

Primary priorities:

1. Lightweight runtime.
2. Low idle resource usage.
3. Minimal unnecessary daemons.
4. Event-driven state updates where possible.
5. Clean boundaries between UI and system integration.
6. Reproducible installation.
7. Arch and Debian support where practical.
8. Declarative configuration instead of ad-hoc root shell scripts.
9. Ability to evolve individual external dependencies without rewriting the whole shell.
10. Specs should describe DE capabilities rather than implementation file locations.

---

# Agent Guidance

When implementing changes:

1. Read `specs/product.md`.
2. Read `specs/architecture.md`.
3. Locate the relevant feature/system/integration spec.
4. Do not assume a feature maps to one directory.
5. Identify all affected layers:
   - dependencies;
   - system;
   - config;
   - integration;
   - service;
   - UI.
6. Prefer native APIs, IPC, and D-Bus over shell command execution.
7. Avoid polling unless no event-driven mechanism exists.
8. Do not introduce a new daemon unless there is a clear architectural reason.
9. Keep Arch/Debian-specific logic isolated.
10. Update specifications when behavior or contracts change.

Before implementation, produce a plan and explicit task list for non-trivial features.

---

# Short Mental Model

```text
                  Custom Desktop Environment
                            │
         ┌──────────────────┼──────────────────┐
         │                  │                  │
   Dependencies       Configuration       Owned software
         │                  │                  │
 Arch / Debian         Hyprland/etc.       Quickshell
    packages             system config      services
         │                  │               integrations
         └──────────────────┼──────────────────┘
                            │
                            ▼
                     Unified desktop UX
```

The repository is the reproducible source of truth for this complete desktop environment.
