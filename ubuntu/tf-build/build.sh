#!/bin/sh

BUILD_DATE=$(date -u +'%Y-%m-%d-%H:%M:%S')
BUILD_VERSION=${1:-"v2.0.0-beta1"}
ORG='edowson'
IMAGE='tf-build'
IMAGE_FEATURE=${2:-"gpu"}
REPOSITORY="$ORG/$IMAGE/$IMAGE_FEATURE"
BAZEL_VERSION='0.26.0'
CUDA_MAJOR_VERSION='10.1'
CUDNN_VERSION='7.6.2.24'
CONDA_PYTHON_VERSION='3'
CONDA_BASE_PACKAGE='miniconda'
CONDA_VERSION='4.7.10'
LLVM_VERSION='7'
NVIDIA_DRIVER_VERSION='430.26'
NCCL2_VERSION='2.4.7'
VULKAN_SDK_VERSION='1.1.108.0'
TENSORFLOW_VERSION="$BUILD_VERSION"
TENSORRT_VERSION='5.1.5.0'
TF_ENABLE_XLA=1
TF_NEED_MPI=0
TF_NEED_OPENCL=0
TF_NEED_ROCM=0
TF_CUDA_COMPUTE_CAPABILITIES="6.1,7.0"
TF_PYTHON_VERSION=${3:-"3.6"}
USER='developer'
USER_ID='1000'
OS_DISTRO=${4:-"ubuntu"}
CODE_NAME=${5:-"xenial"}
BUILD_OUTPUT="/home/$USER/tensorflow_pkg"
TAG="$TENSORFLOW_VERSION-$CUDA_MAJOR_VERSION-$CODE_NAME"
OPTION=""

: '
Information about available software versions:
01. anaconda: 2019.07
02. miniconda: 4.7.10
03. LLVM: 5.0, 6.0, 7, 8.
04. NVIDIA CUDA: 10.1
05. NVIDIA CUDNN: 7.6.1.34, 7.6.2.24
'

# map os code name to os version
if [ $CODE_NAME = "xenial" ]; then
  OS_VERSION='16.04';
elif [ $CODE_NAME = "bionic" ]; then
  OS_VERSION='18.04';
fi

# use tar to dereference the symbolic links from the current directory,
# and then pipe them all to the docker build - command
tar -czh . | docker build - \
  --build-arg REPOSITORY=nvidia/cudagl \
  --build-arg TAG="$CUDA_MAJOR_VERSION-devel-$OS_DISTRO$OS_VERSION" \
  --build-arg BAZEL_VERSION=$BAZEL_VERSION \
  --build-arg CUDA_MAJOR_VERSION=$CUDA_MAJOR_VERSION \
  --build-arg CUDNN_VERSION=$CUDNN_VERSION \
  --build-arg CONDA_PYTHON_VERSION=$CONDA_PYTHON_VERSION \
  --build-arg CONDA_BASE_PACKAGE=$CONDA_BASE_PACKAGE \
  --build-arg CONDA_VERSION=$CONDA_VERSION \
  --build-arg IMAGE_FEATURE=$IMAGE_FEATURE \
  --build-arg LLVM_VERSION=$LLVM_VERSION \
  --build-arg NVIDIA_DRIVER_VERSION=$NVIDIA_DRIVER_VERSION \
  --build-arg NCCL2_VERSION=$NCCL2_VERSION \
  --build-arg VULKAN_SDK_VERSION=$VULKAN_SDK_VERSION \
  --build-arg TENSORFLOW_VERSION=$TENSORFLOW_VERSION \
  --build-arg TENSORRT_VERSION=$TENSORRT_VERSION \
  --build-arg TF_ENABLE_XLA=$TF_ENABLE_XLA \
  --build-arg TF_NEED_MPI=$TF_NEED_MPI \
  --build-arg TF_NEED_OPENCL=$TF_NEED_OPENCL \
  --build-arg TF_NEED_ROCM=$TF_NEED_ROCM \
  --build-arg TF_CUDA_COMPUTE_CAPABILITIES=$TF_CUDA_COMPUTE_CAPABILITIES \
  --build-arg TF_PYTHON_VERSION=$TF_PYTHON_VERSION \
  --build-arg BUILD_VERSION=$BUILD_VERSION \
  --build-arg BUILD_DATE=$BUILD_DATE \
  --build-arg BUILD_OUTPUT=$BUILD_OUTPUT \
  --build-arg USER=$USER \
  --build-arg UID=$USER_ID \
  --tag=${REPOSITORY}:${TAG}
