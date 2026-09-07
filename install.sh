#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == --help || ${1:-} == -h ]]; then
  printf 'Usage: %s\nInstall into ~/.config/quickshell, backing up any existing configuration.\n' "$0"
  exit 0
fi
if (( $# )); then
  printf 'Unknown argument: %s\n' "$1" >&2
  exit 1
fi
if (( EUID == 0 )); then
  printf 'Run this script as your desktop user, without sudo.\n' >&2
  exit 1
fi

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
# Services currently use this path explicitly, regardless of XDG_CONFIG_HOME.
config_dir="$HOME/.config"
target="$config_dir/quickshell"
modules=(Bar AppLauncher Notifications Osd Wallpaper MonitorManager IdleInhibitor)

for file in shell.qml DefaultTheme.qml; do
  [[ -f "$source_dir/$file" ]] || { printf 'Missing source: %s\n' "$file" >&2; exit 1; }
done
for module in "${modules[@]}"; do
  [[ -d "$source_dir/$module" ]] || { printf 'Missing module: %s\n' "$module" >&2; exit 1; }
done

for dependency in quickshell hyprctl; do
  if ! command -v "$dependency" >/dev/null 2>&1; then
    printf 'Required to run the config: %s (not installed).\n' "$dependency" >&2
  fi
done
for dependency in brightnessctl nmcli; do
  command -v "$dependency" >/dev/null 2>&1 || printf 'Optional dependency missing: %s\n' "$dependency"
done
if ! command -v hyprpaper >/dev/null 2>&1 && ! command -v swww >/dev/null 2>&1; then
  printf 'Wallpaper support requires hyprpaper or swww.\n'
fi

mkdir -p -- "$config_dir"
if [[ -d "$target" && "$source_dir" == "$(cd -- "$target" && pwd -P)" ]]; then
  printf 'Configuration is already installed at %s\n' "$target"
  exit 0
fi

stage=$(mktemp -d "$config_dir/.quickshell-install.XXXXXXXX")
backup=""
installed=false
cleanup() {
  if [[ "$installed" == false && -n "$backup" && ! -e "$target" && ! -L "$target" ]]; then
    mv -- "$backup" "$target" || printf 'Restore your backup manually: %s\n' "$backup" >&2
  fi
  [[ ! -d "$stage" ]] || rm -rf -- "$stage"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

cp -- "$source_dir/shell.qml" "$source_dir/DefaultTheme.qml" "$stage/"
for module in "${modules[@]}"; do
  mkdir -- "$stage/$module"
  cp -- "$source_dir/$module/"*.qml "$stage/$module/"
done

if [[ -e "$target" || -L "$target" ]]; then
  backup=$(mktemp -d "$config_dir/quickshell.backup.XXXXXXXX")
  rmdir -- "$backup"
  mv -- "$target" "$backup"
fi
mv -- "$stage" "$target"
installed=true

printf 'Installed: %s\n' "$target"
[[ -z "$backup" ]] || printf 'Previous configuration: %s\n' "$backup"
printf '\nStart in your Hyprland session:\n  quickshell -p "%s"\n' "$target"
printf '\nUse a Nerd Font. Stop dunst/mako before using the notification module.\n'
