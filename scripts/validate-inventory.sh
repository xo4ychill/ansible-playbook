#!/bin/bash
# =============================================================================
# scripts/validate-inventory.sh — Валидация инвентаря перед запуском
# 💡 Проверяет наличие обязательных переменных и корректность ссылок
# =============================================================================

set -euo pipefail

INVENTORY_DIR="${1:-./inventory}"
ENV_FILE="${2:-.env}"

echo "🔍 Валидация инвентаря: $INVENTORY_DIR"

# Проверка наличия обязательных групп
for group in clickhouse vector lighthouse; do
    if ! grep -q "^$group:" "$INVENTORY_DIR"/prod.yml 2>/dev/null; then
        echo "⚠️  Группа '$group' не найдена в инвентаре"
        echo "💡 Добавьте секцию '$group:' в $INVENTORY_DIR/prod.yml"
    fi
done

# Проверка наличия шаблона host_vars
if [ ! -f "$INVENTORY_DIR/../host_vars/template.yml.example" ]; then
    echo "❌ Шаблон host_vars/template.yml.example не найден"
    exit 1
fi

# Проверка переменных окружения (если есть .env файл)
if [ -f "$ENV_FILE" ]; then
    echo "📋 Проверка переменных окружения из $ENV_FILE:"
    
    # Обязательные переменные для prod
    if grep -q "environment_name.*prod" "$INVENTORY_DIR/prod.yml" 2>/dev/null; then
        for var in CLICKHOUSE_PASSWORD; do
            if ! grep -q "^$var=" "$ENV_FILE" 2>/dev/null; then
                echo "❌ Обязательная переменная $var не задана в $ENV_FILE"
                echo "💡 Добавьте: $var=your_value"
                exit 1
            fi
        done
    fi
fi

echo "✅ Валидация пройдена"