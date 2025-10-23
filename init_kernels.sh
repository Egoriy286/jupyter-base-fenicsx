#!/bin/bash
set -e

echo "Инициализация FEniCSx kernels..."

# Проверяем наличие dolfinx
if ! python3 -c "import dolfinx; print(f'FEniCSx версия: {dolfinx.__version__}')" 2>/dev/null; then
    echo "Ошибка: FEniCSx не установлен!"
    exit 1
fi

# === Установка kernelspec для режима Complex ===
echo "Установка kernel: fenics-complex..."
/opt/activate_fenics_complex.sh -m ipykernel install --system \
    --name="fenics-complex" \
    --display-name="FEniCSx (Complex Mode)" 2>/dev/null || \
echo "Внимание: режим Complex может быть недоступен"

# === Установка kernelspec для режима Real ===
echo "Установка kernel: fenics-real..."
/opt/activate_fenics_real.sh -m ipykernel install --system \
    --name="fenics-real" \
    --display-name="FEniCSx (Real Mode)" 2>/dev/null || \
echo "Внимание: режим Real может быть недоступен"

echo "Инициализация завершена!"