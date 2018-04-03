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

	func currentNSides() -> Int {
		return self.rollCounts.countsForNumbers.count
	}

	func resetCounts() {
		self.rollCounts.resetCounts(self.currentNSides())
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countsUpdated"),
												  object: self.rollCounts)
	}

	func resetCountsWithNSides(_ nSides: Int) {
		self.rollCounts.resetCounts(nSides)
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

	func canSaveCurrentRolls() -> Bool {
		for counts in self.rollCounts.countsForNumbers.values {
			if counts > 0 {
				return true
			}
		}
		return false
	}

	func saveCountsWithTitle(_ title: String) -> Bool {
		if UserDefaults.standard.dictionaryRepresentation()[savePrefix + title] != nil {
			return false
		}

		self.rollCounts.name = title
		let data = NSKeyedArchiver.archivedData(withRootObject: self.rollCounts.countsForNumbers)
		UserDefaults.standard.set(data, forKey: savePrefix + title)
		return true
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
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countsUpdated"),
													  object: self.rollCounts)
		}
	}

	func deleteSavedCountsWithTitle(_ title: String) {
		UserDefaults.standard.removeObject(forKey: savePrefix + title)
	}
}
