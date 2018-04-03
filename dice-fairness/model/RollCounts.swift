//
//  RollCounts.swift
//  dice-fairness
//
//  Created by John Bender on 4/1/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

class RollCounts: NSObject {
	var countsForNumbers: Dictionary<Int,Int> = [:]
	var name: String? = nil

	func resetCounts(_ nSides: Int) {
		self.countsForNumbers = [:]
		for i in 1...nSides {
			countsForNumbers[i] = 0
		}
	}
}
