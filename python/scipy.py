#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: m-thu
"""

# (1, 2, 3): tuple (immutable)
# [1, 2, 3]: list (mutable)
# {"key": value}: dictionary (mutable)



import numpy as np

# help: np.array?
#       np.con*?
#       np.lookfor("create array")



# 1D array

a = np.array([0, 1, 2, 3])
print("a:", a)
print("a.ndim:", a.ndim)
print("a.shape:", a.shape)
print("len(a):", len(a), "\n\n")



# 2D array

b = np.array([[0, 1, 2], [3, 4, 5]])
print("b:", b)
print("b.ndim:", b.ndim)
print("b.shape:", b.shape)
print("len(b):", len(b), "\n\n") # first dimension



# Creating arrays

a = np.arange(10) # 0, 1, ..., n-1
print("arange(10):", a, "\n")

b = np.arange(1, 10, 2) # start, start+2, ..., stop-1
print("arange(1, 10, 2):", b, "\n")

c = np.linspace(0, 1, 10) # start; stop; number of points
print("linspace(0, 1, 10):\n", c, "\n")

d = np.ones((4, 4)) # all ones
print("ones((4, 4)):\n", d, "\n")

e = np.zeros((3, 3)) # all zeros
print("zeros((3, 3)):\n", e, "\n")

f = np.eye(2) # unity matrix (nxn)
print("eye((2, 2)\n", f, "\n")

g = np.diag(np.array([1, 2, 3, 4])) # diagonal matrix
print("diag(np.array([1, 2, 3, 4])):\n", g, "\n\n")



# Data types

a = np.array([1, 2, 3])
print("[1, 2, 3] dtype:", a.dtype, "\n")

b = np.array([1., 2., 3.])
print("[1., 2., 3.] dtype:", b.dtype, "\n")

c = np.array([1, 2, 3], dtype=float) # specify type
print("[1, 2, 3], dtype=float dtype:", c.dtype, "\n")

d = np.array([1+1j, 2+2j, 3+3j]) # complex numbers
print("[1+1j, 2+2j, 3+3j] dtype:", d.dtype, "\n\n")



# pyplot: procedural interface
import matplotlib.pyplot as plt

# 1D plots

x = np.linspace(0., 10., 20)
y = x**2
plt.figure()
plt.plot(x, y)
plt.plot(x, y, 'o')
#plt.show()

x = np.linspace(0., 2*np.pi)
y1 = np.sin(x)
y2 = np.cos(x)
plt.figure()
plt.plot(x, y1)
plt.plot(x, y2)
#plt.show()



# Indexing, slicing

a = np.arange(5)
print("a:", a, "\n")
print("a[0]:", a[0], "a[1]:", a[1], "a[-1]:", a[-1], "\n")

print("a[::-1]: ", a[::-1], "\n\n") # reverse



# Operations on arrays

a = np.eye(3)
a += 1
print("a:", a, "\n")

a = np.arange(5)
b = a[::-1]
c = b-a
print("c:", c, "\n")

d = a*a # elementwise multiplication
print("d:", d, "\n")

e = np.ones((2,2))
print("e*e:\n", e*e, "\n") # elementwise
print("e.dot(e):\n", e.dot(e), "\n") # matrix multiplication

f = np.array([[0, -1j], [1j, 0]])
print("f:\n", f, "\n")
print("f^t:\n", f.T, "\n") # transpose (view of the original array)

a = np.array([1, 2, 3, 4])
print(np.sum(a), end="\n")

b = np.array([[1, 2], [3, 4]])
print("b:\n", b, "\n")
print("sum of columns: ", np.sum(b, axis=0), "\n")
print("sum of rows:", np.sum(b, axis=1), "\n")
print("min:", np.min(b), "\tmax:", np.max(b), "\n")
print("b.ravel():\n", b.ravel(), "\n") # flatten array



# Polynomials

# x^2 + 2*x + 3
p = np.poly1d([1, 2, 3])

print("p(0) =", p(0))
print("order:", p.order)
print("roots:", p.roots)
print("p(root1) =", p(p.roots[0]))
print("p(root2) =", p(p.roots[1]), "\n")