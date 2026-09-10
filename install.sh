#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == --help || ${1:-} == -h ]]; then
  printf 'Usage: %s\nInstall shell into ~/.config/quickshell and configs/ into ~/.config/, backing up managed paths.\n' "$0"
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
runtime_source="$source_dir/shell"
configs_source="$source_dir/configs"
config_dir="$HOME/.config"
target="$config_dir/quickshell"

runtime_directories=(config components services modules)
required_sources=(
  shell.qml
  qmldir
  config/qmldir
  components/qmldir
  services/qmldir
  modules/qmldir
)

check_dependencies() {
  local dependency

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
}

# Проверка, не установлена ли уже эта же конфигурация.
if [[ -d "$target" && "$source_dir" == "$(cd -- "$target" && pwd -P)" ]]; then
  printf 'Configuration is already installed at %s\n' "$target"
  exit 0
fi

validate_source_tree() {
  local relative

  for relative in "${required_sources[@]}"; do
    if [[ ! -f "$runtime_source/$relative" ]]; then
      printf 'Required shell source is missing: %s\n' "$relative" >&2
      return 1
    fi
  done

  if [[ ! -d "$configs_source" ]]; then
    printf 'Required configs source is missing: %s\n' "$configs_source" >&2
    return 1
  fi

  if ! find "$configs_source" -type f -print -quit | grep -q .; then
    printf 'Configs source is empty: %s\n' "$configs_source" >&2
    return 1
  fi

  while IFS= read -r -d '' relative; do
    relative=${relative#"$configs_source/"}
    case "$relative" in
      wallpaper.conf|*.state|*.cache)
        printf 'Runtime state is not allowed in configs source: %s\n' "$relative" >&2
        return 1
        ;;
    esac
  done < <(find "$configs_source" -type f -print0)

  while IFS= read -r -d '' relative; do
    relative=${relative#"$configs_source/"}
    if [[ "$relative" == quickshell ]]; then
      printf 'The configs source cannot manage reserved path: %s\n' "$relative" >&2
      return 1
    fi
  done < <(find "$configs_source" -mindepth 1 -maxdepth 1 -printf '%p\0')
}

copy_runtime_file() {
  local relative=$1
  local destination="$stage/quickshell/$relative"

  mkdir -p -- "$(dirname -- "$destination")"
  cp -- "$runtime_source/$relative" "$destination"
  printf '  Copied: %s\n' "$relative"
}

copy_runtime_tree() {
  local runtime_directory
  local file

  copy_runtime_file shell.qml
  copy_runtime_file qmldir
  for runtime_directory in "${runtime_directories[@]}"; do
    while IFS= read -r -d '' file; do
      copy_runtime_file "${file#"$runtime_source/"}"
    done < <(find "$runtime_source/$runtime_directory" -type f \( -name '*.qml' -o -name 'qmldir' \) -print0)
  done
}

copy_configs_tree() {
  local file
  local relative
  local destination

  while IFS= read -r -d '' file; do
    relative=${file#"$configs_source/"}
    destination="$stage/configs/$relative"
    mkdir -p -- "$(dirname -- "$destination")"
    cp -- "$file" "$destination"
    printf '  Copied config: %s\n' "$relative"
  done < <(find "$configs_source" -type f -print0)
}

check_dependencies
validate_source_tree

mapfile -t config_entries < <(find "$configs_source" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort)

mkdir -p -- "$config_dir"

stage=$(mktemp -d "$config_dir/.lpde-install.XXXXXXXX")
backup=""
installed=false
backup_sources=()
backup_targets=()
installed_targets=()

cleanup() {
  local index
  local restore_target

  if [[ "$installed" == false ]]; then
    for restore_target in "${installed_targets[@]}"; do
      if [[ -e "$restore_target" || -L "$restore_target" ]]; then
        rm -rf -- "$restore_target"
      fi
    done

    for ((index=${#backup_targets[@]} - 1; index >= 0; index--)); do
      if [[ -e "${backup_sources[index]}" || -L "${backup_sources[index]}" ]] &&
         [[ ! -e "${backup_targets[index]}" && ! -L "${backup_targets[index]}" ]]; then
        mkdir -p -- "$(dirname -- "${backup_targets[index]}")"
        mv -- "${backup_sources[index]}" "${backup_targets[index]}" ||
          printf 'Restore your backup manually: %s\n' "$backup_sources[index]" >&2
      fi
    done
  fi

  [[ ! -d "$stage" ]] || rm -rf -- "$stage"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

printf 'Requires Quickshell 0.3.1+ with Networking, UPower, PipeWire and Qt.labs.folderlistmodel.\n'

# Копируем runtime и конфигурации в staging, сохраняя относительные пути.
printf 'Copying shell runtime files from %s...\n' "$runtime_source"
copy_runtime_tree
printf 'Copying project configs from %s...\n' "$configs_source"
copy_configs_tree

# Бэкап существующих управляемых целей. Остальной ~/.config не затрагивается.
if [[ -e "$target" || -L "$target" ]]; then
  backup=$(mktemp -d "$config_dir/quickshell.backup.XXXXXXXX")
  rmdir -- "$backup"
  mkdir -p -- "$backup/quickshell" "$backup/configs"
  backup_sources+=("$backup/quickshell/content")
  backup_targets+=("$target")
  mv -- "$target" "${backup_sources[0]}"
fi

for entry in "${config_entries[@]}"; do
  config_target="$config_dir/$entry"
  if [[ -e "$config_target" || -L "$config_target" ]]; then
    [[ -n "$backup" ]] || {
      backup=$(mktemp -d "$config_dir/quickshell.backup.XXXXXXXX")
      rmdir -- "$backup"
      mkdir -p -- "$backup/quickshell" "$backup/configs"
    }
    backup_sources+=("$backup/configs/$entry")
    backup_targets+=("$config_target")
    mkdir -p -- "$(dirname -- "${backup_sources[$((${#backup_sources[@]} - 1))]}")"
    mv -- "$config_target" "${backup_sources[$((${#backup_sources[@]} - 1))]}"
  fi
done

# Устанавливаем staged runtime и configs.
mv -- "$stage/quickshell" "$target"
installed_targets+=("$target")
for entry in "${config_entries[@]}"; do
  config_target="$config_dir/$entry"
  mv -- "$stage/configs/$entry" "$config_target"
  installed_targets+=("$config_target")
done
installed=true

printf 'Installed: %s\n' "$target"
[[ -z "$backup" ]] || printf 'Previous configuration: %s\n' "$backup"
printf '\nStart in your Hyprland session:\n  quickshell -p "%s"\n' "$target"
printf 'Apply installed session configs manually when ready:\n  hyprctl reload\n'
printf '\nUse a Nerd Font. Stop dunst/mako before using the notification module.\n'

# Показываем, что было установлено
qml_count=$(find "$target" -type f -name '*.qml' | wc -l)
qmldir_count=$(find "$target" -type f -name qmldir | wc -l)
printf '\nInstalled %d QML files, %d qmldir manifests and %d config roots\n' "$qml_count" "$qmldir_count" "${#config_entries[@]}"
