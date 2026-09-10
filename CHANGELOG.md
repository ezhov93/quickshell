# Changelog

Все значимые изменения проекта документируются в этом файле.

Формат основан на [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), а версии следуют [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Документирован rolling Gitflow и связь OpenSpec change с feature-веткой.
- Добавлен общий UI-компонент `BarButton` для капсул и интерактивных элементов панели.

### Changed

- Текущая работа ведётся через `develop`, стабильные релизы — через `main`.
- Установщик разворачивает `configs/` в пользовательский `~/.config/` с backup управляемых путей, не применяя конфигурацию автоматически.
- Для OpenSpec change зафиксирован порядок archive → push feature → squash merge в `develop` → push `develop` → проверка merge → удаление feature-ветки.
- Перед каждым push требуется синхронизация с remote через `fetch` и `pull --ff-only`; при расхождении push останавливается.

### Deprecated

### Removed

### Fixed

### Security
