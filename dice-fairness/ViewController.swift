//
//  ViewController.swift
//  dice-fairness
//
//  Created by John Bender on 3/27/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

let nSides = 8

class ViewController: UIViewController {

	@IBOutlet weak var buttonAreaHeightConstraint: NSLayoutConstraint?

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? ButtonViewController {
			vc.setNButtons(nSides)
			vc.buttonAreaHeightConstraint = self.buttonAreaHeightConstraint
		}
		else if let vc = segue.destination as? GraphViewController {
			vc.setNBars(nSides)
		}
	}

}

