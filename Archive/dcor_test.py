#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul  8 10:11:54 2022

@author: ali
"""

pip install dcor



import dcor
import math

import numpy as np
from timeit import timeit
import matplotlib.pyplot as plt
from numpy import random


x = random.rand(10, 1)
y=1-x**2

dcor.distance_correlation(x, y)
np.corrcoef(np.transpose(x), np.transpose(y))
plt.plot(x,y)
