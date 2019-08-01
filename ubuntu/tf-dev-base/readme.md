# Ubuntu TensorFlow development base docker image

## Overview

This docker image creates a TensorFlow v2.0 development base image with support for Bazel, LLVM, NVIDIA CUDA, TensorRT and Vulkan SDK.

This docker image has been tested on an Ubuntu-18.04 LTS host running:
- NVIDIA Docker 2
- NVIDIA Driver 430.26

This [Dockerfile](./Dockerfile) depends upon the [TensorFlow - Build - Ubuntu-16.04](//ubuntu/xenial/tf-build) docker image.

## Usage

Build the docker image
```bash
cd ubuntu/xenial/tf-base
./build.sh
```

Run the docker image:
```bash
./run.sh
```

Activate tensorflow conda environment:
```bash
conda activate tf3.6
python --version
Python 3.6.8 :: Anaconda, Inc.
```

Run a matrix multiply test:
```bash
nano matmul.py
```

```py
"""
Credits: Author: Dr. Donald Kinghorn, Puget Systems.
"""
import tensorflow as tf
import time
tf.compat.v1.set_random_seed(42)
A = tf.compat.v1.random_normal([10000,10000])
B = tf.compat.v1.random_normal([10000,10000])
def checkMM():
    start_time = time.time()
    with tf.compat.v1.Session() as sess:
            print( sess.run( tf.reduce_sum( tf.matmul(A,B) ) ) )
    print(" took {} seconds".format(time.time() - start_time))

checkMM()
```

```bash
python matmul.py

-873834.5
 took 1.8854620456695557 seconds
```

## Technotes

[Build TensorFlow-CPU with MKL and Anaconda Python 3.6 using a Docker Container - Dr Donald Kinghorn - Puget Systems 20180406](https://www.pugetsystems.com/labs/hpc/Build-TensorFlow-CPU-with-MKL-and-Anaconda-Python-3-6-using-a-Docker-Container-1133/)
