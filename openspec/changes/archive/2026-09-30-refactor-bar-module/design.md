## Context

См. мотивацию в `proposal.md`. Сейчас `Bar.qml` содержит координатор модуля, `Variants`, `PanelWindow`, компоновку и inline-представления активного окна, раскладки и часов. `SystemIndicators.qml` объединяет CPU, температуру, сеть и батарею, тогда как другие возможности представлены отдельными виджетами. `ResourceService` уже читает CPU, память и температуру с одинаковым условием активности панели, но UI использует только CPU и температуру.

Bar создаёт окно на каждом элементе `Quickshell.screens`. Большинство системных состояний представлены singleton-сервисами; исключение — единственный экземпляр `KeyboardLayout`, который подписывается на Hyprland и использует общий `HyprlandClient`. `Audio` и `Brightness` находятся в корневом `shell/services`, потому что совместно используются Bar и OSD.

Целевое устройство ограничено по CPU и памяти. Рефакторинг не должен добавлять опрос, фоновые процессы, графические эффекты или дублирующие подписки на каждый экран.

## Goals / Non-Goals

**Goals:**

- Оставить `Bar.qml` координатором жизненного цикла и вынести представление одного экрана в отдельный компонент.
- Дать каждой отображаемой возможности собственный feature-widget, включая память.
- Разделить статический визуальный контейнер и интерактивный контрол.
- Сохранить системные операции и подтверждённое состояние в сервисах.
- Не создавать по экземпляру системного сервиса или polling-механизма на каждое окно панели.

**Non-Goals:**

- Не менять визуальный стиль, порядок виджетов, размеры, цвета, шрифт и анимации панели.
- Не менять IPC target `bar`, команду сетевых настроек и поведение Workspace, Tray, Media, Audio или Brightness.
- Не вводить универсальную систему плагинов виджетов, service locator, общий Bar facade или новый адаптер.
- Не выбирать новый test framework и не добавлять отдельный процесс.

## Decisions

### 1. Координатор и окно разделяются

`shell/modules/Bar/Bar.qml` остаётся единственным entrypoint модуля. Он владеет `barVisible`, `IpcHandler`, bindings активности `ResourceService` и `NetworkService`, а также `Variants` по доступным экранам. Делегатом каждого варианта становится `components/BarWindow.qml`, получающий экран, видимость, тему и шрифт.

`BarWindow.qml` владеет только `PanelWindow` и компоновкой виджетов. Его размещение в `components/` сохраняет правило: entry-файлы находятся в корне модуля, внутренний UI — в `components/`.

Альтернатива — оставить `PanelWindow` в `Bar.qml` и вынести только содержимое — уменьшает один уровень компонента, но продолжает смешивать управление вариантами с деталями окна. Выбран отдельный `BarWindow` как законченная ответственность.

### 2. Компоненты остаются плоскими feature-widget

Сборный `SystemIndicators.qml` заменяется `CpuWidget.qml`, `MemoryWidget.qml`, `TemperatureWidget.qml`, `NetworkWidget.qml` и `BatteryWidget.qml`. Inline-представления переносятся в `ActiveWindowWidget.qml`, `KeyboardLayoutWidget.qml` и `ClockWidget.qml`; `WorkspaceList.qml` переименовывается в `WorkspaceSwitcher.qml`, поскольку компонент также выполняет действие переключения.

Подкаталоги `widgets/` и `primitives/` не вводятся: для текущего количества файлов они требуют дополнительных QML-модулей и импортов без полезной границы. `BarWindow.qml` сохраняет левую, среднюю и правую секции inline; отдельные section-классы появятся только при самостоятельном поведении или повторном использовании.

Альтернатива — оставить `SystemIndicators` — уменьшает число файлов, но связывает независимый порядок, видимость и развитие метрик, сети и батареи.

### 3. Статическая поверхность отделяется от действия

`BarPill.qml` предоставляет фон, размеры, padding и content slot без ввода. `BarButton.qml` добавляет интерактивность, hover, click и wheel поверх той же поверхности. Статические CPU, память, температура, батарея, раскладка и часы используют `BarPill`; Workspace, Media, Volume, Brightness и Network используют `BarButton`. Tray использует статический контейнер, а действия остаются у его delegates.

Это устраняет режим `interactive: false` у сущности с семантикой кнопки и позволяет назначать accessibility role согласно фактическому поведению. Реализация не добавляет визуальных QML-узлов сверх необходимых поверхностей и обработчиков.

Альтернатива — сохранить один `BarButton` с флагом — требует меньше файлов, но оставляет смешанную семантику и допускает недоступные обработчики на статических индикаторах.

### 4. Feature-widget напрямую использует свой сервис

Модульные виджеты обращаются к одному отвечающему за возможность сервису: Workspace к `WorkspaceService`, Media к `MediaService`, Network к `NetworkService` и так далее. `NetworkWidget` вызывает `NetworkService.openSettings()` непосредственно, как остальные интерактивные виджеты, вместо транзитного сигнала через `BarWindow` и `Bar.qml`.

Это соответствует направлению `module UI -> service -> native API` и не требует facade, который только повторял бы свойства и методы существующих сервисов. Переиспользуемые примитивы `BarPill` и `BarButton` не импортируют сервисы Bar.

### 5. Общесистемные сервисы не размножаются по экранам

`KeyboardLayout.qml` переименовывается в `KeyboardLayoutService.qml`, получает `pragma Singleton` и запись singleton в `services/qmldir`. Остальные локальные сервисы сохраняют singleton-модель. `Time.qml` переименовывается в `ClockService.qml` для согласованности с `ClockWidget` и также остаётся singleton.

`WorkspaceService`, `TrayService` и `MediaService` сохраняются: перенос их native API в виджеты нарушил бы границу системной интеграции. Общие `Audio` и `Brightness` не перемещаются в Bar.

### 6. Память использует существующий polling

`MemoryWidget.qml` отображает `ResourceService.memoryUsage` как округлённый процент либо `N/A`. Новых чтений и таймеров не добавляется: `/proc/meminfo` уже читается с интервалом `Config.resourceCpuInterval` одновременно с `/proc/stat`, пока `ResourceService.active` связан с видимостью Bar. При скрытой панели CPU и память не опрашиваются; температура также следует существующему условию активности.

Отдельный `MemoryService` не создаётся, поскольку CPU, память и температура образуют одну возможность системных метрик с общим потребителем и жизненным циклом. Разделение сервисов увеличило бы число singleton-объектов и bindings без независимого режима работы.

### 7. QML-модули и документация обновляются вместе

`components/qmldir` и `services/qmldir` отражают добавленные, удалённые и переименованные типы; корневой `qmldir` продолжает экспортировать только `Bar`. `docs/architecture.md`, ADR-0002, `docs/spec-status.md` и Bar checklist в `docs/testing.md` обновляются только в части реализованной структуры, памяти и уже устранённого прямого доступа Workspace UI к Hyprland.

### 8. Затронутые файлы и слои

- Координатор: изменяется `shell/modules/Bar/Bar.qml`.
- Представление: добавляются `components/BarWindow.qml`, `BarPill.qml`, `ActiveWindowWidget.qml`, `CpuWidget.qml`, `MemoryWidget.qml`, `TemperatureWidget.qml`, `NetworkWidget.qml`, `BatteryWidget.qml`, `KeyboardLayoutWidget.qml`, `ClockWidget.qml`; изменяются `BarButton.qml`, `TrayWidget.qml`, `MediaWidget.qml`, `VolumeWidget.qml`, `BrightnessWidget.qml`; `WorkspaceList.qml` заменяется `WorkspaceSwitcher.qml`, а `SystemIndicators.qml` удаляется.
- Сервисы: `KeyboardLayout.qml` заменяется singleton `KeyboardLayoutService.qml`, `Time.qml` заменяется `ClockService.qml`; `WorkspaceService.qml`, `TrayService.qml`, `MediaService.qml`, `ResourceService.qml`, `NetworkService.qml` и `BatteryService.qml` сохраняют ответственность.
- Регистрация типов: изменяются `components/qmldir` и `services/qmldir`; корневой `qmldir` проверяется без расширения публичного API.
- Документация: изменяются `docs/architecture.md`, `docs/adr/0002-modular-quickshell-shell.md`, `docs/spec-status.md`, `docs/testing.md` и `CHANGELOG.md`.
- Общие сервисы, конфигурация, сессия и deployment не изменяются; новые привилегии и побочные эффекты отсутствуют.

## Risks / Trade-offs

- [Риск регрессии размеров после извлечения компонентов] -> сохранить текущие implicit/explicit размеры, spacing и anchors; проверить панель на узком и обычном экране вручную.
- [Риск дублирования Hyprland-подписок в многомониторной сессии] -> сделать `KeyboardLayoutService` singleton и не создавать сервисы внутри `BarWindow`.
- [Риск потери click/wheel при разделении примитивов] -> проверить Media, Volume, Brightness, Network и Workspace отдельно, включая accessibility press для интерактивных элементов.
- [Риск отсутствия места после добавления Memory] -> сохранить elide активного окна и проверить фактическую компоновку на целевом разрешении; изменение порядка или адаптивное скрытие потребует отдельного решения.
- [Цена большего числа QML-файлов] -> runtime-дерево остаётся сопоставимым; новые файлы задают compile-time границы и не добавляют процессы или polling.
- [Полный `PanelWindow` нельзя подтвердить offscreen] -> offscreen-проверка покрывает импорты и singleton-сервисы, а окно и взаимодействия получают отдельный ручной статус в подготовленной Hyprland-сессии.

## Migration Plan

1. Добавить новые примитивы и feature-widget, сохраняя старые файлы до переключения `BarWindow`.
2. Вынести текущее окно и layout в `BarWindow`, подключить новые виджеты и singleton-сервисы.
3. Обновить `qmldir`, затем удалить заменённые `SystemIndicators.qml`, `WorkspaceList.qml`, `KeyboardLayout.qml` и `Time.qml`.
4. Выполнить статические и доступные offscreen-проверки, затем ручную проверку Bar в подготовленной Hyprland-сессии.
5. Обновить документацию и карту статуса только фактическими результатами проверок.

Сохраняемых данных и формата конфигурации изменение не затрагивает. Откат выполняется возвратом QML-файлов, `qmldir` и документации одной ревизией Git; миграция пользовательского состояния не требуется.
