//
//  GraphViewController.swift
//  dice-fairness
//
//  Created by John Bender on 3/27/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

	var rollCounts = RollCountsController.shared.rollCounts

	override func viewDidLoad() {
		super.viewDidLoad()

		// This will cause all GraphViewControllers to update to the same new counts,
		// if this notification is ever received when there are multiple GraphViewControllers
		// on the screen at the same time. The idea is never to send the notifications
		// when in that state, because counts aren't being updated.
		NotificationCenter.default.addObserver(self, selector: #selector(countsUpdated), name: NSNotification.Name(rawValue: "countsUpdated"), object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if let view = self.view as? GraphView {
			view.rollCounts = self.rollCounts
			view.setupLabels()
			view.setNeedsDisplay()
		}
	}

	@objc func countsUpdated(note: Notification) {
		if let rollCounts = note.object as? RollCounts, let view = self.view as? GraphView {
			view.rollCounts = rollCounts
			view.setNeedsDisplay()
		}
	}
}
