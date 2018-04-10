//
//  RollCounts.swift
//  dice-fairness
//
//  Created by John Bender on 4/1/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

let chiTable99 = [4: 11.345,
						6: 15.086,
						8: 18.475,
						10: 21.666,
						12: 24.725,
						20: 36.191] // 99th percentile chi-squared values for k-1 DOF
let chiTable95 = [4: 7.815,
						6: 11.070,
						8: 14.067,
						10: 16.919,
						12: 19.675,
						20: 30.144] // 95th percentile
let ksTable99 = [4: 0.0000422803, // 99th percentile score of Kolmogorov-Smirnov values
					  6: 0.000446334,  // from Monte Carlo simulation 4/8/18 with N=1e4, n=1e7
					  8: 0.000444602,
					  10: 0.000449304,
					  12: 0.000465234,
					  20: 0.000470716]
let ksTable95 = [4: 0.0003435,
					  6: 0.000357615,
					  8: 0.0003659,
					  10: 0.000370205,
					  12: 0.000377735,
					  20: 0.000388505] // 95th percentile
let ks_n = 1e7

class RollCounts: NSObject {
	var countsForNumbers: Dictionary<Int,Int> = [:]

	var name: String? = nil

	var totalCount = 0
	var maxCount = 0
	var stdev = 0.0
	var chisq = 0.0

	var expectedValue = 0.0
	var expectedStdev = 0.0

	var cumulHist: Dictionary<Int,Int> = [:]
	var cumulExpectedValue: Dictionary<Int,Double> = [:]
	var cumulExpectedStdev: Dictionary<Int,Double> = [:]

	var ks = 0.0

	func resetCounts(_ nSides: Int) {
		self.countsForNumbers = [:]
		self.name = nil
		for i in 1...nSides {
			countsForNumbers[i] = 0
		}
		self.recalculateStats()
	}

	func incrementCountForNumber(_ number: Int, by incrementor: Int) {
		if var value = self.countsForNumbers[number] {
			value += incrementor
			if value < 0 {
				value = 0
			}
			self.countsForNumbers[number] = value
			self.recalculateStats()
		}
	}

	func recalculateStats() {
		let k = Double(self.countsForNumbers.count) // number of sides on the die

		self.totalCount = 0
		self.maxCount = 0
		for i in (1...Int(k)).reversed() {
			let n_i = self.countsForNumbers[i]!
			self.totalCount += n_i
			if n_i > self.maxCount {
				self.maxCount = n_i
			}

			self.cumulHist[i] = 0
			for j in (i...Int(k)) {
				self.cumulHist[i]! += self.countsForNumbers[j]! // i.e., n_j
			}
		}

		let n = Double(self.totalCount) // number of rolls

		if k > 0 {
			let p_i = 1.0/k // for all values of i
			self.expectedValue = n*p_i
			self.expectedStdev = sqrt(n*p_i*(1.0 - p_i))
		}
		else {
			self.expectedValue = 0.0
			self.expectedStdev = 0.0
		}

		for i in (1...Int(k)) {
			let p_i = 1.0 - Double(i - 1)/k
			self.cumulExpectedValue[i] = n*p_i
			self.cumulExpectedStdev[i] = sqrt(n*p_i*(1.0 - p_i))
		}

		var accum = 0.0
		self.chisq = 0.0
		var maxKSDistance = 0.0
		for i in 1...Int(k) {
			let n_i = Double(self.countsForNumbers[i]!)
			let dev = n_i - self.expectedValue
			accum += dev*dev
			self.chisq += dev*dev/self.expectedValue
			let ksDistance = abs(Double(self.cumulHist[i]!) - self.expectedValue*(k - Double(i - 1)))
			if ksDistance > maxKSDistance {
				maxKSDistance = ksDistance
			}
		}
		if n > 1.0 {
			self.stdev = sqrt(accum/(n - 1.0))
		}
		else {
			self.stdev = 0.0
		}
		self.ks = maxKSDistance/n
	}

	func isChiSqSignificant95() -> Bool {
		if let benchmark = chiTable95[self.countsForNumbers.count],
			self.chisq >= benchmark {
			return true
		}
		return false
	}

	func isChiSqSignificant99() -> Bool {
		if let benchmark = chiTable99[self.countsForNumbers.count],
			self.chisq >= benchmark {
			return true
		}
		return false
	}

	func isKSSignificant95() -> Bool {
		if self.totalCount < 36 {
			return false
		}
		if let benchmark = ksTable95[self.countsForNumbers.count],
			self.ks >= benchmark*sqrt(ks_n)/sqrt(Double(self.totalCount)) {
			return true
		}
		return false
	}

	func isKSSignificant99() -> Bool {
		if self.totalCount < 36 {
			return false
		}
		if let benchmark = ksTable99[self.countsForNumbers.count],
			self.ks >= benchmark*sqrt(ks_n)/sqrt(Double(self.totalCount)) {
			return true
		}
		return false
	}
}
