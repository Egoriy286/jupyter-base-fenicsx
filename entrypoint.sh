#!/bin/bash
set -e

echo "🚀 JupyterHub запускается..."

# === Инициализация FEniCSx kernels при первом запуске ===
if [ ! -d "/root/.local/share/jupyter/kernels/fenics-real" ]; then
    echo "📦 Первый запуск! Инициализация kernels..."
    /opt/init_kernels.sh
else
    echo "✓ Kernels уже установлены."
fi

echo ""
echo "✓ Запуск JupyterHub..."

# === Запуск основной команды ===
exec "$@"

