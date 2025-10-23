#!/bin/bash
set -e

# === Инициализация FEniCSx kernels при первом запуске ===
if [ ! -d "/root/.local/share/jupyter/kernels/fenics-complex" ]; then
    echo "Первый запуск! Инициализация FEniCSx kernels..."
    /opt/init_kernels.sh
else
    echo "FEniCSx kernels уже установлены."
fi

# === Запуск основной команды ===
exec "$@"