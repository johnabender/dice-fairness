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
}
