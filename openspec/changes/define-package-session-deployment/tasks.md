## 1. Контракт

- [ ] 1.1 Зафиксировать поддерживаемые версии Arch/Debian и источники пакетов; проверить, что снимок `extra/packages-*` не используется как manifest.
- [ ] 1.2 Сравнить systemd user units, UWSM и альтернативы по lifecycle, privileges, readiness, restart, cleanup и resource cost; подготовить решение.

## 2. План поставки

- [ ] 2.1 Определить контракты `packages/`, `system/` и `install/`; проверить отсутствие циклических зависимостей и изменений shell runtime.
- [ ] 2.2 Подготовить dry-run, rollback и session safety checklist; проверить, что агент не запускает и не изменяет пользовательскую графическую сессию.
