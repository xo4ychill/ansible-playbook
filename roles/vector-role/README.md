# Vector Role for Ansible

[![Ansible Role](https://img.shields.io/ansible/role/d/your_namespace/vector_role)](https://galaxy.ansible.com/your_namespace/vector_role)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Vector Version](https://img.shields.io/badge/vector-0.37.1-blue)](https://vector.dev)

> 🚀 Роль для установки и настройки [Vector](https://vector.dev/) — высокопроизводительного агента сбора, трансформации и маршрутизации логов.

## 📋 Оглавление

- [Требования](#-требования)
- [Быстрый старт](#-быстрый-старт)
- [Переменные роли](#-переменные-роли)
- [Примеры использования](#-примеры-использования)
- [Интеграция с ClickHouse](#-интеграция-с-clickhouse)
- [Безопасность](#-безопасность)
- [Тестирование](#-тестирование)
- [Contributing](#-contributing)
- [License](#-license)

## 🔧 Требования

- **Ansible** >= 2.14
- **Python 3** на контроллере и целевых хостах
- **Доступ к интернету** для скачивания бинарников с GitHub Releases
- **sudo-права** на целевых хостах

## 🚀 Быстрый старт

### 1. Установка роли

```bash
# Через Ansible Galaxy (после публикации)
ansible-galaxy install your_namespace.vector_role

# Или из локального репозитория
git clone https://github.com/yourusername/vector-role.git roles/vector-role