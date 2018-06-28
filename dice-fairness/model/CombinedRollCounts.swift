//
//  CombinedRollCounts.swift
//  dice-fairness
//
//  Created by John Bender on 6/22/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import Foundation

// https://stackoverflow.com/a/28075467
public extension Double {

	/// Returns a random floating point number between 0.0 and 1.0, inclusive.
	public static var random: Double {
		return Double(arc4random()) / 0xFFFFFFFF
	}

	/// Random double between 0 and n-1.
	public static func random(min: Double, max: Double) -> Double {
		return Double.random * (max - min) + min
	}
}

class CombinedRollCounts: RollCounts {
	let rollCounts: [RollCounts]

	var expectedValues: Dictionary<Int,Double> = [:]
	var expectedStdevs: Dictionary<Int,Double> = [:]

	init(_ rollCounts: [RollCounts]) {
		self.rollCounts = rollCounts

		super.init()

		var minVal = 0
		var maxVal = 0
		for count in self.rollCounts {
			minVal += count.minVal
			maxVal += count.maxVal
		}

		self.resetCounts(minVal: minVal, maxVal: maxVal)
		self.estimateCounts()
		self.recalculateStats()
	}

	func estimateCounts() {
		for _ in 1...100000 {
			var sum = 0
			for die in self.rollCounts {
				let r = Double.random
				for val in (die.minVal...die.maxVal).reversed() {
					if 1.0 - r < Double(die.cumulHist[val]!)/Double(die.totalCount) {
						sum += val
						break
					}
				}
			}
			self.countsForNumbers[sum]! += 1
		}
	}

	override func recalculateStats() {
		super.recalculateStats()

		let k = Double(self.nSides()) // number of sides on the die
		let n = Double(self.totalCount) // number of rolls

		if k > 0 {
			if self.rollCounts.count == 2 {
				var count_i: Dictionary<Int,Int> = [:]
				var count_k = 0
				for a in self.rollCounts[0].countsForNumbers.keys {
					for b in self.rollCounts[1].countsForNumbers.keys {
						if count_i[a + b] == nil {
							count_i[a + b] = 0
						}
						count_i[a + b]! += 1
						count_k += 1
					}
				}

				self.expectedValues = [:]
				self.expectedStdevs = [:]
				for i in count_i.keys {
					let p_i = Double(count_i[i]!)/Double(count_k)
					self.expectedValues[i] = n*p_i
					self.expectedStdevs[i] = sqrt(n*p_i*(1.0 - p_i))
				}
			}
			// else not implemented, would need to make more generic/recursive

			self.expectedValue = 0.0
			self.expectedStdev = 0.0
		}

		/*
		for i in (minVal...maxVal) {
			let p_i = 1.0 - Double(i - minVal)/k
			self.cumulExpectedValue[i] = n*p_i
			self.cumulExpectedStdev[i] = sqrt(n*p_i*(1.0 - p_i))
		}

		var accum = 0.0
		self.chisq = 0.0
		var maxKSDistance = 0.0
		for i in minVal...maxVal {
			let n_i = Double(self.countsForNumbers[i]!)
			let dev = n_i - self.expectedValue
			accum += dev*dev
			self.chisq += dev*dev/self.expectedValue
			let ksDistance = abs(Double(self.cumulHist[i]!) - self.expectedValue*(k - Double(i - minVal)))
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
*/
	}
}
