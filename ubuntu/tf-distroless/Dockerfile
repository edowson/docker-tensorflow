# edowson/tf-distroless/$IMAGE_FEATURE:$TENSORFLOW_VERSION-$CUDA_MAJOR_VERSION-xenial

# args
ARG REPOSITORY
ARG TAG
ARG BUILD_BASE

# multi-stage build base image
#FROM ${BUILD_BASE} AS build
FROM python:3.5-slim AS build
#FROM ubuntu:16.04 AS build
COPY ./src/helloworld.py \
     ./src/tf_matmul.py \
     ./src/tf_mnist.py \
     /app/src/
RUN    echo "" \
    && yes | pip install --upgrade pip \
    && yes | pip install tensorflow-gpu==2.0.0-beta1

# RUN    apt-get update; apt-get install --no-install-recommends -y -q wget \
#     && apt-get autoremove -y \
#     && rm -rf /var/lib/apt/lists/* \
#     && wget -q --show-progress --progress=bar:force:noscroll http://security.ubuntu.com/ubuntu/pool/main/a/apt/apt_1.9.1_amd64.deb -O /tmp/apt.deb

# multi-stage build tf-distroless image
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

# # copy applications
# COPY --from=build /tmp/apt.deb /tmp
# RUN    touch /var/lib/dpkg/status \
#     && dpkg -i /tmp/apt.deb

# # install nvidia cuda libraries
# RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates apt-transport-https gnupg-curl && \
#     rm -rf /var/lib/apt/lists/* && \
#     NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
#     NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
#     apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
#     apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
#     echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
#     echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
#     echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

# create tensorflow conda environment
ARG BUILD_OUTPUT
ARG IMAGE_FEATURE
ARG TENSORFLOW_VERSION
ARG TENSORFLOW_PACKAGE_NAME=tensorflow_$IMAGE_FEATURE
ARG TF_PYTHON_VERSION
ARG TF_CONDA_ENV=tf$TF_PYTHON_VERSION
#COPY --from=build $BUILD_OUTPUT $BUILD_OUTPUT

COPY --from=build /app /app
COPY --from=build /usr/local/lib/python$TF_PYTHON_VERSION/site-packages /usr/local/lib/python$TF_PYTHON_VERSION/site-packages
ENV PYTHONPATH=/usr/local/lib/python$TF_PYTHON_VERSION/site-packages

CMD ["/app/src/tf_mnist.py"]
