# TensorFlow Docker build images

This repository contains docker image files for TensorFlow:
- [TensorFlow - Build - Ubuntu-16.04](./ubuntu/xenial/tf-build/)


## Ubuntu Host OS installation

Setup your Ubuntu Host OS, install NVIDIA docker 2 with configure docker user-namespace remapping.
- [Ubuntu-18.04 host installation guide](./doc/ubuntu/ubuntu-18.04-install-myusername.md)

## Usage

Build tensorflow pip package using the docker image
```bash
cd ubuntu/xenial/tf-build
./build.sh
```

This will generate a pip package in `/tmp/build` on the host computer.
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

[Build TensorFlow-CPU with MKL and Anaconda Python 3.6 using a Docker Container](https://www.pugetsystems.com/labs/hpc/Build-TensorFlow-CPU-with-MKL-and-Anaconda-Python-3-6-using-a-Docker-Container-1133/)

[Nvidia GPU: CUDA Compute Capability](https://www.myzhar.com/blog/tutorials/tutorial-nvidia-gpu-cuda-compute-capability/)

---

## Repositories

[hadim/docker-tensorflow-builder/tensorflow/ubuntu-18.10/](https://github.com/hadim/docker-tensorflow-builder/tree/master/tensorflow/ubuntu-18.10)

[cirocavani/tensorflow-build](https://github.com/cirocavani/tensorflow-build)

[horovod/Dockerfile](https://github.com/horovod/horovod/blob/master/Dockerfile)
