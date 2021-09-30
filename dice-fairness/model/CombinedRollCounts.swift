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
	static var random: Double {
		return Double(arc4random()) / 0xFFFFFFFF
	}

	/// Random double between 0 and n-1.
	static func random(min: Double, max: Double) -> Double {
		return Double.random * (max - min) + min
	}
}

class CombinedRollCounts: RollCounts {
	let rollCounts: [RollCounts]

	var expectedValues: Dictionary<Int,Double> = [:]

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
				for i in count_i.keys {
					let p_i = Double(count_i[i]!)/Double(count_k)
					self.expectedValues[i] = n*p_i
				}

				for i in minVal...maxVal {
					var accum = 0.0
					for j in minVal..<i {
						accum += self.expectedValues[j]!
					}
					self.cumulExpectedValue[i] = n - accum
				}
			}
			// else not implemented, would need to make more generic/recursive

			self.expectedValue = 0.0
			self.expectedStdev = 0.0
			self.chisq = 0.0
			self.ks = 0.0
		}
	}
}
