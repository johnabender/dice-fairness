//
//  Options.swift
//  dice-fairness
//
//  Created by John Bender on 4/6/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

let saveKey = "options-dice-fairness"

class Options: NSObject, NSCopying {
	static let shared = Options()

	var drawWhiskers = false
	var drawFairnessLine = true
	var drawFairnessEnvelope = true
	var drawCumulHist = true

	func load() {
		let dict = UserDefaults.standard.dictionary(forKey: saveKey)
		if dict == nil { return }
		if let drawWhiskers = dict!["drawWhiskers"] as? Bool {
			self.drawWhiskers = drawWhiskers
		}
		if let drawFairnessLine = dict!["drawFairnessLine"] as? Bool {
			self.drawFairnessLine = drawFairnessLine
		}
		if let drawFairnessEnvelope = dict!["drawFairnessEnvelope"] as? Bool {
			self.drawFairnessEnvelope = drawFairnessEnvelope
		}
		if let drawCumulHist = dict!["drawCumulHist"] as? Bool {
			self.drawCumulHist = drawCumulHist
		}
	}

	func save() {
		UserDefaults.standard.set(["drawWhiskers": self.drawWhiskers,
                                   "drawFairnessLine": self.drawFairnessLine,
                                   "drawFairnessEnvelope": self.drawFairnessEnvelope,
                                   "drawCumulHist": self.drawCumulHist],
                                  forKey: saveKey)
	}

	func copy(with zone: NSZone? = nil) -> Any {
		let copy = Options()
		copy.drawWhiskers = self.drawWhiskers
		copy.drawFairnessLine = self.drawFairnessLine
		copy.drawFairnessEnvelope = self.drawFairnessEnvelope
		copy.drawCumulHist = self.drawCumulHist

		return copy
	}
}
