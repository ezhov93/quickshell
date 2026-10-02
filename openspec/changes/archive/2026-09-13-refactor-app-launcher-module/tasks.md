## 1. Сервис launcher

- [x] 1.1 Заменить `SearchIndex.qml` на singleton `LauncherService.qml`, сохранив источник `DesktopEntries`, поля индекса, сортировку, поиск и запуск, затем проверить изолированную offscreen-загрузку сервиса и результаты поиска на контролируемых desktop-entry данных.

## 2. Представление и окно

- [x] 2.1 Добавить `LauncherResults.qml`, перенести в него список, highlight, empty state и `LauncherEntry`, зарегистрировать тип и проверить offscreen-harness на создание, выбранный индекс, hover/activation signals и позиционирование строки без import/type ошибок.
- [x] 2.2 Добавить `LauncherPanel.qml`, перенести в него локальные query/selection/focus, `ScriptModel`, клавиатурную навигацию и композицию содержимого, затем проверить offscreen-harness на начальный и граничный выбор, reset/reconcile, Up/Down/Tab, Enter/Return и Escape.
- [x] 2.3 Сократить `LauncherWindow.qml` до Wayland-окна, backdrop и композиции `LauncherPanel`, сохранить `AppLauncher.qml` координатором IPC/lazy-loading, обновить `qmldir`, удалить `SearchIndex.qml` и проверить по всему `shell/` отсутствие старого имени и сохранение единственного `LazyLoader` launcher.

## 3. Документация и статические проверки

- [x] 3.1 Обновить `docs/architecture.md`, `docs/spec-status.md`, AppLauncher checklist в `docs/testing.md` и `CHANGELOG.md`, затем проверить, что документы описывают только фактическую структуру и не объявляют runtime-сценарии пройденными без результата.
- [x] 3.2 Выполнить `openspec validate "refactor-app-launcher-module" --strict`, `openspec validate --specs --strict`, доступные offscreen-проверки AppLauncher, `git diff --check` для tracked-файлов и отдельную whitespace-проверку новых untracked-файлов; зафиксировать каждый результат как пройденный, непройденный или заблокированный.

## 4. Runtime-проверка

- [x] 4.1 В подготовленной Hyprland-сессии вручную проверить `launcher toggle`, открытие/закрытие/повторное открытие, поиск по имени, общему имени, keywords и категориям с учётом регистра и внешних пробелов, hover/click, стрелки/Tab, Enter/Return, Escape, тему и неизменную геометрию; отметить задачу выполненной только после фактического результата владельца сессии.
