# Dockerfile: jupyter-fenicsx
FROM jupyter/base-notebook:latest

# Переключаемся на root для установки пакетов
USER root

# Установим mamba и conda-пакеты
RUN conda update -n base -c defaults conda -y && \
    conda install -n base -c conda-forge mamba -y

# Создаем conda-окружение fenicsx-env и устанавливаем пакеты
RUN mamba create -n fenicsx-env -c conda-forge -y \
        fenics-dolfinx \
        mpich \
        "pyvista[all]" \
        ipython \
        numpy \
        scipy \
        sympy \
        matplotlib \
        pandas \
        "scikit-fem[all]" \
        libgl1-mesa-glx \
        xvfb

# Автоактивация окружения fenicsx-env
RUN echo "conda activate fenicsx-env" >> /etc/profile.d/conda-fenicsx.sh

# Настройка Jupyter
RUN mkdir -p /home/jovyan/.jupyter && \
    echo "c.FileContentsManager.autosave_interval = 60000" >> /home/jovyan/.jupyter/jupyter_notebook_config.py

# Вернемся к пользователю jovyan
USER jovyan

# Рабочая директория
WORKDIR /home/jovyan/work