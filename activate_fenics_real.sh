#!/bin/bash
set -e

source /usr/share/dolfinx/dolfinx-real-mode
exec python3 "$@"
