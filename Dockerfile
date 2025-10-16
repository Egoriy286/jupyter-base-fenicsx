FROM jupyter/base-notebook:latest

USER root

# Установим системные зависимости
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgl1-mesa-glx \
        xvfb && \
    rm -rf /var/lib/apt/lists/*

# Установим mamba
RUN conda update -n base -c defaults conda -y && \
    conda install -n base -c conda-forge mamba -y

# Создаем conda-окружение с пакетами
RUN mamba create -n fenicsx-env -c conda-forge -y \
        fenics-dolfinx \
        mpich \
        pyvista \
        ipython \
        numpy \
        scipy \
        sympy \
        matplotlib \
        pandas \
        "scikit-fem[all]"

# Автоактивация окружения
RUN echo "conda activate fenicsx-env" >> /etc/profile.d/conda-fenicsx.sh

# Настройка Jupyter
RUN mkdir -p /home/jovyan/.jupyter && \
    echo "c.FileContentsManager.autosave_interval = 60000" >> /home/jovyan/.jupyter/jupyter_notebook_config.py

USER jovyan
WORKDIR /home/jovyan/work
