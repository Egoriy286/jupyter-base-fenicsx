#!/bin/bash
set -e

echo "Инициализация FEniCSx kernels..."

# === Установка kernelspec для режима Complex ===
echo "Установка kernel: fenics-complex..."
/opt/activate_fenics_complex.sh -m ipykernel install --system \
    --name="fenics-complex" \
    --display-name="FEniCSx (Complex Mode)"

# === Установка kernelspec для режима Real ===
echo "Установка kernel: fenics-real..."
/opt/activate_fenics_real.sh -m ipykernel install --system \
    --name="fenics-real" \
    --display-name="FEniCSx (Real Mode)"

echo "Kernels успешно установлены!"
