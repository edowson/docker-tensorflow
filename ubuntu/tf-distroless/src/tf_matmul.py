#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
TensorFlow Matrix Multiply Example.

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
