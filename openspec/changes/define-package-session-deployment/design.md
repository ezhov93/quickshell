## Context

Проект ориентирован на Arch и Debian, но полная установка и lifecycle сессии не подтверждены. Платформенные службы остаются внешними; собственный daemon требует отдельного обоснования.

## Goals / Non-Goals

**Goals:** спроектировать manifests, session ownership, privileges, readiness, restart, cleanup, rollback и безопасную проверку.

**Non-Goals:** не выбирать пакетный менеджер молча, не создавать units и не превращать текущий shell installer в установщик полного DE.

## Decisions

- `packages/` описывает зависимости по платформам и версиям.
- `system/` содержит декларации user services, portals и session wiring.
- `install/` оркестрирует deployment, но не владеет UI-логикой.
- Выбор systemd/UWSM/другой схемы выносится в отдельное решение после сравнения lifecycle и ресурсов.

## Risks / Trade-offs

- [Риск] Различия Arch/Debian попадут в shell → [Митигация] изолировать их в manifests/deployment.
- [Риск] Несогласованный владелец запустит компоненты дважды → [Митигация] сначала определить единственного владельца и cleanup.
- [Риск] Установка повредит пользовательскую сессию → [Митигация] dry-run, отдельная среда и rollback.

## Migration Plan

Инвентаризация зависимостей → сравнение lifecycle вариантов → выбор владельца → отдельные changes для manifests, units и deployment → контролируемая проверка на целевой системе.
