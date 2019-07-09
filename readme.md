# TensorFlow Docker build images

This repository contains docker images for building TensorFlow v2.0 with NVIDIA CUDA and TensorRT support:
- [TensorFlow - Build Image - Ubuntu-16.04](./ubuntu/xenial/tf-build/)

Additionally, a set of TensorFlow v2.0 base images have been provided, as a starting point for creating your own docker images:
- [TensorFlow - Base Image - Ubuntu-16.04](./ubuntu/xenial/tf-base/)
- [TensorFlow - Development Base Image - Ubuntu-16.04](./ubuntu/xenial/tf-base/)


## Ubuntu Host OS installation

Setup your Ubuntu Host OS, install NVIDIA docker 2 with configure docker user-namespace remapping.
- [Ubuntu-18.04 host installation guide](./doc/ubuntu/ubuntu-18.04-install-myusername.md)

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

---

## Issues

### Conda

[Activating environment in dockerfile - related to #81 #89](https://github.com/ContinuumIO/docker-images/issues/89)

### Tensorflow

[Missing input file mpi:mpio.h #11903](https://github.com/tensorflow/tensorflow/issues/11903)
> setting export MPI_HOME=/usr/lib/openmpi that should result in correct symlinks

---

## Technotes

[How a badly configured Tensorflow in Docker can be 10x slower than expected - 20180808](https://www.freecodecamp.org/news/how-a-badly-configured-tensorflow-in-docker-can-be-10x-slower-than-expected-3ac89f33d625/)

[How to compile TensorFlow 1.12 on Ubuntu 16.04 using Docker](https://cnvrg.io/how-to-compile-tensorflow-1-12-on-ubuntu-16-04-using-docker/)

[Build TensorFlow-CPU with MKL and Anaconda Python 3.6 using a Docker Container - Dr Donald Kinghorn - Puget Systems 20180406](https://www.pugetsystems.com/labs/hpc/Build-TensorFlow-CPU-with-MKL-and-Anaconda-Python-3-6-using-a-Docker-Container-1133/)

[Nvidia GPU: CUDA Compute Capability](https://www.myzhar.com/blog/tutorials/tutorial-nvidia-gpu-cuda-compute-capability/)

---

## Repositories

[hadim/docker-tensorflow-builder/tensorflow/ubuntu-18.10/](https://github.com/hadim/docker-tensorflow-builder/tree/master/tensorflow/ubuntu-18.10)

[cirocavani/tensorflow-build](https://github.com/cirocavani/tensorflow-build)

[horovod/Dockerfile](https://github.com/horovod/horovod/blob/master/Dockerfile)
