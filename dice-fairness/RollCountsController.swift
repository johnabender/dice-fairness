//
//  RollCountsController.swift
//  dice-fairness
//
//  Created by John Bender on 4/1/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

class RollCountsController: NSObject {
	static let shared = RollCountsController()

	var rollCounts: RollCounts = RollCounts()

	func currentNSides() -> Int {
		return self.rollCounts.countsForNumbers.count
	}

	func resetCounts() {
		print("reset counts")
		self.rollCounts.resetCounts(self.currentNSides())
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countsUpdated"),
												  object: self.rollCounts)
	}

	func resetCountsWithNSides(_ nSides: Int) {
		print("reset counts with", nSides)
		self.rollCounts.resetCounts(nSides)
		print("roll conuts is", self.rollCounts.countsForNumbers)
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countsUpdated"),
												  object: self.rollCounts)
	}

	func incrementCountForNumber(_ number: Int, by incrementor: Int) {
		if var value = self.rollCounts.countsForNumbers[number] {
			value += incrementor
			if value < 0 {
				value = 0
			}
			self.rollCounts.countsForNumbers[number] = value

			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countsUpdated"),
													  object: self.rollCounts,
													  userInfo: ["number": number, "count": value])
		}
	}
}
