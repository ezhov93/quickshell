## 1. Границы сервисов и визуальных примитивов

- [x] 1.1 Заменить `KeyboardLayout.qml` на зарегистрированный singleton `KeyboardLayoutService.qml`, переименовать `Time.qml` в singleton `ClockService.qml` и проверить загрузку обоих типов из `qs.modules.Bar.services` изолированным offscreen-harness.
- [x] 1.2 Добавить статический `BarPill.qml`, перевести `BarButton.qml` на отдельную интерактивную ответственность и проверить через минимальный QML-harness создание обоих типов с обязательными theme/font свойствами без import/type ошибок.

## 2. Feature-widget и окно панели

- [x] 2.1 Заменить `SystemIndicators.qml` отдельными `CpuWidget.qml`, `MemoryWidget.qml`, `TemperatureWidget.qml`, `NetworkWidget.qml` и `BatteryWidget.qml`, зарегистрировать типы и статически проверить, что память берётся из существующего `ResourceService.memoryUsage`, неизвестные метрики дают `N/A`, а новый polling отсутствует.
- [x] 2.2 Вынести inline-представления в `ActiveWindowWidget.qml`, `KeyboardLayoutWidget.qml` и `ClockWidget.qml`, заменить `WorkspaceList.qml` на `WorkspaceSwitcher.qml` и проверить, что каждое действие обращается к соответствующему сервису, а визуальные примитивы не импортируют системные API.
- [x] 2.3 Добавить `BarWindow.qml`, сократить `Bar.qml` до координатора видимости, IPC, service lifecycle и экранных вариантов, обновить `qmldir`, удалить заменённые QML-типы и проверить отсутствие ссылок на старые имена по всему `shell/`.

## 3. Документация и статические проверки

- [x] 3.1 Обновить `docs/architecture.md`, ADR-0002, `docs/spec-status.md`, Bar checklist в `docs/testing.md` и `CHANGELOG.md`, затем проверить, что они описывают память, новую границу Bar и фактический доступ Workspace через сервис без заявления о невыполненных runtime-проверках.
- [x] 3.2 Выполнить `openspec validate "refactor-bar-module" --strict`, `openspec validate --specs --strict`, offscreen-проверку сервисов и неоконных компонентов Bar, `git diff --check` для tracked-файлов и отдельную whitespace-проверку новых untracked-файлов; зафиксировать каждый результат как пройденный, непройденный или заблокированный.

## 4. Runtime-проверка

- [x] 4.1 В подготовленной Hyprland-сессии вручную проверить отображение панели на доступных экранах, CPU/память/температуру и `N/A`, Workspace, Tray, Media, Volume, Brightness, Network, Battery, KeyboardLayout, Clock, `bar toggle`, повторное отображение и остановку предусмотренного polling при скрытии; отметить задачу выполненной только после получения фактического результата владельца сессии.
