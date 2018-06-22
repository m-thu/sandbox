#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: m-thu
"""

import numpy as np
from numpy import exp, pi, sqrt, log
import matplotlib.pyplot as plt
import scipy as sp
import scipy.special

# N: number of oscillators
# q: units of energy
#
# Multiplicity:
#
#               (q+N-1)     (q+N-1)!
# Omega(N, q) = (     ) = -----------
#               (  q  )    q! (N-1)!

def mult(N, q):
	return sp.special.comb(q+N-1, q, exact = True)


# q_total: total energy
# NA     : number of oscillators in A
# NB     : number of oscillators in B

def macrostate(q_total, NA, NB):
	print("qA\tOmegaA\tqB\tOmegaB\tOmegaTotal")
	print("-"*50, end = "\n")

	OmegaSum = 0
	x = []
	y = []
	S_A = []
	S_B = []
	S_total = []
	
	for qA in range(q_total+1):
		qB = q_total - qA
		OmegaA = mult(NA, qA)
		OmegaB = mult(NB, qB)
		OmegaTotal = OmegaA * OmegaB
		OmegaSum += OmegaTotal
		
		print(qA, OmegaA, qB, OmegaB, OmegaTotal, sep = "\t")
		
		x.append(qA)
		y.append(OmegaTotal)
		
		# Entropy:
		#    S_A = k_B * ln(OmegaA)
		#    S_B = k_B * ln(OmegaB)
		#    S_total = S_A + S_B
		
		# 1   dS
		# - = --
		# T   dU
		
		S_A.append(log(float(OmegaA)))
		S_B.append(log(float(OmegaB)))
		S_total.append(log(float(OmegaA)) + log(float(OmegaB)))

	print("\nTotal number of microstates:", OmegaSum, end = "\n\n")
	return x, y, S_A, S_B, S_total

if __name__ == "__main__":
	plt.close("all")

	x, y, S_A, S_B, S_total = macrostate(6, 3, 3)
	fig = plt.figure()
	fig.suptitle("NA = 3, NB = 3, q_total = 6")
	ax = fig.add_subplot(111)
	ax.bar(x, y)
	ax.set(xlabel = "qA", ylabel = "OmegaTotal")
	
	x, y, S_A, S_B, S_total = macrostate(100, 300, 200)
	fig2 = plt.figure()
	fig2.suptitle("NA = 300, NB = 200, q_total = 100")
	ax2 = fig2.add_subplot(111)
	ax2.bar(x, y)
	ax2.set(xlabel = "qA", ylabel = "OmegaTotal")
	
	fig3 = plt.figure()
	ax3 = fig3.add_subplot(111)
	ax3.plot(x, S_A, "r", label = r"$S_A$")
	ax3.plot(x, S_B, "g", label = r"$S_B$")
	ax3.plot(x, S_total, "b", label = r"$S_{total}$")
	ax3.legend()
	ax3.set(xlabel = "qA", ylabel = "Entropy")
	
	plt.show()
