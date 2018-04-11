#!/usr/bin/env python

import time

import numpy

N = 1e4
n = 1e7
K = [4, 6, 8, 10, 12, 20]
A = [0.05, 0.01]

print N, n

p = {}
for k in K:
	p[k] = {}

	D = numpy.zeros((N,))
	for r in range(int(N)):
		x = (numpy.random.random((n,))*k + 0.5).round()
		max_ks_distance = 0.0
		for i in range(1, k + 1):
			c = numpy.count_nonzero(x >= i)
			max_ks_distance = max(max_ks_distance, abs(c - (k - i + 1)*n/k))
		D[r] = max_ks_distance/n

		if r % 1e3 == 0: print time.asctime(), k, r, "/", int(N)

	for a in A:
		p[k][a] = numpy.percentile(D, 100.0*(1.0 - a))

print N, n, p
