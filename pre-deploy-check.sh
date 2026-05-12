
---

## ✅ Финальная проверка перед запуском

```bash
#!/bin/bash
# scripts/pre-deploy-check.sh

set -e

echo "🔍 Running pre-deployment checks..."

# 1. Синтаксис
echo "✅ Checking playbook syntax..."
ansible-playbook site.yml --syntax-check

# 2. Ping хостов
echo "✅ Testing SSH connectivity..."
ansible all -m ping -i inventory/prod.yml

# 3. Проверка vault (если используется)
if grep -q "vault" group_vars/*.yml 2>/dev/null; then
    echo "✅ Vault-файлы обнаружены, проверьте доступ..."
    ansible-playbook site.yml -i inventory/prod.yml --check --ask-vault-pass --diff
else
    echo "✅ Running dry-run..."
    ansible-playbook site.yml -i inventory/prod.yml --check --diff
fi

echo "🎉 All checks passed! Ready to deploy."