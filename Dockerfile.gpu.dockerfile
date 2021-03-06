FROM nvidia/cuda:9.0-base-ubuntu16.04

LABEL maintainer="Manraj Singh Grover <manrajsinghgrover@gmail.com>"

# Install Cuda requirements, basic CLI tools etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        cuda-command-line-tools-9-0 \
        cuda-cublas-9-0 \
        cuda-cufft-9-0 \
        cuda-curand-9-0 \
        cuda-cusolver-9-0 \
        cuda-cusparse-9-0 \
        curl \
        git-core \
        iputils-ping \
        libcudnn7=7.0.5.15-1+cuda9.0 \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
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
        sympy

RUN pip --no-cache-dir install --upgrade python-dateutil==2.6.1

# Install Python 3.6 extra packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3.6-tk

# Install XGBoost GPU Version
RUN cd /usr/local/src && \
    mkdir xgboost && \
    cd xgboost && \
    git clone --recursive https://github.com/dmlc/xgboost && \
    cd xgboost && \
    mkdir build && \
    cd build && \
    cmake .. -DUSE_CUDA=ON && \
    make -j4 && \
    cd .. && \
    cd python-package && \
    python setup.py install

# Install Tensorflow GPU
RUN pip --no-cache-dir install tensorflow-gpu

# Install LightGBM GPU version
ENV OPENCL_LIBRARIES /usr/local/cuda/lib64
ENV OPENCL_INCLUDE_DIR /usr/local/cuda/include

RUN apt-get update && apt-get install -y --no-install-recommends \
        libboost-dev \
        libboost-system-dev \
        libboost-filesystem-dev \
        bzip2 \
        ca-certificates \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxrender1

RUN cd /usr/local/src && \
    mkdir lightgbm && \
    cd lightgbm && \
    git clone --recursive https://github.com/Microsoft/LightGBM && \
    cd LightGBM && \
    mkdir build && \
    cd build && \
    cmake -DUSE_GPU=1 -DOpenCL_LIBRARY=/usr/local/cuda/lib64/libOpenCL.so -DOpenCL_INCLUDE_DIR=/usr/local/cuda/include/ .. && \
    make OPENCL_HEADERS=/usr/local/cuda/targets/x86_64-linux/include LIBOPENCL=/usr/local/cuda/targets/x86_64-linux/lib && \
    cd .. && \
    cd python-package && \
    python setup.py install --precompile

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

# Environment Variables
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

# Ports
## Jupyter Notebook
EXPOSE 8888

## TensorBoard
EXPOSE 6006

# Set working directory
WORKDIR "/root/project"
CMD ["/bin/bash"]
