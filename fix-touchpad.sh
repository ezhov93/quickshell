#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == --help || ${1:-} == -h ]]; then
  printf 'Usage: sudo bash %s\nApply and persist the tested SYNA3602 touchpad fix (quirks=5121).\n' "$0"
  exit 0
fi
if (( $# )); then
  printf 'Unknown argument: %s\n' "$1" >&2
  exit 1
fi
if (( EUID != 0 )); then
  printf 'Запусти: sudo bash "%s"\n' "$0" >&2
  exit 1
fi
command -v udevadm >/dev/null || { printf 'Не найден udevadm.\n' >&2; exit 1; }

devices=()
for device in /sys/bus/hid/devices/0018:0911:5288.*; do
  [[ -f "$device/quirks" && -f "$device/uevent" ]] || continue
  if grep -Fxq 'HID_NAME=SYNA3602:00 0911:5288' "$device/uevent"; then
    devices+=("$device")
  fi
done
if (( ${#devices[@]} == 0 )); then
  printf 'Тачпад SYNA3602:00 0911:5288 не найден. Ничего не изменено.\n' >&2
  exit 1
fi

rule_file=/etc/udev/rules.d/99-teclast-touchpad.rules
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
cat > "$stage/99-teclast-touchpad.rules" <<'EOF'
# Tested on TECLAST F7: retain NOT_SEEN_MEANS_UP, add IGNORE_DUPLICATES
# and CONTACT_CNT_ACCURATE to fix single-finger movement and contact jumps.
ACTION=="add|bind", SUBSYSTEM=="hid", KERNEL=="0018:0911:5288.*", ENV{HID_NAME}=="SYNA3602:00 0911:5288", DRIVER=="hid-multitouch", ATTR{quirks}="5121"
EOF
udevadm verify "$stage/99-teclast-touchpad.rules"
mkdir -p -- /etc/udev/rules.d
if [[ -e "$rule_file" ]] && ! cmp -s -- "$stage/99-teclast-touchpad.rules" "$rule_file"; then
  cp --backup=numbered -- "$rule_file" "$rule_file.bak"
  printf 'Предыдущее правило сохранено: %s.bak\n' "$rule_file"
fi
install -m 644 -- "$stage/99-teclast-touchpad.rules" "$rule_file"
udevadm control --reload-rules
for device in "${devices[@]}"; do
  printf '5121\n' > "$device/quirks"
  [[ $(cat "$device/quirks") == 5121 ]] || { printf 'Не удалось применить исправление.\n' >&2; exit 1; }
done
printf 'Исправление применено и сохранено для следующих загрузок.\n'
