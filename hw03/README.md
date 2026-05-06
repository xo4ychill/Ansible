# Домашнее задание к занятию 3 «Использование Ansible»

# 🚀 Ansible Playbook: ClickHouse + Vector + Lighthouse на Yandex Cloud

Автоматизированное развёртывание стека сбора, хранения и визуализации логов на виртуальных машинах Yandex Cloud. Плейбук настраивает безопасную, оптимизированную и полностью идемпотентную инфраструктуру без хардкода.

## Структура проекта
```
├── ansible.cfg                 # Конфигурация Ansible
├── inventory.yml               # Инвентарь хостов
├── site.yml                    # Главный плейбук
├── group_vars/                 # Групповые переменные
├── host_vars/                  # Хост-специфичные переменные
└── roles/                      # Роли (bootstrap, system_tuning, clickhouse, vector, lighthouse)
```

## 📦 Что делает этот Playbook

| Компонент | Роль | Описание |
|-----------|------|----------|
| 🔹 **Bootstrap** | Подготовка ОС | Автоматическая установка Python3 на "голые" VM (AlmaLinux/Ubuntu/Debian) через `raw`-модуль |
| 🔹 **System Tuning** | Оптимизация VM | Настройка Swap, OOM-killer, лимитов памяти systemd и `swappiness` для маломощных машин |
| 🔹 **ClickHouse** | База данных | Установка сервера БД, настройка репозиториев, healthcheck, запуск сервиса |
| 🔹 **Vector** | Агент сбора логов | Загрузка бинарника, создание системного пользователя, настройка `vector.toml`, systemd-юнит |
| 🔹 **Lighthouse + Nginx** | Веб-интерфейс | Клонирование репозитория (или создание fallback-заглушки), деплой Nginx, graceful reload |

**Ключевые особенности:**
- ✅ Полная идемпотентность и поддержка `--check --diff`
- ✅ Нулевой хардкод: все IP, пароли и версии вынесены в `group_vars` / `host_vars`
- ✅ Безопасность: пароли через `lookup('env')`, `StrictHostKeyChecking` настраивается, права `0640/0600`
- ✅ Обработка ошибок: retry-логика, валидация архивов, fallback-сценарии при недоступности Git-репо
- ✅ Кросс-платформенность: автоматическое определение семейства ОС (RHEL / Debian)

## ⚙️ Параметры конфигурации

Все параметры управляются через переменные. Ниже приведены ключевые настройки, которые можно переопределять.

### 🔐 Глобальные параметры (`group_vars/all.yml`)
| Переменная | Описание | По умолчанию |
|------------|----------|--------------|
| `clickhouse_password` | Пароль для ClickHouse | `your_secure_password` (переопределяется через env `CLICKHOUSE_PASSWORD`) |
| `strict_host_checking` | Режим проверки SSH-ключей | `accept-new` (`yes` в production) |
| `ansible_user` | Пользователь для SSH-подключения | `yc-user` |
| `ssh_key_path` | Путь к приватному SSH-ключу | `~/.ssh/id_ed25519` |
| `tuning_low_memory_threshold_mb` | Порог RAM для включения Swap (МБ) | `2048` |
| `tuning_swap_size` | Размер Swap-файла | `2G` |
| `tuning_swappiness` | Приоритет использования Swap | `10` |

### 🗄️ ClickHouse (`group_vars/clickhouse.yml`)
| Переменная | Описание |
|------------|----------|
| `clickhouse_packages` | Список пакетов для установки |
| `clickhouse_health_url` | URL для проверки доступности БД |
| `clickhouse_database` | Имя БД для логов |
| `clickhouse_table` | Имя таблицы для логов |
| `clickhouse_endpoint` | Адрес ClickHouse (формируется автоматически из `ansible_host`) |

### 📤 Vector (`group_vars/vector.yml`)
| Переменная | Описание |
|------------|----------|
| `vector_version` | Версия Vector агента |
| `vector_install_dir` | Путь установки бинарников |
| `vector_clickhouse_endpoint` | Адрес ClickHouse для отправки логов |
| `vector_batch_max_events` | Размер батча перед отправкой |
| `vector_checksum` | SHA-сумма архива (опционально) |

### 🌐 Lighthouse (`group_vars/lighthouse.yml`)
| Переменная | Описание |
|------------|----------|
| `lighthouse_repo` | URL Git-репозитория с UI |
| `lighthouse_dir` | Директория деплоя |
| `lighthouse_nginx_port` | Порт Nginx |
| `lighthouse_nginx_server_name` | `server_name` в конфиге Nginx |

> 💡 **Переменные окружения:**  
> `export CLICKHOUSE_PASSWORD="your_secure_password"`  
> Плейбук автоматически подхватит его через `lookup('env', 'CLICKHOUSE_PASSWORD')`.

## 🏷️ Доступные теги (Tags)

Используйте `--tags` для запуска конкретных компонентов или `--skip-tags` для их пропуска.

| Тег | Что запускает | Когда использовать |
|-----|---------------|-------------------|
| `bootstrap` | Установка Python на все хосты | Первоначальная подготовка VM |
| `tuning`, `system` | Настройка Swap, OOM, systemd limits | Оптимизация маломощных машин |
| `clickhouse`, `db` | Развёртывание ClickHouse | Установка/обновление БД |
| `vector`, `agent` | Установка и настройка Vector | Деплой агента сбора логов |
| `lighthouse`, `ui` | Деплой Lighthouse + Nginx | Развёртывание веб-интерфейса |
| `always` | Запускает `bootstrap` в любом случае | Встроенный тег Ansible (не требуется указывать вручную) |

**Примеры использования:**
```bash
# Запустить только установку БД и агента
ansible-playbook site.yml --tags "clickhouse,vector" -vv

# Пропустить тюнинг системы (если он уже настроен)
ansible-playbook site.yml --skip-tags "tuning" -vv

# Dry-run с выводом изменений
ansible-playbook site.yml --check --diff -vv

# Запуск только на одном хосте
ansible-playbook site.yml --limit AlmaLinux -vv

