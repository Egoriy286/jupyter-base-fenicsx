#!/bin/bash
set -e

source /usr/share/dolfinx/dolfinx-complex-mode
exec python3 "$@"
