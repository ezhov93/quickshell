## 1. Контракт и источник

- [x] 1.1 Обновить `install.sh` и документацию с контрактом `configs/` → `~/.config/`; проверить, что package manager, `sudo`, reload и запуск сессии не добавлены.
- [x] 1.2 Добавить рекурсивную проверку и staging всех файлов `configs/` с сохранением относительных путей; проверить текущие `configs/hypr/*` и запрет runtime state.

## 2. Безопасная установка

- [x] 2.1 Реализовать backup только `~/.config/quickshell` и управляемых подпапок `~/.config/<configs-child>`; проверить сохранность посторонних файлов в `~/.config`.
- [x] 2.2 Реализовать установку staged shell/configs и rollback при ошибке; проверить повторный запуск и сообщение путей backup.
- [x] 2.3 Вывести отдельную команду ручного применения конфигурации без выполнения `hyprctl reload`; проверить root guard и отсутствие live-session действий.

## 3. Документация и проверки

- [x] 3.1 Обновить `docs/project-context.md`, `docs/architecture.md`, `docs/testing.md`, `docs/spec-status.md`, `README.md` и CHANGELOG с новой границей установщика.
- [x] 3.2 Выполнить `bash -n install.sh`, `openspec validate "install-configs" --strict`, `openspec validate --specs --strict`, `git diff --check` и тесты установщика в отдельной среде без замены реального `~/.config`.
- [x] 3.3 Владелец подготовленной сессии вручную применяет профиль и проверяет конфигурации; агент и installer сессию не запускают, не перезагружают и не завершают.
