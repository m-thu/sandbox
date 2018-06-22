#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: m-thu
"""

import numpy as np
import matplotlib.pyplot as plt

# Feigenbaum diagram
#
# z_0 = 0
# z_n = z_{n-1}^2 + c
#
# -2 < c < 0.25
# z_99 ... z_105

if __name__ == "__main__":
	plt.close("all")
	
	N = 1000
	min = 99
	max = 105
	#min = 200
	#max = 210
	
	c = np.linspace(-2, 0.25, N)
	x = []
	y = []
	for idx in range(0, N):
		z = 0.
		for i in range(0, min):
			z = z**2 + c[idx]
		for i in range(min, max):
			z = z**2 + c[idx]
			x.append(c[idx])
			y.append(z)
	
	plt.close("all")
	fig = plt.figure()
	ax = fig.add_subplot(111)
	ax.set(xlabel = "c", ylabel = r"$z_{"+str(min)+r"}\,\dots\,z_{"+str(max)+r"}$")
	ax.scatter(x, y, marker = ".", s = 0.5)
	plt.show()