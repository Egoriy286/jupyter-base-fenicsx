FROM ubuntu:22.04

# === Переменные окружения ===
ENV DEBIAN_FRONTEND=noninteractive
ENV JUPYTERHUB_PORT=8000
ENV JUPYTERHUB_IP=0.0.0.0
ENV JUPYTERHUB_DATA_PATH=/opt/jupyterhub_data
ENV NOTEBOOKS_PATH=/opt/notebooks
ENV PYTHONUNBUFFERED=1
ENV TZ=UTC
ENV FENICS_COMPLEX_MODE="source /usr/share/dolfinx/dolfinx-complex-mode"
ENV FENICS_REAL_MODE="source /usr/share/dolfinx/dolfinx-real-mode"

# === Установка зависимостей ===
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    software-properties-common \
    wget \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# === Добавление репозитория FEniCSx ===
RUN add-apt-repository ppa:fenics-packages/fenics && \
    apt-get update && \
    apt-get install -y fenicsx && \
    rm -rf /var/lib/apt/lists/*

# === Установка Python пакетов ===
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

RUN pip install --no-cache-dir \
    jupyterhub \
    jupyterlab \
    nativeauthenticator \
    notebook \
    ipykernel \
    numpy \
    scipy \
    matplotlib \
    pandas \
    sympy \
    meshio \
    h5py

# === Создание директорий ===
RUN mkdir -p ${JUPYTERHUB_DATA_PATH} && \
    mkdir -p ${NOTEBOOKS_PATH} && \
    chmod 755 ${JUPYTERHUB_DATA_PATH} && \
    chmod 755 ${NOTEBOOKS_PATH}

# === Создание конфигурационного файла JupyterHub ===
RUN mkdir -p /etc/jupyterhub

RUN cat > /etc/jupyterhub/jupyterhub_config.py << 'EOF'
c = get_config()

# === Основные параметры ===
import os
c.JupyterHub.ip = os.getenv('JUPYTERHUB_IP', '0.0.0.0')
c.JupyterHub.port = int(os.getenv('JUPYTERHUB_PORT', 8000))
c.JupyterHub.data_files_path = os.getenv('JUPYTERHUB_DATA_PATH', '/opt/jupyterhub_data')

# === Простая аутентификация ===
c.JupyterHub.authenticator_class = 'nativeauthenticator.NativeAuthenticator'

# Разрешаем регистрацию (только один раз для трёх пользователей)
c.NativeAuthenticator.open_signup = True
c.NativeAuthenticator.check_common_password = True
c.NativeAuthenticator.minimum_password_length = 8

# === Спавнер обычного процесса ===
c.JupyterHub.spawner_class = 'simple'

# === Каталог для ноутбуков ===
notebooks_dir = os.getenv('NOTEBOOKS_PATH', '/opt/notebooks')
c.Spawner.notebook_dir = notebooks_dir
c.Spawner.default_url = '/lab'
c.Spawner.args = ['--NotebookApp.token=']

# === Логи ===
c.JupyterHub.log_level = 'INFO'

# === Дополнительные параметры ===
c.JupyterHub.admin_users = set()
c.JupyterHub.allow_named_servers = False
c.JupyterHub.shutdown_on_logout = True
EOF

# === Создание примера ноутбука ===
RUN cat > ${NOTEBOOKS_PATH}/example_fenics.py << 'EOF'
# FEniCSx Example
import dolfinx
import numpy as np
from mpi4py import MPI

print("FEniCSx успешно установлен!")
print(f"Версия dolfinx: {dolfinx.__version__}")
EOF

# === Создание скриптов для активации режимов FEniCSx ===
RUN cat > /opt/activate_fenics_complex.sh << 'EOF'
#!/bin/bash
source /usr/share/dolfinx/dolfinx-complex-mode
exec python3 "$@"
EOF

RUN cat > /opt/activate_fenics_real.sh << 'EOF'
#!/bin/bash
source /usr/share/dolfinx/dolfinx-real-mode
exec python3 "$@"
EOF

RUN chmod +x /opt/activate_fenics_complex.sh /opt/activate_fenics_real.sh

# === Установка kernelspec для режима Complex ===
RUN /opt/activate_fenics_complex.sh -m ipykernel install --user \
    --name="fenics-complex" \
    --display-name="FEniCSx (Complex Mode)"

# === Установка kernelspec для режима Real ===
RUN /opt/activate_fenics_real.sh -m ipykernel install --user \
    --name="fenics-real" \
    --display-name="FEniCSx (Real Mode)"

# === Рабочая директория ===
WORKDIR /opt/jupyterhub

# === Expose порт ===
EXPOSE ${JUPYTERHUB_PORT}

# === Запуск JupyterHub ===
CMD ["jupyterhub", "-f", "/etc/jupyterhub/jupyterhub_config.py"]
