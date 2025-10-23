#!/bin/bash
# Активация режима real для FEniCSx
set -e

# Если файл существует, используем его
if [ -f "/usr/share/dolfinx/dolfinx-real-mode" ]; then
    source /usr/share/dolfinx/dolfinx-real-mode
fi

exec python3 "$@"

