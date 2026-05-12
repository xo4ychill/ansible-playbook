# Lighthouse Role for Ansible

[![Ansible Role](https://img.shields.io/ansible/role/d/your_namespace/lighthouse_role)](https://galaxy.ansible.com/your_namespace/lighthouse_role)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> 🚀 Роль для деплоя [Lighthouse UI](https://github.com/xo4ychill/lighthouse) с Nginx reverse proxy.

## 🔧 Требования

- Ansible >= 2.14
- Python 3 на контроллере и целевых хостах
- sudo-права на целевых хостах

## 🚀 Быстрый старт

```yaml
- name: Deploy Lighthouse UI
  hosts: lighthouse_hosts
  become: true
  roles:
    - role: lighthouse-role
      lighthouse_clickhouse_host: "clickhouse:8123"
      lighthouse_clickhouse_database: "logs"
      lighthouse_clickhouse_table: "events"