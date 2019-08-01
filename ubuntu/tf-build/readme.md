# Ubuntu TensorFlow Build docker image

## Overview

This docker image builds TensorFlow v2.0 from sources with support for NVIDIA CUDA and TensorRT.

This docker image has been tested on an Ubuntu-18.04 LTS host running:
- NVIDIA Docker 2
- NVIDIA Driver 430.26

## Usage

Build tensorflow pip package using the docker image
```bash
cd ubuntu/xenial/tf-build
./build.sh
```

This process will generate the pip package in `/home/developer/tensorflow_pkg` inside the docker image.

To copy the pip package to the host:
```bash
./run.sh
```

This will copy the generated pip package from `/home/developer/tensorflow_pkg` within docker image to `/tmp/build` on the host computer.


## Manual Build Process

```bash
conda create -n tf3.6 python=3.6
conda activate tf3.6
conda install opencv six numpy wheel setuptools mock
pip install keras_applications==1.0.6 --no-deps
pip install keras_preprocessing==1.0.5 --no-deps
```

Configure tensorflow:
```bash
# configure environment varaibles
export PYTHON_BIN_PATH=$(which python)
export PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'import site; print(site.getsitepackages()[0])')"

export TF_ENABLE_XLA=1
export TF_NEED_OPENCL=0
export TF_NEED_ROCM=0
export TF_CUDA_CLANG=0

#export TF_NEED_GCP=1
#export TF_NEED_HDFS=1
#export TF_NEED_S3=1
#export TF_NEED_KAFKA=1

export TF_SET_ANDROID_WORKSPACE=0

export GCC_HOST_COMPILER_PATH=$(which gcc)
export CC_OPT_FLAGS="-march=native -Wno-sign-compare"
export TMP=/tmp

export TF_NEED_MPI=0
#export CC=mpicc
#export MPI_HOME=/usr/lib/openmpi

export TF_NEED_CUDA=1
export TF_NEED_TENSORRT=1
export TF_CUDA_COMPUTE_CAPABILITIES=6.1,7.0

./configure
```

Display contents of .tf_configure.bazelrc
```bash
cat .tf_configure.bazelrc

build --action_env PYTHON_BIN_PATH="/home/developer/.conda/env/tf36/bin/python"
build --action_env PYTHON_LIB_PATH="/home/developer/.conda/env/tf36/lib/python3.6/site-packages"
build --python_path="/home/developer/.conda/env/tf36/bin/python"
build:xla --define with_xla_support=true
build --config=xla
build --config=tensorrt
build --action_env CUDA_TOOLKIT_PATH="/usr/local/cuda"
build --action_env TF_CUDA_COMPUTE_CAPABILITIES="7.0"
build --action_env LD_LIBRARY_PATH="/usr/local/lib/x86_64-linux-gnu:/usr/local/lib/i386-linux-gnu:/usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64"
build --action_env GCC_HOST_COMPILER_PATH="/usr/bin/gcc"
build --config=cuda
build:opt --copt=-march=native
build:opt --copt=-Wno-sign-compare
build:opt --host_copt=-march=native
build:opt --define with_default_optimizations=true
build:v2 --define=tf_api_version=2
test --flaky_test_attempts=3
test --test_size_filters=small,medium
test --test_tag_filters=-benchmark-test,-no_oss,-oss_serial
test --build_tag_filters=-benchmark-test,-no_oss
test --test_tag_filters=-no_gpu
test --build_tag_filters=-no_gpu
test --test_env=LD_LIBRARY_PATH
build --action_env TF_CONFIGURE_IOS="0"
```

Build tensorflow:
```bash
bazel build --config=opt --config=mkl --config=v2 //tensorflow/tools/pip_package:build_pip_package
```
**Note**: Using `--config=mkl` that will cause the build to link in the Intel MKL-ML libs. Those libs are now included in the TensorFlow source tree.


Build tensorflow pip package:
```bash
# fix file time-stamps
find . -type f -exec touch -t 201906090600 '{}' \;

# package
export TENSORFLOW_PACKAGE_NAME=tensorflow-gpu
export BUILD_OUTPUT=$HOME/tensorflow_pkg
./bazel-bin/tensorflow/tools/pip_package/build_pip_package $BUILD_OUTPUT --project_name $TENSORFLOW_PACKAGE_NAME
```

----

## Information

### Library Versions

The NVIDIA machine learning libraries repos are located here:
https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/

Here are the versions and locations of nvidia libraries required for building tensorflow with cuda.

libcublas-dev:
```bash
# location
dpkg -L libcublas-dev
/usr/lib/x86_64-linux-gnu/libcublas.so
/usr/lib/x86_64-linux-gnu/libnvblas.so
/usr/lib/x86_64-linux-gnu/libcublasLt.so

cd /usr/lib/x86_64-linux-gnu/
ls libcublas*
libcublas.so     libcublas.so.10.2.0.168  libcublasLt.so.10          libcublasLt_static.a
libcublas.so.10  libcublasLt.so           libcublasLt.so.10.2.0.168  libcublas_static.a

# version
ldconfig -v | grep libcublas
libcublas.so.10 -> libcublas.so.10.2.0.168
libcublasLt.so.10 -> libcublasLt.so.10.2.0.168
```

libnvinfer-dev:
```bash
# location
dpkg -L libnvinfer-dev
...
/usr/include/x86_64-linux-gnu
/usr/include/x86_64-linux-gnu/NvInferPlugin.h
/usr/include/x86_64-linux-gnu/NvOnnxParserRuntime.h
/usr/include/x86_64-linux-gnu/NvOnnxParser.h
/usr/include/x86_64-linux-gnu/NvUffParser.h
/usr/include/x86_64-linux-gnu/NvCaffeParser.h
/usr/include/x86_64-linux-gnu/NvOnnxConfig.h
/usr/include/x86_64-linux-gnu/NvUtils.h
/usr/include/x86_64-linux-gnu/NvInfer.h
...
/usr/lib/x86_64-linux-gnu/libnvinfer_plugin_static.a
/usr/lib/x86_64-linux-gnu/libnvparsers_static.a
/usr/lib/x86_64-linux-gnu/libnvinfer_static.a
/usr/lib/x86_64-linux-gnu/libnvonnxparser_static.a
/usr/lib/x86_64-linux-gnu/libnvonnxparser_runtime_static.a
/usr/lib/x86_64-linux-gnu/libnvparsers.so
/usr/lib/x86_64-linux-gnu/libnvcaffe_parser.so
/usr/lib/x86_64-linux-gnu/libnvonnxparser.so
/usr/lib/x86_64-linux-gnu/libnvonnxparser_runtime.so
/usr/lib/x86_64-linux-gnu/libnvinfer_plugin.so
/usr/lib/x86_64-linux-gnu/libnvcaffe_parser.a
/usr/lib/x86_64-linux-gnu/libnvinfer.so
```
