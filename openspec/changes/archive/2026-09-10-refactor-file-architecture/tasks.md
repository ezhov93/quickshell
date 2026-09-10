## 1. Файловая раскладка модулей

- [x] 1.1 Перенести `modules/AppLauncher/LauncherWindow.qml` в `modules/AppLauncher/components/`, создать локальный `qmldir`, обновить импорт entrypoint и удалить прежний публичный export; проверить, что `qs.modules.AppLauncher` по-прежнему экспортирует только `AppLauncher`, а новый manifest указывает существующий файл.
- [x] 1.2 Удалить дубликат `services/quickshell.code-workspace`, сохранив существующий корневой `quickshell.code-workspace`; проверить через `find services -maxdepth 1 -type f`, что в runtime-каталоге остались только QML-сервисы и `qmldir`, а корневая editor-конфигурация не изменилась по содержанию.
- [x] 1.3 Перенести `shell.qml`, `qmldir`, `config/`, `components/`, `services/` и `modules/` в подпапку `shell/`, сохранив внутренние относительные пути и Git-корень для документации, OpenSpec, `extra/` и `install.sh`; проверить отсутствие старых runtime-путей в корне.

## 2. Границы системных интеграций Bar

- [x] 2.1 Добавить singleton `WorkspaceService` и его export, перевести `Bar.qml` и `WorkspaceList.qml` на предоставляемые модель, active title и activation; проверить отсутствие `Quickshell.Hyprland` и прямого `activate()` в этих visual-файлах при сохранении существующих bindings и анимаций.
- [x] 2.2 Добавить singleton `MediaService`, перенести в него выбор active player и play/pause, затем перевести `MediaWidget.qml`; проверить отсутствие `Quickshell.Services.Mpris` и `togglePlaying()` в компоненте и неизменность алгоритма «playing, иначе первый».
- [x] 2.3 Добавить singleton `TrayService`, передать через него items и left/middle activation, оставив menu anchoring в `TrayWidget.qml`; проверить отсутствие `Quickshell.Services.SystemTray` и прямых activation-вызовов в компоненте, а также сохранение обработки трёх кнопок мыши.
- [x] 2.4 Перенести on-demand запуск `Config.networkSettingsCommand` в `NetworkService.openSettings()` и вызвать его из Bar; проверить отсутствие `Process` в `Bar.qml`, использование `Quickshell.Io` только существующим `IpcHandler`, точное сохранение команды и отсутствие нового timer/polling.

## 3. Границы AppLauncher и Notifications

- [x] 3.1 Добавить в `SearchIndex` операцию запуска desktop entry и перевести на неё `LauncherWindow`; проверить отсутствие прямого `entry.execute()` в visual-файле и сохранение закрытия окна после запуска через мышь и Enter/Return.
- [x] 3.2 Добавить в `NotificationData` семантические признаки urgency и использовать их в `NotificationCard`; проверить отсутствие `Quickshell.Services.Notifications` в компоненте и неизменность dismiss/action-вызовов, таймеров и plain-text rendering.

## 4. Установщик runtime-дерева

- [x] 4.1 Разделить в `install.sh` проверку зависимостей, валидацию source tree и копирование, заменив общий `find` явным allowlist runtime-root `shell/` с `shell.qml`, `qmldir`, `config/`, `components/`, `services/`, `modules/`; проверить сохранение целевого пути, backup/rollback и относительных путей QML/`qmldir`.
- [x] 4.2 Запустить `bash -n "install.sh"` и статически проверить, что staging не получает файлы из `docs/`, `openspec/`, `extra/` или editor metadata; реальную установку не выполнять против пользовательского `~/.config`.

## 5. Статическая и изолированная проверка

- [x] 5.1 Проверить все изменённые `qmldir` и импорты по фактическим путям, затем статически убедиться, что затронутые visual-файлы не импортируют Hyprland/MPRIS/SystemTray/Notifications и не содержат `Process`; сохранить команды и результат в отчёте.
- [x] 5.2 Сравнить timers, polling conditions, IPC targets, внешние команды и состав `shell.qml` до/после; подтвердить по diff отсутствие новых фоновых процессов, polling и наблюдаемых изменений.
- [x] 5.3 Выполнить доступную изолированную offscreen-проверку загрузки QML без запуска Hyprland или пользовательской графической сессии; результат отметить как passed, failed или blocked с точным сообщением.
- [x] 5.4 Зафиксировать воспроизводимую offscreen-процедуру и критерии passed/failed/blocked в `docs/testing.md`; проверить, что она не требует пользовательского `~/.config`, display или запуска графической сессии и не объявляет `PanelWindow` проверенным.

## 6. Ручная проверка владельцем сессии

- [x] 6.1 Передать владельцу чеклист и получить подтверждение загрузки shell без QML/import errors, открытия/закрытия/reopen launcher, запуска приложения мышью и Enter/Return, переключения workspace и обновления active window title.
- [x] 6.2 Получить подтверждение tray left/right/middle actions и menu, media display/play-pause и notification dismiss/actions; агент не запускает, не блокирует и не перезапускает графическую сессию.
- [x] 6.3 Получить подтверждение открытия сетевых настроек после замены команды на `foot -e nmtui` в `Config.networkSettingsCommand`.

## 7. Документация и финальная валидация

- [x] 7.1 После подтверждения реализации обновить `docs/architecture.md` и `docs/spec-status.md`: описать фактические новые границы, закрыть G01 и G03 и не заявлять непроверенные функциональные исправления; проверить ссылки и соответствие исходникам.
- [x] 7.2 Запустить `openspec validate "refactor-file-architecture" --strict`, `openspec validate --specs --strict` и `git diff --check`; отдельно проверить новые untracked-файлы и записать каждому check статус passed/failed/not run/blocked.
