#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jun  9 13:14:35 2018

@author: matthias
"""

# <f> = 1/(b-a) * \int_a^b f(x) dx
# (b-a) * <f> = \int_a^b f(x) dx
# --> \int_a^b f(x) dx ~ (b-a)/N * \sum_{i=1}^N f(x_i)

from scipy import random
import numpy as np
from numpy import pi
import matplotlib.pyplot as plt

def integrate(f, a, b, N):
    xrand = random.uniform(a, b, N)

    sum = 0.

    for x in xrand:
        sum += f(x)

    return sum * (b-a) / N

if __name__ == "__main__":
    f = lambda x: np.sin(x)
    a = 0
    b = pi
    N = 1000
    
    areas = []
    for i in range(N):
        areas.append(integrate(f, a, b, N))
    
    plt.hist(areas, bins = 30, ec = "black")
    plt.xlabel("Value of the integral")
    plt.show()