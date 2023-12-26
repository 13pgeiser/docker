# vim:set ft=dockerfile:
# VERSION=1
include(`debian_base.m4')

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#RUN wget https://raw.githubusercontent.com/root-project/cling/master/tools/packaging/cpt.py && \
#	chmod +x cpt.py && \
#	python3 cpt.py --check-requirements && ./cpt.py --create-dev-env Debug --with-workdir=./cling-build/

RUN set -x && \
    CONDA_VERSION=py310_23.3.1-0 ; \
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"; \
    SHA256SUM="aef279d6baea7f67940f16aad17ebe5f6aac97487c7c03466ff01f4819e5a651"; \
    wget "${MINICONDA_URL}" -O miniconda.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    sha256sum --check --status shasum && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

RUN /opt/conda/bin/conda install -y mamba -n base -c conda-forge

RUN /opt/conda/bin/mamba install -y -c conda-forge xeus-cling
RUN /opt/conda/bin/mamba install -y -c conda-forge jupyterlab

RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        wget \
        g++ \
        libstdc++6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN mkdir /notebooks
CMD /opt/conda/bin/jupyter lab --ip=0.0.0.0 --port=9999 --NotebookApp.token='' --NotebookApp.password='' --allow-root --notebook-dir='/notebooks'
#CMD /opt/conda/bin/jupyter notebook --ip=0.0.0.0 --port=9999 --NotebookApp.token='' --NotebookApp.password='' --allow-root --notebook-dir='/notebooks'
