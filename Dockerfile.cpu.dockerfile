FROM ubuntu:16.04

LABEL maintainer="Manraj Singh Grover <manrajsinghgrover@gmail.com>"

# Install basic CLI tools etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git-core \
        iputils-ping \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        rsync \
        software-properties-common \
        unzip \
        wget

# Install Python 3.6
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y python3.6 python3.6-dev

# Link Python to Python 3.6
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.6 1

# Install PIP
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

# Install Python packages
RUN pip --no-cache-dir install \
        colorlover \
        gensim \
        hyperopt \
        h5py \
        ipykernel \
        jupyter \
        keras \
        lightgbm \
        matplotlib \
        nltk \
        nose \
        numpy \
        pandas \
        scikit-image \
        scipy \
        seaborn \
        sklearn \
        SQLAlchemy \
        sympy \
        tensorflow \
        xgboost

RUN pip --no-cache-dir install --upgrade python-dateutil==2.6.1

# Install Python 3.6 extra packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3.6-tk

# Fix hyperopt issue
RUN pip install networkx==1.11

# Fix pandas excel issue
RUN pip install xlrd openpyxl

# Fix xgboost plotting issue
RUN apt-get update && apt-get install -y --no-install-recommends graphviz
RUN pip install graphviz

# Fix TensorBoard issue
RUN pip --no-cache-dir install bleach==1.5.0

# Install fbprophet
RUN pip --no-cache-dir install pystan
RUN pip --no-cache-dir install fbprophet

# Clean up commands
RUN rm -rf /root/.cache/pip/* && \
    apt-get autoremove -y && apt-get clean && \
    rm -rf /usr/local/src/*

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Ports
## Jupyter Notebook
EXPOSE 8888

## TensorBoard
EXPOSE 6006

# Set working directory
WORKDIR "/root/project"
CMD ["/bin/bash"]
