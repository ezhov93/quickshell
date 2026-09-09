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
config_dir="$HOME/.config"
target="$config_dir/quickshell"

# Проверка зависимостей
for dependency in quickshell hyprctl; do
  if ! command -v "$dependency" >/dev/null 2>&1; then
    printf 'Required to run the config: %s (not installed).\n' "$dependency" >&2
  fi
done

for dependency in brightnessctl NetworkManager upower ip nmtui; do
  command -v "$dependency" >/dev/null 2>&1 || printf 'Optional dependency missing: %s\n' "$dependency"
done

if ! command -v hyprpaper >/dev/null 2>&1; then
  printf 'Wallpaper support requires hyprpaper 0.8 or newer.\n'
fi

mkdir -p -- "$config_dir"

# Проверка, не установлена ли уже эта же конфигурация
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

printf 'Requires Quickshell 0.3.1+ with Networking, UPower, PipeWire and Qt.labs.folderlistmodel.\n'

# Находим и копируем QML-файлы и описатели локальных модулей, сохраняя структуру
echo "Copying QML files and qmldir manifests from $source_dir..."
find "$source_dir" -type f \( -name '*.qml' -o -name 'qmldir' \) -print0 | while IFS= read -r -d '' file; do
  relative="${file#"$source_dir/"}"
  dest="$stage/$relative"
  mkdir -p -- "$(dirname -- "$dest")"
  cp -- "$file" "$dest"
  echo "  Copied: $relative"
done

# Проверяем, найдены ли какие-либо QML-файлы
if [[ -z "$(find "$source_dir" -type f -name '*.qml' -print -quit)" ]]; then
  echo "Warning: No QML files found in $source_dir" >&2
fi

# Бэкап существующей конфигурации
if [[ -e "$target" || -L "$target" ]]; then
  backup=$(mktemp -d "$config_dir/quickshell.backup.XXXXXXXX")
  rmdir -- "$backup"
  mv -- "$target" "$backup"
  echo "Backup created: $backup"
fi

# Устанавливаем новую конфигурацию
mv -- "$stage" "$target"
installed=true

printf 'Installed: %s\n' "$target"
[[ -z "$backup" ]] || printf 'Previous configuration: %s\n' "$backup"
printf '\nStart in your Hyprland session:\n  quickshell -p "%s"\n' "$target"
printf '\nUse a Nerd Font. Stop dunst/mako before using the notification module.\n'

# Показываем, что было установлено
qml_count=$(find "$target" -type f -name '*.qml' | wc -l)
qmldir_count=$(find "$target" -type f -name qmldir | wc -l)
printf '\nInstalled %d QML files and %d qmldir manifests\n' "$qml_count" "$qmldir_count"
