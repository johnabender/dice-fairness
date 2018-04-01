//
//  ViewController.swift
//  dice-fairness
//
//  Created by John Bender on 3/27/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

let initialNSides = 20

class ViewController: UIViewController {

	@IBOutlet weak var buttonAreaHeightConstraint: NSLayoutConstraint?

	override func viewDidLoad() {
		super.viewDidLoad()

		RollCountsController.shared.resetCountsWithNSides(initialNSides)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let buttonVC = segue.destination as? ButtonViewController {
			buttonVC.buttonAreaHeightConstraint = self.buttonAreaHeightConstraint
		}
	}

	@IBAction func pressedResetCounts() {
		RollCountsController.shared.resetCounts()
	}
}
