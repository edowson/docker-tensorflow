# edowson/tf-base/$IMAGE_FEATURE:$TENSORFLOW_VERSION-$CUDA_MAJOR_VERSION-xenial

# args
ARG REPOSITORY
ARG TAG
ARG BUILD_BASE

# multi-stage build base image
FROM ${BUILD_BASE} AS build

# multi-stage build tf-base image
FROM ${REPOSITORY}:${TAG} AS base
LABEL maintainer "Elvis Dowson <elvis.dowson@gmail.com>"

# setup environment variables
ENV container docker
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}display,graphics,utility

# set the locale
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8

# install build tools
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install --no-install-recommends -q -y \
    apt-transport-https \
    apt-utils \
    bash-completion \
    bzip2 \
    ca-certificates \
    curl \
    git-core \
    git-gui \
    inetutils-ping \
    nano \
    net-tools \
    pkg-config \
    pulseaudio-utils \
    rsync \
    shared-mime-info \
    sudo \
    tzdata \
    unzip \
    wget \
    zip \
    # install git-lfs
    && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install --no-install-recommends -q -y \
    git-lfs \
    # perform dist-upgrade: dist-upgrade in addition to performing the function of upgrade,
    # also intelligently handles changing dependencies with new versions of packages
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get dist-upgrade --no-install-recommends -q -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# install required libraries
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install -q -y \
    libasound2-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# install cudnn libraries
ARG CUDA_MAJOR_VERSION
ARG CUDNN_VERSION
ENV CUDA_MAJOR_VERSION $CUDA_MAJOR_VERSION
ENV CUDNN_VERSION $CUDNN_VERSION
LABEL com.nvidia.cudnn.version="$CUDNN_VERSION"
RUN CUDA_MAJOR_VERSION=`echo $CUDA_VERSION | cut -d. -f1` \
    && CUDA_MINOR_VERSION=`echo $CUDA_VERSION | cut -d. -f2` \
    && CUDNN_MAJOR_VERSION=`echo $CUDNN_VERSION | cut -d. -f1` \
    && echo "CUDA_VERSION=$CUDA_MAJOR_VERSION.$CUDA_MINOR_VERSION" \
    && echo "CUDNN_VERSION=$CUDNN_VERSION" \
    && echo "CUDNN_MAJOR_VERSION=$CUDNN_MAJOR_VERSION" \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install -q -y \
    libcudnn$CUDNN_MAJOR_VERSION=$CUDNN_VERSION-1+cuda$CUDA_MAJOR_VERSION.$CUDA_MINOR_VERSION \
    libcudnn$CUDNN_MAJOR_VERSION-dev=$CUDNN_VERSION-1+cuda$CUDA_MAJOR_VERSION.$CUDA_MINOR_VERSION \
    && apt-mark hold libcudnn$CUDNN_MAJOR_VERSION \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# install cmake
ARG CMAKE_VERSION=3.14
RUN wget -qO- "https://cmake.org/files/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.0-Linux-x86_64.tar.gz" | \
  tar --strip-components=1 -xz -C /usr/local

# install conda
ARG CONDA_PYTHON_VERSION
ARG CONDA_BASE_PACKAGE
ARG CONDA_VERSION
ENV CONDA_PYTHON_VERSION $CONDA_PYTHON_VERSION
ENV CONDA_BASE_PACKAGE $CONDA_BASE_PACKAGE
ENV CONDA_VERSION $CONDA_VERSION
RUN CONDA_BASE_PACKAGE_NAME=`echo $CONDA_BASE_PACKAGE | sed -r 's/\<./\U&/g'` \
    && OS=`uname -s` \
    && ARCH=`uname -m` \
    && CONDA_INSTALL_PACKAGE=$CONDA_BASE_PACKAGE_NAME$CONDA_PYTHON_VERSION-$CONDA_VERSION-$OS-$ARCH.sh \
    && echo "installing $CONDA_INSTALL_PACKAGE" \
    && if [ $CONDA_BASE_PACKAGE_NAME = 'Anaconda' ]; then \
         wget -q --show-progress --progress=bar:force:noscroll https://repo.anaconda.com/archive/$CONDA_INSTALL_PACKAGE -O /tmp/$CONDA_BASE_PACKAGE.sh ;\
       fi \
    && if [ $CONDA_BASE_PACKAGE_NAME = 'Miniconda' ]; then \
         wget -q --show-progress --progress=bar:force:noscroll https://repo.continuum.io/miniconda/$CONDA_INSTALL_PACKAGE -O /tmp/$CONDA_BASE_PACKAGE.sh ;\
       fi \
    && bash /tmp/$CONDA_BASE_PACKAGE.sh -b -p /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION \
    && rm /tmp/$CONDA_BASE_PACKAGE.sh

# install packages and libraries for jetbrains ide
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install --no-install-recommends -q -y \
    # java jdk \
    openjdk-8-jdk \
    # gtk support \
    libcanberra-gtk-module \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# install additional libraries
ARG NCCL2_VERSION
ARG TENSORRT_VERSION
ENV NCCL2_VERSION $NCCL2_VERSION
ENV TENSORRT_VERSION $TENSORRT_VERSION
RUN apt-get update \
    && TENSORRT_VERSION=`echo $TENSORRT_VERSION | cut -d. -f1-3` \
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install --allow-change-held-packages -q -y \
    # nvidia libraries \
    libnccl2=$NCCL2_VERSION-1+cuda$CUDA_MAJOR_VERSION \
    libnccl-dev=$NCCL2_VERSION-1+cuda$CUDA_MAJOR_VERSION \
    libnvinfer-dev=$TENSORRT_VERSION-1+cuda$CUDA_MAJOR_VERSION \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# fixes for tensorflow build
RUN    echo "applying fixes for tensorflow build" \
    # libcublas \
    && CUBLAS_VERSION=`apt-cache policy libcublas-dev | grep 'Installed:' | cut -c 14- | sed 's/-[0-9].*//'` \
    && cp /usr/include/cublas* /usr/local/cuda-$CUDA_MAJOR_VERSION/include/ \
    && cp /usr/lib/x86_64-linux-gnu/libcublas.so.$CUBLAS_VERSION /usr/local/cuda-$CUDA_MAJOR_VERSION/lib64/ \
    && echo "current libcublas-dev=$CUBLAS_VERSION, creating symlink /usr/local/cuda-$CUDA_MAJOR_VERSION/lib64/libcublas.so.$CUDA_MAJOR_VERSION" \
    && ln -s /usr/local/cuda-$CUDA_MAJOR_VERSION/lib64/libcublas.so.$CUBLAS_VERSION /usr/local/cuda-$CUDA_MAJOR_VERSION/lib64/libcublas.so.$CUDA_MAJOR_VERSION \
    && ln -s /usr/local/cuda-$CUDA_MAJOR_VERSION/lib64/libcublas.so.$CUDA_MAJOR_VERSION /usr/local/cuda-$CUDA_MAJOR_VERSION/lib64/libcublas.so


# create user
ARG USER
ARG UID

ENV HOME /home/$USER
RUN adduser $USER --uid $UID --disabled-password --gecos "" \
    && usermod -aG audio,video $USER \
    && echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# copy configuration files
COPY ./config/etc/asound.conf /etc/asound.conf
COPY ./config/etc/pulse/client.conf /etc/pulse/client.conf
COPY ./config/etc/resolv.conf /etc/resolv.conf

# setup nvidia opengl and vulkan driver icds
#COPY ./config/vendor/egl_nvidia_icd.json /usr/local/share/glvnd/egl_vendor.d/10_nvidia.json
#COPY ./config/vendor/glx_nvidia_icd.json /usr/local/share/vulkan/icd.d/nvidia_icd.json

# switch to non-root user
USER $USER

# set the working directory
WORKDIR $HOME

# update .bashrc
RUN echo \
'CUDA="/usr/local/cuda-${CUDA_MAJOR_VERSION}"\n\
export PS1="${debian_chroot:+($debian_chroot)}\u:\W\$ "\n\
export LD_LIBRARY_PATH="${CUDA}/lib64:${CUDA}/extras/CUPTI/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"\n\
export PATH="${HOME}/bin:${VULKAN_SDK}/bin:${CUDA}/bin${PATH:+:${PATH}}"' \
    >> $HOME/.bashrc

RUN /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/bin/conda init bash

# update .condarc
RUN    /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/bin/conda config --set auto_activate_base true \
    && /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/bin/conda config --add envs_dirs ~/.conda/env \
    && /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/bin/conda config --add pkgs_dirs ~/.conda/pkgs \
    && /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/bin/conda config --add channels anaconda

# create tensorflow conda environment
ARG BUILD_OUTPUT
ARG IMAGE_FEATURE
ARG TENSORFLOW_VERSION
ARG TENSORFLOW_PACKAGE_NAME=tensorflow_$IMAGE_FEATURE
ARG TF_PYTHON_VERSION
ARG TF_CONDA_ENV=tf$TF_PYTHON_VERSION
COPY --from=build $BUILD_OUTPUT $BUILD_OUTPUT
RUN    /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/bin/conda create -n $TF_CONDA_ENV python=$TF_PYTHON_VERSION --yes \
    # source conda shell environment \
    && . /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/etc/profile.d/conda.sh \
    && conda activate $TF_CONDA_ENV \
    && conda install opencv six numpy wheel setuptools mock --yes \
    && yes | pip install keras_applications==1.0.6 --no-deps \
    && yes | pip install keras_preprocessing==1.0.5 --no-deps \
    && yes | pip install $BUILD_OUTPUT/$TENSORFLOW_PACKAGE_NAME*.whl

# labels
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="edowson/tf-base/$IMAGE_FEATURE:$TENSORFLOW_VERSION-$CUDA_MAJOR_VERSION-xenial"
LABEL org.label-schema.description="TensorFlow $IMAGE_FEATURE-$TENSORFLOW_VERSION base image with NVIDIA CUDA-$CUDA_VERSION CUDNN-$CUDNN_VERSION TENSORRT-$TENSORRT_VERSION - Ubuntu-16.04."
LABEL org.label-schema.version=$TENSORFLOW_VERSION
LABEL org.label-schema.docker.cmd="xhost +local:root \
docker run -it \
  --runtime=nvidia \
  --device /dev/snd \
  -e DISPLAY \
  -e PULSE_SERVER=tcp:$HOST_IP:4713 \
  -e PULSE_COOKIE_DATA=`pax11publish -d | grep --color=never -Po '(?<=^Cookie: ).*'` \
  -e QT_GRAPHICSSYSTEM=native \
  -e QT_X11_NO_MITSHM=1 \
  -v /dev/shm:/dev/shm \
  -v /etc/localtime:/etc/localtime:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket:ro \
  -v ${XDG_RUNTIME_DIR}/pulse/native:/run/user/1000/pulse/native \
  -v ~/mount/backup:/backup \
  -v ~/mount/data:/data \
  -v ~/mount/project:/project \
  -v ~/mount/tool:/tool \
  --rm \
  --name tf-base-$IMAGE_FEATURE-$TENSORFLOW_VERSION-$CUDA_MAJOR_VERSION-xenial \
  edowson/tf-base/$IMAGE_FEATURE:$TENSORFLOW_VERSION-$CUDA_MAJOR_VERSION-xenial \
xhost -local:root"

CMD ["bash"]
