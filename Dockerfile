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
    jupyterhub-nativeauthenticator \
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

# === Копирование конфигурационных файлов ===
COPY jupyterhub_config.py /etc/jupyterhub/jupyterhub_config.py

# === Копирование скриптов активации режимов ===
COPY activate_fenics_complex.sh /opt/activate_fenics_complex.sh
COPY activate_fenics_real.sh /opt/activate_fenics_real.sh
RUN chmod +x /opt/activate_fenics_complex.sh /opt/activate_fenics_real.sh

# === Копирование скрипта инициализации ===
COPY init_kernels.sh /opt/init_kernels.sh
RUN chmod +x /opt/init_kernels.sh && /opt/init_kernels.sh

# === Рабочая директория ===
WORKDIR /opt/jupyterhub

# === Expose порт ===
EXPOSE ${JUPYTERHUB_PORT}

# === Запуск JupyterHub ===
CMD ["jupyterhub", "-f", "/etc/jupyterhub/jupyterhub_config.py"]