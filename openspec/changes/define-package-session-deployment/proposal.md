## Why

LPDE пока не имеет воспроизводимого слоя зависимостей, session wiring и deployment полного окружения. Нужно отдельно спроектировать эти границы, не расширяя текущий `install.sh`, который устанавливает только Quickshell runtime.

## What Changes

- Определить структуру `packages/`, `system/` и `install/`.
- Выбрать проверяемые версии Arch/Debian и владельца запуска сессии.
- Разделить package manifests, system units/portals/session wiring и deployment orchestration.
- Описать проверки, права, rollback и отсутствие повторного запуска компонентов.
- Не устанавливать пакеты и не менять живую сессию в рамках подготовки.

## Capabilities

### New Capabilities

Нет. Это архитектурное планирование будущей поставки.

### Modified Capabilities

Нет.

## Impact

Затрагиваются будущие `packages/`, `system/`, `install/`, session documentation и проверки. Текущий shell runtime и `install.sh` не меняются до отдельного решения.
