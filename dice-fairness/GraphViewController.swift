//
//  GraphViewController.swift
//  dice-fairness
//
//  Created by John Bender on 3/27/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(countsUpdated), name: NSNotification.Name(rawValue: "countsUpdated"), object: nil)
	}

	func setNBars(_ n: Int) {
		DispatchQueue.main.async {
			if let view = self.view as? GraphView {
				view.setupLabels(n)
			}
		}
	}

	@objc func countsUpdated(note: Notification) {
		if let dict = note.object as? Dictionary<Int,Int>, let view = self.view as? GraphView {
			view.countsForNumbers = dict
			view.setNeedsDisplay()
		}
	}
}
