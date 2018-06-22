#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: m-thu
"""

import numpy as np
from numpy import sqrt
import matplotlib.pyplot as plt

# Newton fractal
#
#                  f(z)
# z_n = z_{n-1} - --------
#                  f'(z)
#
# f(z) = z^3 - 1
# f'(z) = 3 z^2
#
# Roots:
#    z_0 = 1
#    z_1 = -0.5 + sqrt(3)/2 i
#    z_2 = -0.5 - sqrt(3)/2 i

def f(z):
	return z**3 - 1

def fd(z):
	if z != 0.:
		return 3 * z**2
	else:
		return 1.e-12

if __name__ == "__main__":
	plt.close("all")
	
	N = 500
	max_iter = 20
	eps = 1.e-9
	z0 = [1., -0.5+1j*sqrt(3)/2., -0.5-1j*sqrt(3)/2.]
	
	x_min = -2.
	x_max = 2.
	y_min = -2.
	y_max = 2.
	
	x = np.linspace(x_min, x_max, N)
	y = np.linspace(y_min, y_max, N)
	M = np.zeros((N, N))
	
	for i in range(0, N):
		for j in range(0, N):
			z = complex(x[i], y[j])
			iteration = 0
			
			while iteration < max_iter:
				z -= f(z)/fd(z)
				iteration += 1

				color = 1
				breakout = False
				for w in z0:
					if abs(z - w) < eps:
						M[i, j] = color
						breakout = True
						break
					color += 1
				if breakout:
					break

	plt.close("all")
	fig = plt.figure()
	ax = fig.add_subplot(111)
	ax.matshow(M)
	ax.set_xticks([])
	ax.set_yticks([])
	ax.set(xlabel = r"$\Re\{z\}$", ylabel = r"$\Im\{z\}$")
	plt.show()