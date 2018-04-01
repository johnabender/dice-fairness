//
//  OptionsViewController.swift
//  dice-fairness
//
//  Created by John Bender on 3/30/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {
	@IBAction func chooseDice(sender: UIButton) {
		if let newSides = Int((sender.accessibilityIdentifier)!) {
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sidesChanged"), object: nil, userInfo: ["newSides": newSides])
		}
	}

	@IBAction func pressedLoad() {
	}

	@IBAction func pressedSave() {
	}
}
