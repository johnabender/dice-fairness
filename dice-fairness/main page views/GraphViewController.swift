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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if let view = self.view as? GraphView {
			view.setupLabels(RollCountsController.shared.currentNSides())
		}
	}

	@objc func countsUpdated(note: Notification) {
		if let rollCounts = note.object as? RollCounts, let view = self.view as? GraphView {
			view.rollCounts = rollCounts
			view.setNeedsDisplay()
		}
	}
}
