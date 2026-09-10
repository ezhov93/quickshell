## Why

Текущая документация описывает общий merge feature-ветки, но не фиксирует обязательный порядок публикации и squash merge. Из-за этого завершённая OpenSpec-задача может попасть в `develop` fast-forward-ом с промежуточными коммитами или быть удалена до публикации результата.

## What Changes

- Зафиксировать один обязательный цикл завершения OpenSpec change: архивирование, push feature-ветки, squash merge в `develop`, push `develop`, затем удаление локальной и удалённой feature-ветки.
- Зафиксировать проверку успешного merge перед удалением feature-ветки.
- Уточнить rolling-релиз: squash merge `develop` в `main`, push `main`, затем создание и push SemVer-тега.
- Зафиксировать, что уже выполненный ранее fast-forward не переписывается задним числом.

## Capabilities

### New Capabilities

Не добавляются: изменение относится к документации и процессу разработки.

### Modified Capabilities

Не изменяются: runtime-контракт LPDE не меняется.

## Impact

Затрагиваются `docs/git-workflow.md`, `docs/openspec-workflow.md`, `CHANGELOG.md` и архивируемые OpenSpec-артефакты. Внешние API, зависимости, графическая сессия и установщик не затрагиваются.
