#!/bin/bash
# Активация режима complex для FEniCSx
set -e

# Если файл существует, используем его
if [ -f "/usr/share/dolfinx/dolfinx-complex-mode" ]; then
    source /usr/share/dolfinx/dolfinx-complex-mode
fi

exec python3 "$@"

