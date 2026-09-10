# Отчёт о проверке

## Статические проверки

- **passed** — все entries изменённых `qmldir` указывают на существующие QML-файлы; корневой `qs.modules.AppLauncher` экспортирует только `AppLauncher`, внутреннее окно экспортируется из `qs.modules.AppLauncher.components`.
- **passed** — в `Bar.qml`, `WorkspaceList.qml`, `MediaWidget.qml`, `TrayWidget.qml`, `LauncherWindow.qml` и `NotificationCard.qml` отсутствуют прямые импорты Hyprland/MPRIS/SystemTray/Notifications и прямые вызовы `activate`, `secondaryActivate`, `togglePlaying` или `DesktopEntry.execute`; `Bar.qml` не содержит `Process`.
- **passed** — `shell.qml` не изменён. В проверяемой области количество `Process` осталось 3 до/после, количество `Timer` — 2 до/после. `Config.networkSettingsCommand` и оба вызова `ip -j route` сохранены в `NetworkService`.

Использованные проверки:

```bash
find shell/modules/AppLauncher shell/modules/Bar shell/modules/Notifications shell/components shell/services -name qmldir -print
grep -nE '^import Quickshell\.(Hyprland|Services\.(Mpris|SystemTray|Notifications))|Process[[:space:]]*\{|\.activate\(\)|\.secondaryActivate\(\)|\.togglePlaying\(\)|entry\.execute\(' <visual-files>
git diff --exit-code -- shell/shell.qml
grep -R -n 'Timer[[:space:]]*{' shell/modules/Bar/services shell/modules/AppLauncher shell/modules/Notifications
grep -R -n 'Process[[:space:]]*{' shell/modules/Bar shell/modules/AppLauncher shell/modules/Notifications
```

## Изолированная загрузка

- **blocked** — полный `shell.qml` в offscreen-среде разрешает изменённые imports, но останавливается на `PanelWindow`: `No PanelWindow backend loaded`. Это ожидаемое ограничение проверки без Wayland/Hyprland и не считается runtime-pass.
- **passed** — отдельная offscreen-конфигурация без окон загрузила новые Bar services и неоконные компоненты: журнал содержит `INFO: Configuration Loaded`; процесс оставался запущен до `timeout` (код 124). Предупреждения об отсутствующих D-Bus, MPRIS, SystemTray и Hyprland ожидаемы для изолированной среды.
- **not run** — графическая/session-регрессия. По правилу проекта её выполняет владелец вручную; агент не запускает и не перезапускает пользовательскую графическую сессию.
- **passed** — владелец подтвердил загрузку shell, launcher, запуск приложений, workspace/active title, tray, media и notification actions.
- **passed** — после уточнения терминала команда изменена на `foot -e nmtui`; владелец подтвердил открытие сетевых настроек.
- **passed** — воспроизводимая процедура, ограничения среды и критерии статусов сохранены в `docs/testing.md` для следующих изменений.

Команда изолированной проверки:

```bash
timeout 5s env -u DISPLAY -u WAYLAND_DISPLAY QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= XDG_CACHE_HOME=<tmp-cache> XDG_RUNTIME_DIR=<tmp-runtime> quickshell -p /tmp/quickshell-refactor-service-check --no-color
```

## Установщик

- **passed** — `bash -n install.sh`.
- **passed** — `bash install.sh --help`; команда завершилась без изменения файлов пользователя.
- **passed** — статический allowlist сформировал 69 runtime-файлов только из `shell/shell.qml`, `shell/qmldir`, `shell/config/`, `shell/components/`, `shell/services/`, `shell/modules/`; `docs/`, `openspec/`, `extra/` и `quickshell.code-workspace` отсутствуют.
- **passed** — по diff сохранены `~/.config/quickshell`, staging, backup/rollback, сообщения о зависимостях и отдельная команда запуска; общий source-root `find` удалён.
- **not run** — реальная установка: скрипт не имеет безопасного destination override и не должен заменять пользовательский `~/.config` во время агентской проверки.
- **not run** — `shellcheck`: команда не установлена.
