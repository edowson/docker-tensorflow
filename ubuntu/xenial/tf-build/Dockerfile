# edowson/tf-build/$IMAGE_FEATURE:$BUILD_VERSION-$CUDA_MAJOR_VERSION-xenial

# build tf-build
ARG REPOSITORY
ARG TAG
FROM ${REPOSITORY}:${TAG}
LABEL maintainer "Elvis Dowson <elvis.dowson@gmail.com>"

# setup environment variables
ENV container docker
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}display,graphics,utility

# set the locale
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8

# install packages
RUN apt-get update \
    && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# setup keys: llvm
ARG LLVM_VERSION
RUN if [ -n "$LLVM_VERSION" ]; then \
     echo "importing gpg keys for llvm apt repository" ;\
     apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 6084F3CF814B57C1CF12EFD515CF4D18AF4F7421 ;\
    fi

# setup sources.list
RUN echo "deb-src http://us.archive.ubuntu.com/ubuntu/ $(lsb_release -cs) main restricted \n\
deb-src http://us.archive.ubuntu.com/ubuntu/ $(lsb_release -cs)-updates main restricted \n\
deb-src http://us.archive.ubuntu.com/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse \n\
deb-src http://security.ubuntu.com/ubuntu $(lsb_release -cs)-security main restricted" \
    > /etc/apt/sources.list.d/official-source-repositories.list \
    && if [ -n "$LLVM_VERSION" ]; then \
        echo "setting up sources.list for llvm-toolchain-$LLVM_VERSION" ;\
        echo "deb http://apt.llvm.org/`lsb_release -sc`/ llvm-toolchain-`lsb_release -sc`-$LLVM_VERSION main" \
        > "/etc/apt/sources.list.d/llvm-toolchain-$LLVM_VERSION.list" ;\
       fi

# install build tools
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install --no-install-recommends -q -y \
    apt-transport-https \
    apt-utils \
    bash-completion \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    gconf2 \
    gconf-service \
    gdb \
    git-core \
    git-gui \
    gvfs-bin \
    inetutils-ping \
    nano \
    net-tools \
    pkg-config \
    pulseaudio-utils \
    rsync \
    shared-mime-info \
    software-properties-common \
    sudo \
    tzdata \
    unzip \
    wget \
    xdg-user-dirs \
    xdg-utils \
    x11-xserver-utils \
    zip \
    # install git-lfs
    && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install --no-install-recommends -q -y \
    git-lfs \
    # install llvm-toolchain
    && if [ -n "$LLVM_VERSION" ]; then \
        echo "installing llvm-toolchain-$LLVM_VERSION" ;\
        # install llvm-toolchain
        DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install --no-install-recommends -q -y \
        clang-$LLVM_VERSION \
        clang-format-$LLVM_VERSION \
        lld-$LLVM_VERSION \
        lldb-$LLVM_VERSION \
        llvm-$LLVM_VERSION \
        llvm-$LLVM_VERSION-dev ;\
        # configure update update-alternatives \
        update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$LLVM_VERSION 100 ;\
        update-alternatives --install /usr/bin/clang   clang   /usr/bin/clang-$LLVM_VERSION   100 ;\
        update-alternatives --install /usr/bin/ld.lld  ld.lld  /usr/bin/ld.lld-$LLVM_VERSION  100 ;\
        update-alternatives --install /usr/bin/lldb    lldb    /usr/bin/lldb-$LLVM_VERSION    100 ;\
       else \
        echo "llvm-toolchain not specified, not installing llvm." ;\
       fi \
    # perform dist-upgrade: dist-upgrade in addition to performing the function of upgrade,
    # also intelligently handles changing dependencies with new versions of packages
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get dist-upgrade --no-install-recommends -q -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# install required libraries
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install -q -y \
    libasound2-dev \
    libglm-dev \
    libmirclient-dev \
    libpciaccess0 \
    libpng-dev \
    libwayland-dev \
    libxcb-dri3-0 \
    libxcb-dri3-dev \
    libxcb-glx0 \
    libxcb-present0 \
    libxcb-keysyms1-dev \
    libx11-dev \
    libxrandr-dev \
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
    && wget -q --show-progress --progress=bar:force:noscroll https://repo.anaconda.com/archive/$CONDA_INSTALL_PACKAGE -O /tmp/$CONDA_BASE_PACKAGE.sh \
    && bash /tmp/$CONDA_BASE_PACKAGE.sh -b -p /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION \
    && rm /tmp/$CONDA_BASE_PACKAGE.sh

# install vulkan sdk
ARG VULKAN_SDK_VERSION
ENV VULKAN_SDK_VERSION=$VULKAN_SDK_VERSION
RUN echo "downloading Vulkan SDK $VULKAN_SDK_VERSION" \
    && wget -q --show-progress --progress=bar:force:noscroll https://sdk.lunarg.com/sdk/download/$VULKAN_SDK_VERSION/linux/vulkansdk-linux-$VULKAN_SDK_VERSION.tar.gz -O /tmp/vulkansdk-linux-x86_64-$VULKAN_SDK_VERSION.tar.gz \
    && echo "installing Vulkan SDK $VULKAN_SDK_VERSION" \
    && mkdir -p /opt/vulkan \
    && tar -xf /tmp/vulkansdk-linux-x86_64-$VULKAN_SDK_VERSION.tar.gz -C /opt/vulkan \
    && rm /tmp/vulkansdk-linux-x86_64-$VULKAN_SDK_VERSION.tar.gz

# install nvidia driver
ARG NVIDIA_DRIVER_VERSION
ENV NVIDIA_DRIVER_VERSION $NVIDIA_DRIVER_VERSION
RUN wget -q --show-progress --progress=bar:force:noscroll http://us.download.nvidia.com/XFree86/Linux-x86_64/$NVIDIA_DRIVER_VERSION/NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION.run -O /tmp/NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION.run \
    && cd /tmp \
    && sh NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION.run --extract-only \
    && cp /tmp/NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION/libnvidia-glvkspirv.so.$NVIDIA_DRIVER_VERSION /usr/lib/x86_64-linux-gnu/ \
    && rm -rf /tmp/NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION /tmp/NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION.run

# install packages and libraries for jetbrains ide
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install --no-install-recommends -q -y \
    # java jdk \
    openjdk-8-jdk \
    # gtk support \
    libcanberra-gtk-module \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# args
ARG BUILD_VERSION

# install additional libraries
ARG NCCL2_VERSION
ARG TENSORRT_VERSION
ENV NCCL2_VERSION $NCCL2_VERSION
ENV TENSORRT_VERSION $TENSORRT_VERSION
RUN apt-get update \
    && TENSORRT_VERSION=`echo $TENSORRT_VERSION | cut -d. -f1-3` \
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install --allow-change-held-packages -q -y \
    # required libraries \
    openmpi-bin \
    libopenmpi-dev \
    libfreetype6-dev \
    libhdf5-serial-dev \
    libpng-dev \
    libzmq3-dev \
    zlib1g-dev \
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
    && echo "current libcublas-dev=$CUBLAS_VERSION, creating symlink /usr/local/cuda-$CUDA_MAJOR_VERSION/lib64/libcublas.so.$CUDA_MAJOR_VERSION" \
    && cp /usr/lib/x86_64-linux-gnu/libcublas.so.$CUBLAS_VERSION /usr/local/cuda-$CUDA_MAJOR_VERSION/lib64/ \
    && ln -s /usr/local/cuda-10.1/lib64/libcublas.so.$CUBLAS_VERSION /usr/local/cuda-$CUDA_MAJOR_VERSION/lib64/libcublas.so.$CUDA_MAJOR_VERSION \
    && ln -s /usr/local/cuda-10.1/lib64/libcublas.so.$CUDA_MAJOR_VERSION /usr/local/cuda-10.1/lib64/libcublas.so

# install bazel
ARG BAZEL_VERSION
ENV BAZEL_VERSION $BAZEL_VERSION
RUN    echo "startup --batch" >> /etc/bazel.bazelrc \
    && echo "build --spawn_strategy=standalone --genrule_strategy=standalone" >> /etc/bazel.bazelrc \
    && wget -q --show-progress --progress=bar:force:noscroll https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh \
            -O /tmp/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh \
    && bash /tmp/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh \
    && rm -f /tmp/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh


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
COPY ./config/vendor/glx_nvidia_icd.json /usr/local/share/vulkan/icd.d/nvidia_icd.json

# switch to non-root user
USER $USER

# set the working directory
WORKDIR $HOME

# update .bashrc
RUN echo \
'CUDA="/usr/local/cuda-${CUDA_MAJOR_VERSION}"\n\
export PS1="${debian_chroot:+($debian_chroot)}\u:\W\$ "\n\
export VULKAN_SDK="/opt/vulkan/${VULKAN_SDK_VERSION}/x86_64"\n\
export VK_LAYER_PATH="${VULKAN_SDK}/etc/explicit_layer.d"\n\
export LD_LIBRARY_PATH="${VULKAN_SDK}/lib:${CUDA}/lib64:${CUDA}/extras/CUPTI/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"\n\
export PATH="${HOME}/bin:${VULKAN_SDK}/bin:${CUDA}/bin${PATH:+:${PATH}}"\n\
source /usr/local/lib/bazel/bin/bazel-complete.bash' \
    >> $HOME/.bashrc

RUN /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/bin/conda init bash

# update .condarc
RUN    /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/bin/conda config --set auto_activate_base true \
    && /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/bin/conda config --add envs_dirs ~/.conda/env \
    && /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/bin/conda config --add pkgs_dirs ~/.conda/pkgs \
    && /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/bin/conda config --add channels anaconda

# create tensorflow conda build environment
ARG TF_PYTHON_VERSION
ARG TF_CONDA_ENV=tf$TF_PYTHON_VERSION
RUN    /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/bin/conda create -n $TF_CONDA_ENV python=$TF_PYTHON_VERSION --yes \
    # source conda shell environment \
    && . /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/etc/profile.d/conda.sh \
    && conda activate $TF_CONDA_ENV \
    && conda install opencv six numpy wheel setuptools mock --yes \
    && yes | pip install keras_applications==1.0.6 --no-deps \
    && yes | pip install keras_preprocessing==1.0.5 --no-deps

# clone tensorflow sources
ARG TENSORFLOW_VERSION
ARG TENSORFLOW_DIR=$HOME/tensorflow
ENV TENSORFLOW_VERSION $TENSORFLOW_VERSION
ADD --chown=1000:1000 https://api.github.com/repos/tensorflow/tensorflow/git/refs/heads/$TENSORFLOW_VERSION $HOME/.tensorflow_git_version.json
RUN git clone --depth=1 --branch $TENSORFLOW_VERSION https://github.com/tensorflow/tensorflow.git $TENSORFLOW_DIR

# configure tensorflow
ARG IMAGE_FEATURE
ARG TF_ENABLE_XLA
ARG TF_NEED_MPI
ARG TF_NEED_OPENCL
ARG TF_NEED_ROCM
ARG TF_CUDA_COMPUTE_CAPABILITIES
ENV IMAGE_FEATURE $IMAGE_FEATURE
RUN    echo "configuring tensorflow-$IMAGE_FEATURE-$TENSORFLOW_VERSION"  \
    # source conda shell environment \
    && . /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/etc/profile.d/conda.sh \
    && conda activate $TF_CONDA_ENV \
    && export PYTHON_BIN_PATH=$(which python) \
    && export PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'import site; print(site.getsitepackages()[0])')" \
    && export GCC_HOST_COMPILER_PATH=$(which gcc) \
    && export CC_OPT_FLAGS="-march=native -Wno-sign-compare" \
    && export TMP=/tmp \
    && export TF_ENABLE_XLA=$TF_ENABLE_XLA \
    && export TF_NEED_OPENCL=$TF_NEED_OPENCL \
    && export TF_NEED_ROCM=$TF_NEED_ROCM \
    && if [ $IMAGE_FEATURE = "gpu" ]; then \
        echo "configuring $IMAGE_FEATURE support" ;\
        # cuda
        export TF_NEED_CUDA=1 ;\
        # tensorrt
        if [ $TENSORRT_VERSION ]; then \
         export TF_NEED_TENSORRT=1  ;\
        fi ;\
        # cuda compute capabilities
        if [ $TF_CUDA_COMPUTE_CAPABILITIES ]; then \
         export TF_CUDA_COMPUTE_CAPABILITIES=$TF_CUDA_COMPUTE_CAPABILITIES ;\
        else \
         export TF_CUDA_COMPUTE_CAPABILITIES="7.0" ;\
        fi ;\
        export TF_CUDA_CLANG=0 ;\
        # debug output
        echo "TF_NEED_CUDA=$TF_NEED_CUDA" ;\
        echo "TF_NEED_TENSORRT=$TF_NEED_TENSORRT" ;\
        echo "TF_CUDA_COMPUTE_CAPABILITIES=$TF_CUDA_COMPUTE_CAPABILITIES" ;\
        echo "TF_CUDA_CLANG=$TF_CUDA_CLANG" ;\
       else \
        export TF_NEED_CUDA=0 ;\
        echo "TF_NEED_CUDA=$TF_NEED_CUDA" ;\
       fi \
    && export TF_NEED_MPI=$TF_NEED_MPI \
    && export TF_SET_ANDROID_WORKSPACE=0 \
    && cd $TENSORFLOW_DIR \
    && ./configure

# build tensorflow
ARG TENSORFLOW_PACKAGE_NAME=tensorflow-$IMAGE_FEATURE
RUN    echo "building tensorflow-$IMAGE_FEATURE-$TENSORFLOW_VERSION" \
    # source conda shell environment \
    && . /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/etc/profile.d/conda.sh \
    && conda activate $TF_CONDA_ENV \
    && cd $TENSORFLOW_DIR \
    && bazel build --config=opt --config=mkl //tensorflow/tools/pip_package:build_pip_package

# generate tensorflow pip package
ARG BUILD_OUTPUT
RUN    echo "generating tensorflow-$IMAGE_FEATURE-$TENSORFLOW_VERSION wheels package to $BUILD_OUTPUT" \
    # source conda shell environment \
    && . /opt/$CONDA_BASE_PACKAGE$CONDA_PYTHON_VERSION/etc/profile.d/conda.sh \
    && conda activate $TF_CONDA_ENV \
    && cd $TENSORFLOW_DIR \
    && ./bazel-bin/tensorflow/tools/pip_package/build_pip_package $BUILD_OUTPUT --project_name $TENSORFLOW_PACKAGE_NAME

# labels
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="edowson/tf-build/$IMAGE_FEATURE:$TENSORFLOW_VERSION-$CUDA_MAJOR_VERSION-xenial"
LABEL org.label-schema.description="TensorFlow $IMAGE_FEATURE-$TENSORFLOW_VERSION build with NVIDIA CUDA-$CUDA_VERSION CUDNN-$CUDNN_VERSION TENSORRT-$TENSORRT_VERSION - Ubuntu-16.04."
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
  -v ${BUILD_OUTPUT}:${BUILD_OUTPUT} \
  --rm \
  --name tf-build-$IMAGE_FEATURE-$TENSORFLOW_VERSION-$CUDA_MAJOR_VERSION-xenial \
  edowson/tf-build/$IMAGE_FEATURE:$TENSORFLOW_VERSION-$CUDA_MAJOR_VERSION-xenial \
xhost -local:root"

CMD ["bash"]
