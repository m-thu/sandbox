#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from numpy import random
import numpy as np
import matplotlib.pyplot as plt

N = 1000

circlex = []
circley = []

squarex = []
squarey = []

i = 1

while i <= N:
    x = random.uniform(-1, 1)
    y = random.uniform(-1, 1)
    
    if (x**2 + y**2) <= 1.:
        circlex.append(x)
        circley.append(y)
    else:
        squarex.append(x)
        squarey.append(y)
    
    i += 1

pi = 4. * len(circlex) / N

print("Pi is approximately", pi)
print("Error:", (pi-np.pi)/np.pi*100, "%")

plt.plot(circlex, circley, "b.")
plt.plot(squarex, squarey, "g.")
plt.grid()

plt.show()