//
//  RollCountsController.swift
//  dice-fairness
//
//  Created by John Bender on 4/1/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

let savePrefix = "dice-fairness-"

class RollCountsController: NSObject {
	static let shared = RollCountsController()

	var rollCounts: RollCounts = RollCounts()
	var secondRollCounts: RollCounts? = nil
	var combinedRollCounts: CombinedRollCounts? = nil

	var hasChanged = false

	func setSecondRollCounts(_ second: RollCounts) {
		self.secondRollCounts = second
		self.combinedRollCounts = CombinedRollCounts([self.rollCounts, self.secondRollCounts!])
	}

	func currentNSides() -> Int {
		return self.rollCounts.nSides()
	}

	func resetCounts() {
		self.rollCounts.resetCounts(minVal: 1, maxVal: self.currentNSides())
		self.hasChanged = false
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countsUpdated"),
												  object: self.rollCounts)
	}

	func resetCountsWithNSides(_ nSides: Int) {
		self.rollCounts.resetCounts(minVal: 1, maxVal: nSides)
		self.hasChanged = false
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countsUpdated"),
												  object: self.rollCounts)
	}

	func incrementCountForNumber(_ number: Int, by incrementor: Int) {
		self.rollCounts.incrementCountForNumber(number, by: incrementor)
		self.hasChanged = true
		let userInfo = ["number": number,
							 "count": self.rollCounts.countsForNumbers[number]!,
							 "incrementor": incrementor]
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countsUpdated"),
												  object: self.rollCounts,
												  userInfo: userInfo)
	}

	func canSaveCurrentRolls() -> Bool {
		if !self.hasChanged { return false }

		for counts in self.rollCounts.countsForNumbers.values {
			if counts > 0 {
				return true
			}
		}
		return false
	}

	func getCurrentDateStamp() -> String {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = .withFullDate
		return dateFormatter.string(from: Date.init())
	}

	func saveCountsWithTitle(_ title: String) {
		let data = NSKeyedArchiver.archivedData(withRootObject: self.rollCounts.countsForNumbers)
		let formattedCount = String(format: "%03d", self.rollCounts.nSides())
		let saveSuffix = "-" + formattedCount + "-" + self.getCurrentDateStamp()
		UserDefaults.standard.set(data, forKey: savePrefix + title + saveSuffix)
		self.rollCounts.name = title + saveSuffix
		self.hasChanged = false
	}

	func listSavedCounts() -> [String] {
		var savedCounts: [String] = []
		for key in UserDefaults.standard.dictionaryRepresentation().keys {
			if key.hasPrefix(savePrefix) {
				savedCounts.append((key as NSString).substring(from: savePrefix.count))
			}
		}
		return savedCounts
	}

	func loadCountsWithTitle(_ title: String) {
		if let data = UserDefaults.standard.object(forKey: savePrefix + title) as? NSData,
			let newCounts = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? Dictionary<Int,Int> {
			self.rollCounts.countsForNumbers = newCounts
			self.rollCounts.name = title
			var min = 0, max = 0
			for key in newCounts.keys {
				if min == 0 || key < min {
					min = key
				}
				if key > max {
					max = key
				}
			}
			self.rollCounts.minVal = min
			self.rollCounts.maxVal = max
			self.rollCounts.recalculateStats()
			self.hasChanged = false
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countsUpdated"),
													  object: self.rollCounts)
		}
	}

	func deleteSavedCountsWithTitle(_ title: String) {
		UserDefaults.standard.removeObject(forKey: savePrefix + title)
	}
}
