## 1. Документация процесса

- [x] 1.1 Обновить `docs/git-workflow.md`: описать обязательный порядок archive → push feature → `merge --squash` в `develop` → push `develop` → проверка → удаление локальной и удалённой feature-ветки; проверить, что fast-forward не указан как целевой способ.
- [x] 1.2 Обновить `docs/openspec-workflow.md` тем же порядком и связать архивирование change с публикацией его feature-ветки; проверить согласованность с `docs/git-workflow.md`.
- [x] 1.3 Описать в документации rolling-релиз через squash merge `develop` → `main`, push и SemVer-тег; проверить наличие шага проверки перед удалением веток.

## 2. История и проверка

- [x] 2.1 Добавить запись в `CHANGELOG.md` в разделе `Unreleased/Changed`; проверить соответствие Keep a Changelog 1.1.0.
- [x] 2.2 Запустить `openspec validate "enforce-gitflow-push-squash-order" --strict`, `git diff --check` и отдельную проверку новых файлов; результат каждого этапа записать.
- [x] 2.3 Убедиться чтением `git diff`, что текущая история не переписывается и runtime-файлы не затронуты.
