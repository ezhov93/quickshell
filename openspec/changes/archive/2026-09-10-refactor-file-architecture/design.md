## Context

Действующие ограничения заданы baseline-спекой `architecture` и ADR-0002. Большая часть дерева уже разделена на module entrypoints, локальные `components/` и `services/`, но аудит выявил смешение ролей:

- `modules/AppLauncher/LauncherWindow.qml` является UI, но экспортируется из корня модуля; запуск приложения выполняется самим окном через `DesktopEntry.execute()`;
- `modules/Bar/Bar.qml` читает активное окно из Hyprland и содержит `Process` для сетевых настроек;
- `WorkspaceList.qml`, `MediaWidget.qml` и `TrayWidget.qml` напрямую используют системные модели и выполняют их операции;
- `NotificationCard.qml` зависит от enum системного API, хотя получает подготовленную модель модуля;
- `services/quickshell.code-workspace` не является runtime-сервисом.
- `install.sh` рекурсивно ищет QML и `qmldir` от корня репозитория, поэтому будущий служебный или тестовый QML может попасть в установленную конфигурацию (G03).

Целевой Git-корень сохраняет документацию, OpenSpec, пример Hyprland, установщик и editor metadata. Runtime исходники оболочки группируются в подпапке `shell/`.

Общие `Audio`, `Brightness`, `DirectoryScanner`, `TextFileWriter` и `HyprlandClient` имеют несколько потребителей или самостоятельную общую ответственность и остаются в `shell/services/`. `shell/components/IconButton.qml` сохраняется как общий, независимый от модулей визуальный примитив. Исправление функциональности не входит в этот рефакторинг.

## Goals

- Сделать расположение каждого затронутого файла отражением его ответственности.
- Убрать владение системным состоянием и операциями из визуальных файлов, сохранив реактивные обновления.
- Сохранить публичные module entrypoints, поведение IPC и ленивое создание окон.
- Не увеличить число процессов, timers, polling-механизмов и обязательных зависимостей.

## Non-goals

- Не менять baseline-спеки и не добавлять новую capability.
- Не перерабатывать UI, тексты, тему, hotkeys или поведение выбора активного player/workspace/tray item.
- Не менять `shell.qml`, целевой путь и backup-семантику установщика, пример Hyprland, session lifecycle, MonitorManager, IdleInhibitor или известные функциональные пробелы других задач.
- Не вводить универсальный adapter для каждого API Quickshell.

## Decisions

### 1. Корень модуля содержит только его публичный entrypoint

`LauncherWindow.qml` переносится в `modules/AppLauncher/components/`. Для каталога создаётся `qmldir` с namespace `qs.modules.AppLauncher.components`; `AppLauncher.qml` импортирует этот namespace, а корневой manifest продолжает экспортировать только `AppLauncher`. Внешний импорт `qs.modules.AppLauncher` и композиция в `shell.qml` остаются прежними.

Альтернатива — оставить окно в корне как второй публичный тип — отвергнута: оно является внутренней деталью модуля и не используется внешними потребителями.

### 2. Системные модели панели получают локальные сервисные границы

В `shell/modules/Bar/services/` добавляются singleton-сервисы с узкой ответственностью:

- `WorkspaceService` импортирует `Quickshell.Hyprland`, предоставляет реактивную модель рабочих столов, заголовок активного окна и операцию активации workspace;
- `MediaService` импортирует `Quickshell.Services.Mpris`, сохраняет текущий алгоритм выбора активного player и предоставляет подготовленные поля отображения и операцию play/pause;
- `TrayService` импортирует `Quickshell.Services.SystemTray`, предоставляет модель items и методы left/middle activation; привязка и открытие `QsMenuAnchor` остаются задачей UI, потому что зависят от геометрии окна.

`WorkspaceList`, `MediaWidget`, `TrayWidget` и `Bar.qml` получают данные и вызывают операции через эти сервисы. Системные объекты могут оставаться элементами внутренней модели сервиса, но visual-файлы больше не импортируют соответствующие system namespaces и не вызывают системные методы напрямую.

Альтернатива — один `BarService` — отвергнута: у workspace, media и tray разные поставщики, состояние и failure paths. Отдельные сервисы не создают процессы, поскольку остаются singleton-объектами того же Quickshell process.

### 3. Существующие capability-сервисы принимают операции своего UI

Запуск `Config.networkSettingsCommand` переносится из `Bar.qml` в существующий `NetworkService.openSettings()`. Единственный `Process` запускается только по явному запросу пользователя; polling и условия `NetworkService.active` не меняются. `Bar.qml` и `AppLauncher.qml` сохраняют импорт `Quickshell.Io`, потому что он предоставляет их существующие `IpcHandler`; это локальный IPC-вход entrypoint, а не владение системной операцией visual-компонентом.

`SearchIndex` получает операцию запуска выбранного desktop entry. `LauncherWindow` передаёт ей entry и закрывается после принятого запроса тем же способом, что и сейчас. Это не меняет поиск, выбор, клавиатурное управление или команду desktop entry.

Альтернатива — общий `CommandRunner` — отвергнута: он скрыл бы владельца операции и создал бы слабую универсальную границу без отдельной ответственности.

### 4. NotificationData является view model для карточки

`NotificationData` предоставляет семантические признаки urgency, необходимые карточке. `NotificationCard` использует эти признаки и уже существующие методы модели для dismiss/actions, поэтому больше не импортирует `Quickshell.Services.Notifications`. Владение NotificationServer и исходным notification object остаётся в `shell/modules/Notifications/services/`.

Это сохраняет текущий plain-text rendering и не исправляет G08 в рамках рефакторинга.

### 5. Общие каталоги определяются переиспользуемой ответственностью

Общие `shell/services/` и `shell/components/` не расформировываются. Общие сервисы с несколькими потребителями и generic `IconButton` остаются на месте. Поскольку `quickshell.code-workspace` уже существует в корне репозитория, дубликат `services/quickshell.code-workspace` удаляется без замены корневой editor-конфигурации, чтобы metadata не устанавливалась как часть runtime service tree.

Новые QML-типы добавляются в соответствующие `qmldir`; удалённые или перенесённые типы удаляются из прежних manifests. Публичными остаются только существующие module entrypoints.

### 6. Проверка границ дополняет поведенческую регрессию

Статическая проверка подтверждает:

- отсутствие `Quickshell.Hyprland`, `Quickshell.Services.Mpris`, `Quickshell.Services.SystemTray` и `Quickshell.Services.Notifications` в затронутых visual-компонентах;
- отсутствие `Process` и прямых системных операций в затронутых visual-файлах;
- согласованность путей, namespaces и экспортов всех изменённых `qmldir`;
- отсутствие новых timers, polling и самостоятельных процессов.

Графическую и session-проверку выполняет владелец вручную по чеклисту: агент не запускает, не блокирует и не перезапускает графическую сессию. Проверяются launcher, workspace switching и active title, tray actions/menu, media display/play-pause, network settings и notification actions.

### 7. Установщик копирует явное runtime-дерево

`install.sh` задаёт allowlist внутри runtime-root `shell/`: `shell.qml`, корневой `qmldir` и каталоги `config`, `components`, `services`, `modules`. Перед созданием backup он проверяет обязательные entrypoint/manifests, затем копирует из разрешённых каталогов только `*.qml` и `qmldir` с прежними относительными путями. Поиск от Git-корня удаляется, поэтому `docs/`, `openspec/`, `extra/` и будущие QML-тесты не попадают в staging.

Проверка зависимостей, фиксированный путь `~/.config/quickshell`, staging в том же filesystem, backup/rollback и отсутствие запуска shell или настройки Hyprland сохраняются. Функции выделяются по операциям проверки и копирования; новый CLI, destination override и package installation не добавляются.

Альтернатива — исключать известные служебные каталоги из общего `find` — отвергнута: denylist снова станет неполным при появлении нового каталога. Установка каталогов целиком также отвергнута, поскольку протащит editor metadata и другие не-runtime файлы.

## Risks and Trade-offs

- Реактивность QML-моделей может потеряться при неудачной обёртке system model. Модель сервиса передаётся binding-ом без снимка или периодического копирования; проверяются добавление/удаление workspace, player и tray item.
- Перенос `LauncherWindow` может сломать разрешение типа при lazy loading. Файл и новый `qmldir` переносятся одним шагом, а старый экспорт удаляется только после обновления импорта entrypoint.
- Обёртка tray actions может изменить контекст меню или обработку кнопок. Геометрия `QsMenuAnchor` остаётся в `TrayWidget`, а left/right/middle сценарии включаются в ручной чеклист.
- Сервис media может изменить выбор player. Алгоритм «playing, иначе первый» переносится без изменения и проверяется с одним player и при доступности нескольких.
- Рефакторинг может случайно захватить известные функциональные проблемы. Diff проверяется на отсутствие изменений UI-констант, IPC targets, timers и внешних команд, кроме перемещения их владельца.
- Allowlist установщика требует явного добавления нового runtime-каталога в будущем. Это намеренная граница: отсутствие source entrypoint/manifests выявляется до backup, а изменение runtime-состава должно быть осознанным.

## Migration Plan

1. Сначала добавить локальные сервисы и их manifest entries, не меняя потребителей.
2. Перевести visual-файлы и module entrypoints на новые границы по одной интеграции.
3. Перенести Launcher window, удалить дубликат editor workspace-файла из `services/` и очистить прежние exports/imports.
4. Перенести runtime-дерево в подпапку `shell/`, перевести установщик на явный allowlist этого каталога и проверить `bash -n` без запуска против пользовательского каталога.
5. Выполнить статические проверки и подготовить владельцу session ручной чеклист.
6. После подтверждения runtime обновить `docs/architecture.md`, закрыть G01 и G03 в `docs/spec-status.md`, перечислив фактическое доказательство.

Изменение не мигрирует пользовательские данные и не меняет установленную конфигурацию вне обычного повторного запуска `install.sh`. Откат выполняется возвратом перенесённых файлов, manifests и потребителей в одном revision; внешнего состояния для восстановления нет.
