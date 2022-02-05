# Base image
ARG PYTORCH="1.9.0"
ARG CUDA="11.1"
ARG CUDNN="8"

FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

# Core tools
RUN apt-get update && apt-get install -y \
    cmake \
    curl \
    docker.io \
    ffmpeg \
    git \
    htop \
    libsm6 \
    libxext6 \
    libglib2.0-0 \
    libsm6 \
    libxrender-dev \
    libxext6 \
    ninja-build \
    tmux \
    unzip \
    vim \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# Optional: AWS credentials
# -------------------------
ARG AWS_SECRET_ACCESS_KEY
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

ARG AWS_ACCESS_KEY_ID
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}

ARG AWS_DEFAULT_REGION
ENV AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

# -------------------------
# Optional: W&B credentials
# -------------------------
ARG WANDB_ENTITY
ENV WANDB_ENTITY=${WANDB_ENTITY}

ARG WANDB_API_KEY
ENV WANDB_API_KEY=${WANDB_API_KEY}

# Allow OpenSSH to talk to containers without asking for confirmation
RUN cat /etc/ssh/ssh_config | grep -v StrictHostKeyChecking > /etc/ssh/ssh_config.new && \
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config.new && \
    mv /etc/ssh/ssh_config.new /etc/ssh/ssh_config


# Set up compatible user to avoid file permission issues
ARG USER
ARG USER_ID
ARG GROUP_ID

RUN addgroup --gid $GROUP_ID $USER
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $USER
USER $USER

WORKDIR /home/${USER}
ENV PATH="/home/${USER}/.local/bin:${PATH}"

# Python tools
RUN pip install \
    awscli \
    boto3 \
    coloredlogs \
    gdown \
    gpustat \
    hydra-core \
    omegaconf \
    seaborn \
    scipy \
    termcolor \
    timm==0.4.12 \
    pyyaml \
    wandb \
    yacs \
    # dataset specific tools
    pycocotools \
    nuscenes-devkit

RUN git clone https://github.com/NVIDIA/apex && cd apex && \
    pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./