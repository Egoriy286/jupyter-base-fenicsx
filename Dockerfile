FROM ubuntu:22.04

# Устанавливаем системные пакеты
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    python3-pip \
    libgl1-mesa-glx \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    wget build-essential python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем Miniconda
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /root/miniconda3 && \
    rm /tmp/miniconda.sh && \
    /root/miniconda3/bin/conda init bash

ENV PATH=/root/miniconda3/bin:$PATH

RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main

RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
# Создаём conda-окружение с dolfinx и зависимостями
RUN conda create -n fenicsx -c conda-forge python=3.10 fenics-dolfinx mpich pyvista meshio jupyter ipykernel -y && \
    conda create -n fenicsx-complex -c conda-forge python=3.10 fenics-dolfinx petsc=*=complex* mpich pyvista meshio jupyter ipykernel -y && \
    conda create -n fenics-legacy -c conda-forge python=3.10 fenics-dolfin mpich jupyter ipykernel -y

RUN /bin/bash -c "source activate fenicsx && python -m ipykernel install --user --name=fenicsx --display-name 'FEniCSx (real)'" && \
    /bin/bash -c 'source activate fenicsx-complex && python -m ipykernel install --user --name=fenicsx-complex --display-name "FEniCSx (complex)"' && \
    /bin/bash -c 'source activate fenics-legacy && python -m ipykernel install --user --name=fenics-legacy --display-name "FEniCS Legacy"'


WORKDIR /workspace

# Обновляем pip и устанавливаем Jupyter Lab и дополнительные библиотеки
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir \
    jupyterlab \
    notebook \
    ipywidgets \
    matplotlib \
    numpy \
    scipy \
    pandas \
    meshio \
    pyvista

# Настраиваем права доступа
RUN chmod -R 777 /workspace

# Открываем порт для Jupyter Lab
EXPOSE 8888

# Запуск Jupyter Lab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]