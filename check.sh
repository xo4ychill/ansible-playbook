# 1. Проверка синтаксиса
ansible-playbook site.yml --syntax-check

# 2. Проверка подключения
ansible all -m ping -i inventory/prod.yml

# 3. Dry-run
ansible-playbook site.yml --check --diff -vvv

# 4. Полный запуск
ansible-playbook site.yml --ask-vault-pass

# 5. Запуск по тегам
ansible-playbook site.yml --tags clickhouse
ansible-playbook site.yml --tags vector,lighthouse