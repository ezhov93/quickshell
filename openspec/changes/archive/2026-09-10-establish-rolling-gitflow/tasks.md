## 1. Документирование процесса

- [x] 1.1 Создать `docs/git-workflow.md` с ролями `develop`, `main`, feature/hotfix-ветками и правилами merge; проверить соответствие design.md и OpenSpec workflow.
- [x] 1.2 Описать связь одного `feature/<change-name>` с одним OpenSpec change, выполнение всех его `tasks.md` в этой ветке и правила удаления ветки; проверить пример на существующем change.

## 2. Версионирование и релиз

- [x] 2.1 Зафиксировать SemVer и аннотированные теги `vMAJOR.MINOR.PATCH`, правила повышения версии и запрет переписывания тегов; проверить release checklist.
- [x] 2.2 Описать rolling-релиз `develop` → `main`, hotfix merge-back и отсутствие release-веток; проверить сценарии обычного релиза и hotfix.
- [x] 2.3 Создать корневой `CHANGELOG.md` по Keep a Changelog 1.1.0: `Unreleased`, датированные версии и категории `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`; проверить формат заголовков и ссылок.

## 3. Миграция репозитория

- [x] 3.1 Проверить текущие refs, remote и отсутствие тегов; подготовить безопасную команду создания `develop` без запуска `git push` и без переписывания истории.
- [x] 3.2 Создать локальный `develop` от проверенного текущего commit; проверить, что `main`, рабочее дерево и история не изменились.
- [x] 3.3 Проверить default branch и branch protection на remote без изменения настроек; default branch видна как `origin/main`, branch protection недоступна из-за DNS-ошибки при обращении к GitHub (`not available`).

## 4. Проверка процесса

- [x] 4.1 Выполнить dry-run полного цикла feature → develop → main → tag в отдельном временном Git-репозитории; проверить имена веток, fast-forward/merge и тегирование.
- [x] 4.2 Обновить `docs/README.md` и `docs/openspec-workflow.md`, добавить ссылки на Git-процесс; проверить ссылки, OpenSpec validation и `git diff --check`.
