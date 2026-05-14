# Ansible Playbook: ClickHouse + Vector + Lighthouse Stack

[![Status](https://img.shields.io/badge/Status-Production--Ready-green)](#)
[![Ansible Version](https://img.shields.io/badge/ansible-%3E%3D2.14-red.svg)](https://docs.ansible.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)




> 📦 Автоматизированное развёртывание стека для сбора, хранения и визуализации логов: **ClickHouse** (БД) → **Vector** (агент) → **Lighthouse** (UI).

---

## 📋 Содержание

- [Ansible Playbook: ClickHouse + Vector + Lighthouse Stack](#ansible-playbook-clickhouse--vector--lighthouse-stack)
  - [📋 Содержание](#-содержание)
  - [🔍 Обзор](#-обзор)
    - [✨ Особенности](#-особенности)
  - [🏗️ Архитектура](#️-архитектура)
    - [Поток данных](#поток-данных)
  - [⚙️ Требования](#️-требования)
    - [Установка зависимостей на контроллере](#установка-зависимостей-на-контроллере)
    - [📁 Структура проекта](#-структура-проекта)
  - [🚀 Быстрый старт](#-быстрый-старт)
  - [🧩 Роли и параметры](#-роли-и-параметры)
  - [📊 Переменные](#-переменные)
  - [🗂️ Инвентарь](#️-инвентарь)
  - [▶️ Запуск плейбука](#️-запуск-плейбука)
  - [🏷️ Теги для выборочного выполнения](#️-теги-для-выборочного-выполнения)
  - [🔐 Безопасность](#-безопасность)
  - [🛠️ Устранение неполадок](#️-устранение-неполадок)
      - [Частые проблемы и решения](#частые-проблемы-и-решения)

---

## 🔍 Обзор

Данный Ansible-проект предназначен для автоматизированного развёртывания отказоустойчивого стека мониторинга и логирования:
```
| Компонент | Назначение | Порт | ОС |
|-----------|-----------|------|-----|
| **ClickHouse** | Column-oriented БД для хранения логов | `8123` (HTTP), `9000` (TCP) | RHEL-family |
| **Vector** | Агент сбора и маршрутизации логов | — | Ubuntu |
| **Lighthouse** | Веб-интерфейс для визуализации | `80` (Nginx) | Debian |
```

### ✨ Особенности

- 🎯 **Идемпотентность**: Повторный запуск не ломает конфигурацию
- 🔐 **Безопасность**: SSH hardening, чувствительные данные через `lookup('env')`
- 🧠 **Адаптивность**: Авто-тюнинг для маломощных ВМ (swap, OOM-killer)
- 🔄 **Модульность**: Каждая роль изолирована и переиспользуема
- 🏷️ **Теги**: Гибкий запуск отдельных компонентов
- 📦 **Кроссплатформенность**: Поддержка Debian/Ubuntu и RHEL/CentOS/AlmaLinux

---

## 🏗️ Архитектура

```
┌─────────────────────────────────────────────────┐
│ Ansible Controller                              │
│ • site.yml (orchestrator)                       │
│ • group_vars/, host_vars/ (конфигурация)        │
│ • roles/ (bootstrap, system_tuning, ...)        │
└─────────────────┬───────────────────────────────┘
│ SSH (key-based)
▼
┌─────────────────────────────────────────────────┐
│ Inventory                                       │
│ • clickhouse: AlmaLinux/Rocky/CentOS (БД)       │
│ • vector: Ubuntu (агент сбора)                  │
│ • lighthouse: Debian (веб-интерфейс)            │
└─────────────────────────────────────────────────┘
```

### Поток данных

[Приложения]
│
▼
[Vector Agent] ──batch/timeout──► [ClickHouse: logs.events]
│
▼
[Lighthouse UI] ◄──[Пользователь]


---

## ⚙️ Требования

| Компонент | Версия | Примечание |
|-----------|--------|------------|
| **Ansible** | ≥ 2.14 | Рекомендуется 2.15+ |
| **Python** | ≥ 3.8 | На контроллере и управляемых хостах |
| **SSH** | OpenSSH 7.0+ | Key-based аутентификация |
| **Доступ** | sudo/root | На всех target-хостах |

### Установка зависимостей на контроллере

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y ansible python3-pip git

# RHEL/CentOS/AlmaLinux
sudo dnf install -y ansible python3-pip git

# Установка коллекций (если используются)
ansible-galaxy install -r requirements.yml
```

### 📁 Структура проекта

```
.
├── ansible.cfg                 # Глобальная конфигурация Ansible
├── site.yml                    # Главный плейбук (orchestrator)
├── requirements.yml            # Внешние зависимости (роли/коллекции)
├── inventory/
│   └── prod.yml                # Production-инвентарь (группы + vars)
├── group_vars/
│   ├── all.yml                 # Глобальные дефолты (безопасность, tuning)
│   ├── clickhouse.yml          # Переменные для группы ClickHouse
│   ├── vector.yml              # Переменные для группы Vector
│   └── lighthouse.yml          # Переменные для группы Lighthouse
├── host_vars/
│   ├── clickhouse-01.yml       # IP и ОС для clickhouse-01
│   ├── vector-01.yml           # IP для vector-01
│   └── lighthouse-01.yml       # IP для lighthouse-01
└── roles/
    ├── bootstrap/
    │   ├── defaults/main.yml   # Дефолты для установки Python
    │   └── tasks/main.yml      # Raw-скрипты подготовки хостов
    └── system_tuning/
        ├── defaults/main.yml   # Параметры тюнинга (RAM, swap, OOM)
        ├── tasks/main.yml      # Логика оптимизации
        └── handlers/main.yml   # Обработчики (systemd reload)
```

💡 Внешние роли (clickhouse, vector-role, lighthouse-role) подключаются через requirements.yml из Git-репозиториев.

## 🚀 Быстрый старт

1. Клонирование и подготовка

```bash
git clone <repository-url>
cd <project-directory>

# Проверка синтаксиса
ansible-playbook site.yml --syntax-check

# Проверка подключения к хостам
ansible all -m ping -i inventory/prod.yml
```
2. Настройка чувствительных данных

```bash
# Установите пароль ClickHouse через переменную окружения (рекомендуется)
export CLICKHOUSE_PASSWORD="your_strong_password"

# ИЛИ отредактируйте дефолт в group_vars/all.yml (только для dev!)
# vector_clickhouse_password: "changeme"
```

3. Запуск полного развёртывания

```bash
# Dry-run (проверка без изменений)
ansible-playbook site.yml --check --diff

# Полное выполнение
ansible-playbook site.yml

# С подробным выводом
ansible-playbook site.yml -vvv
```

4. Проверка результата

```bash
# Проверка ClickHouse
curl http://<clickhouse-host>:8123/ping
# Ответ: Ok.

# Проверка Vector
systemctl status vector

# Проверка Lighthouse
curl http://<lighthouse-host>/
```

## 🧩 Роли и параметры

- `bootstrap`
Подготовка "голых" хостов: установка Python3 для работы Ansible-модулей.

|   Variable  |Type         |Default      |Description|
|-------------|-------------|-------------|-------------|
|`bootstrap_python_debian`|string|apt-get update -qq && apt-get install -y -qq python3-minimal python3-simplejson|Raw-скрипт для установки Python на Debian/Ubuntu|
|`bootstrap_python_redhat`|string|yum install -y -q python3 python3-libselinux|Raw-скрипт для установки Python на RHEL-family|

    Особенности:
      - ✅ Использует модуль raw (работает до установки Python)
      - ✅ Авто-определение семейства ОС через /etc/*-release
      - ✅ check_mode: false — выполняется даже в режиме dry-run
      - ✅ changed_when: false — не помечает чтение как изменение

- `system_tuning`
Оптимизация системных параметров для маломощных ВМ (< 2 ГБ ОЗУ).

    - Variables
        | Variable                          | Type   | Default  | Description                                              |
        |-----------------------------------|--------|----------|----------------------------------------------------------|
        | `tuning_low_memory_threshold_mb`  | int    | `2048`   | Порог ОЗУ (МБ) для включения тюнинга                     |
        | `tuning_swap_size`                | string | `"2G"`   | Размер swap-файла                                        |
        | `tuning_swappiness`               | int    | `10`     | Приоритет RAM над swap (0–100)                           |
        | `tuning_oom_kill_allocating_task` | int    | `1`      | Убивать задачу-источник OOM, а не случайный процесс      |
        | `tuning_systemd_memory_low`       | string | `"500M"` | Минимальная память для systemd-юнитов (мягкий резерв)    |
        | `tuning_systemd_memory_high`      | string | `"2G"`   | Мягкий лимит памяти, после которого начинается троттлинг |

    - Handlers
        |Handler|Trigger|Action|
        |-------------|-------------|-------------|
        |`reload systemd`|Изменение memory.conf|daemon_reload: true, daemon_reexec: true|

- `clickhouse` (внешняя роль)
Развёртывание ClickHouse сервера.

    - Variables
        | Variable                     | Type   | Default                                                              | Description                       |
        |------------------------------|--------|----------------------------------------------------------------------|-----------------------------------|
        | `clickhouse_apt_repo`        | string | `https://packages.clickhouse.com/deb`                                | APT-репозиторий для Debian/Ubuntu |
        | `clickhouse_rpm_repo_url`    | string | `https://packages.clickhouse.com/rpm/clickhouse.repo`                | RPM-репозиторий для RHEL-family   |
        | `clickhouse_repo_key`        | string | `https://packages.clickhouse.com/rpm/stable/repodata/repomd.xml.key` | GPG-ключ репозитория              |
        | `clickhouse_packages`        | list   | `[clickhouse-server, clickhouse-client]`                             | Пакеты для установки              |
        | `clickhouse_health_url`      | string | `http://localhost:8123/ping`                                         | Endpoint для healthcheck          |
        | `clickhouse_health_expected` | string | `"Ok.\n"`                                                            | Ожидаемый ответ healthcheck       |
        | `clickhouse_database`        | string | `"logs"`                                                             | БД для интеграции с Vector        |
        | `clickhouse_table`           | string | `"events"`                                                           | Таблица для хранения логов        |
        | `clickhouse_endpoint`        | string | `http://{{ ansible_host }}:8123`                                     | URL подключения к ClickHouse      |
        | `clickhouse_max_connections` | int    | `100`                                                                | Максимальное число соединений     |
        | `clickhouse_listen_port`     | int    | `8123`                                                               | HTTP-порт для запросов            |
        | `clickhouse_tcp_port`        | int    | `9000`                                                               | Native TCP-порт для клиентов      |

- `vector-role` (внешняя роль)
Установка и конфигурация агента Vector для отправки логов в ClickHouse.
    - Variables
        | Variable                     | Type   | Default                                                    | Description                                   |
        |------------------------------|--------|------------------------------------------------------------|-----------------------------------------------|
        | `vector_dependencies`        | list   | `[curl, ca-certificates, xz-utils, gzip, file]`            | Пакеты для установки зависимостей             |
        | `vector_version`             | string | `"0.37.1"`                                                 | Версия Vector для загрузки                    |
        | `vector_install_dir`         | string | `"/opt/vector"`                                            | Директория установки бинарника                |
        | `vector_config_dir`          | string | `"/etc/vector"`                                            | Директория конфигурационных файлов            |
        | `vector_config_file`         | string | `"{{ vector_config_dir }}/vector.toml"`                    | Полный путь к конфигу                         |
        | `vector_log_dir`             | string | `"/var/log/vector"`                                        | Директория для логов агента                   |
        | `vector_github_base`         | string | `https://github.com/vectordotdev/vector/releases/download` | Базовый URL GitHub Releases                   |
        | `vector_version_tag`         | string | `"v{{ vector_version }}"`                                  | Тег версии с префиксом 'v'                    |
        | `vector_arch`                | string | `x86_64/aarch64`                                           | Архитектура (авто-определение)                |
        | `vector_os`                  | string | `unknown-linux-gnu`                                        | OS target для бинарника                       |
        | `vector_filename`            | string | *(динамический)*                                           | Имя архива: `vector-{ver}-{arch}-{os}.tar.gz` |
        | `vector_url`                 | string | *(динамический)*                                           | Полный URL для загрузки                       |
        | `vector_checksum`            | string | `""`                                                       | SHA256 для проверки целостности (опционально) |
        | `vector_clickhouse_endpoint` | string | *(динамический)*                                           | URL ClickHouse из инвентаря или fallback      |
        | `vector_clickhouse_database` | string | `"{{ clickhouse_database }}"`                              | Целевая база данных                           |
        | `vector_clickhouse_table`    | string | `"{{ clickhouse_table }}"`                                 | Целевая таблица                               |
        | `vector_clickhouse_user`     | string | `"default"`                                                | Пользователь для аутентификации               |
        | `vector_clickhouse_password` | string | `{{ lookup('env', 'CLICKHOUSE_PASSWORD') }}`               | Пароль (env > дефолт)                         |
        | `vector_batch_max_events`    | int    | `5000`                                                     | Отправлять батч после N событий               |
        | `vector_batch_timeout_secs`  | int    | `2`                                                        | Или через N секунд таймаута                   |
        | `vector_output_path`         | string | `"{{ vector_log_dir }}/output.log"`                        | Fallback-лог для отладки                      |

- `lighthouse-role` (внешняя роль)
Развёртывание веб-интерфейса Lighthouse
    - Variables
        | Variable                       | Type   | Default                                       | Description                                   |
        |--------------------------------|--------|-----------------------------------------------|-----------------------------------------------|
        | `lighthouse_packages`          | list   | `[nginx, git, curl]`                          | Пакеты для установки веб-сервера и VCS        |
        | `lighthouse_repo`              | string | `https://github.com/xo4ychill/lighthouse.git` | Git-репозиторий приложения                    |
        | `lighthouse_dir`               | string | `"/opt/lighthouse"`                           | Целевая директория для клонирования           |
        | `lighthouse_version`           | string | `"master"`                                    | Ветка или тег для checkout (напр. `"v1.0.0"`) |
        | `lighthouse_nginx_port`        | int    | `80`                                          | Порт, на котором слушает Nginx                |
        | `lighthouse_nginx_server_name` | string | `"_"`                                         | Server name (catch-all по IP)                 |
        | `lighthouse_nginx_root`        | string | `"{{ lighthouse_dir }}"`                      | Document root для Nginx                       |
        | `lighthouse_nginx_log_dir`     | string | `"/var/log/nginx/lighthouse"`                 | Директория для логов доступа/ошибок           |

## 📊 Переменные

- `Глобальные (group_vars/all.yml)`

    | Variable               | Default                                     | Description                              |
    |------------------------|---------------------------------------------|------------------------------------------|
    | `strict_host_checking` | `"yes"` (prod) / `"accept-new"` (dev)       | Значение `StrictHostKeyChecking` для SSH |
    | `ssh_key_path`         | `"~/.ssh/id_ed25519"`                       | Путь к приватному SSH-ключу              |
    | `default_ansible_user` | `"yc-user"`                                 | Пользователь для SSH-подключения         |
    | `ansible_ssh_timeout`  | `30`                                        | Таймаут SSH-соединения (секунды)         |
    | `ansible_ssh_retries`  | `3`                                         | Количество повторных попыток подключения |
    | `common_packages`      | `[curl, gnupg, ca-certificates]`            | Базовые пакеты для всех хостов           |
    | `environment_name`     | `"{{ ansible_env.ENV \| default('dev') }}"` | Идентификатор окружения (dev/stage/prod) |

- `Групповые переменные`

    - [group_vars/clickhouse.yml](group_vars/clickhouse.yml)
    - [roup_vars/vector.yml](group_vars/vector.yml)
    - [group_vars/lighthouse.yml](host_vars/lighthouse-01.yml)

- `Хост-специфичные переменные`

    | File                | Variable             | Example            | Purpose                                          |
    |---------------------|----------------------|--------------------|--------------------------------------------------|
    | `clickhouse-01.yml` | `ch_host_ip`         | `"111.88.244.167"` | IP-адрес хоста ClickHouse                        |
    | `vector-01.yml`     | `vector_host_ip`     | `"51.250.70.164"`  | IP-адрес хоста Vector                            |
    | `lighthouse-01.yml` | `lighthouse_host_ip` | `"111.88.247.242"` | IP-адрес хоста Lighthouse                        |

## 🗂️ Инвентарь

- `Файл:` [inventory/prod.yml](inventory/prod.yml)

## ▶️ Запуск плейбука

- Базовые команды

```bash
# Проверка синтаксиса
ansible-playbook site.yml --syntax-check

# Dry-run (без внесения изменений)
ansible-playbook site.yml --check --diff

# Полное выполнение
ansible-playbook site.yml

# Выполнение с подробным логом (уровень 3)
ansible-playbook site.yml -vvv

# Запуск только для конкретной группы хостов
ansible-playbook site.yml --limit clickhouse

# Запуск с указанием альтернативного инвентаря
ansible-playbook site.yml -i inventory/staging.yml
```

- Использование тегов

```bash
# Только подготовка хостов (установка Python)
ansible-playbook site.yml --tags bootstrap

# Только системный тюнинг
ansible-playbook site.yml --tags tuning

# Только развёртывание БД
ansible-playbook site.yml --tags clickhouse

# Развёртывание Vector и ClickHouse
ansible-playbook site.yml --tags vector,clickhouse

# Исключить вектор из запуска
ansible-playbook site.yml --skip-tags vector

# Запуск с конкретного шага
ansible-playbook site.yml --start-at-task "Create swap file"
```

## 🏷️ Теги для выборочного выполнения

| Tag                | Component       | Host Group   | Description                                  |
|--------------------|-----------------|--------------|----------------------------------------------|
| `bootstrap`        | Python install  | `all`        | Установка Python3 на "голые" хосты           |
| `always`           | All roles       | `all`        | Запускать всегда, даже при фильтрации тегов  |
| `tuning`, `system` | system_tuning   | `all`        | Системный тюнинг (swap, OOM, systemd limits) |
| `clickhouse`, `db` | clickhouse      | `clickhouse` | Развёртывание и настройка ClickHouse         |
| `vector`, `agent`  | vector-role     | `vector`     | Установка и конфигурация агента Vector       |
| `lighthouse`, `ui` | lighthouse-role | `lighthouse` | Развёртывание веб-интерфейса Lighthouse      |

## 🔐 Безопасность

1. `SSH Hardening`

```yaml
# group_vars/all.yml
strict_host_checking: "yes"  # Вместо "accept-new" в production
ssh_key_path: "/secure/path/to/key"  # Не в home-директории
ansible_ssh_common_args: >-
  -o StrictHostKeyChecking=yes
  -o UserKnownHostsFile=/home/ansible/.ssh/known_hosts
```

2. `Sensitive Data Management`

```bash
# ✅ Используйте переменные окружения
export CLICKHOUSE_PASSWORD="super_secret_password"
ansible-playbook site.yml

# ✅ Или используйте Ansible Vault
ansible-vault encrypt group_vars/secrets.yml
ansible-playbook site.yml --ask-vault-pass
```

3. `Vault File Structure Example`

```yaml
# group_vars/secrets.yml (encrypted)
clickhouse_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          33363...encrypted_content...
vector_clickhouse_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          44474...encrypted_content...
```
4. `Рекомендации`

    - Используйте NOPASSWD в sudo только для конкретных команд
    - Ограничьте доступ к /etc/vector/, /etc/clickhouse-server/
    - Регулярно ротируйте SSH-ключи и пароли

5. `Audit Logging`

```bash
# Логирование всех изменений
ansible-playbook site.yml --start-at-task "Apply systemd memory tuning" -vvv > deploy_$(date +%Y%m%d).log

# Проверка идемпотентности
ansible-playbook site.yml --check --diff | tee audit_check.log
```

## 🛠️ Устранение неполадок

#### Частые проблемы и решения
| Symptom                         | Possible Cause                   | Solution                                                               |
|---------------------------------|----------------------------------|------------------------------------------------------------------------|
| `Failed to connect to host`     | Wrong SSH key or user            | Check `ansible_user`, `ssh_key_path` in `group_vars/all.yml`           |
| `Python not found`              | Host without Python3             | Ensure `bootstrap` role runs first; check `ansible_python_interpreter` |
| `ClickHouse connection refused` | DB not running or port blocked   | `systemctl status clickhouse-server`; check firewall rules             |
| `Vector failed to start`        | Invalid config or password       | Check `/etc/vector/vector.toml`; verify `CLICKHOUSE_PASSWORD` env var  |
| `Nginx 502 Bad Gateway`         | Lighthouse not cloned or running | Check `/opt/lighthouse` exists; run `nginx -t`                         |
| `Swap not created`              | RAM >= threshold                 | Check `ansible_memtotal_mb`; adjust `tuning_low_memory_threshold_mb`   |