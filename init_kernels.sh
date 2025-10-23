#!/bin/bash
set -e

echo "Инициализация FEniCSx kernels..."

# Попытка найти где установлен dolfinx
echo "Поиск FEniCSx..."

# Проверка стандартных путей
if [ -f "/usr/bin/python3" ]; then
    # Просто используем стандартный python3 с установленными пакетами
    echo "Проверка FEniCSx через python3..."
    python3 << 'PYEOF'
try:
    import dolfinx
    print(f"✓ FEniCSx найден: версия {dolfinx.__version__}")
except ImportError as e:
    print(f"✗ FEniCSx не найден: {e}")
PYEOF
fi

# === Установка kernelspec для режима Real (по умолчанию) ===
echo ""
echo "Установка kernel: fenics-real..."
python3 -m ipykernel install --system \
    --name="fenics-real" \
    --display-name="FEniCSx (Real Mode)" || \
    echo "⚠ Ошибка при установке fenics-real"

# === Установка дополнительного Python kernel ===
echo ""
echo "Установка kernel: python3..."
python3 -m ipykernel install --system \
    --name="python3" \
    --display-name="Python 3" || \
    echo "⚠ Ошибка при установке python3"

echo ""
echo "✓ Инициализация завершена!"
