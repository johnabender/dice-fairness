//
//  ViewController.swift
//  dice-fairness
//
//  Created by John Bender on 3/27/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

let initialNSides = 8

class ViewController: UIViewController {

	@IBOutlet weak var optionsButton: UIBarButtonItem? = nil

	@IBOutlet weak var topGraphAreaHeightConstraint: NSLayoutConstraint? = nil
	@IBOutlet weak var buttonAreaHeightConstraint: NSLayoutConstraint? = nil

	@IBOutlet weak var buttonAreaView: UIView? = nil

	var buttonVC: ButtonViewController? = nil

	var graphVCTop: GraphViewController? = nil
	var graphVCMiddle: GraphViewController? = nil
	var graphVCBottom: GraphViewController? = nil

	override func viewDidLoad() {
		super.viewDidLoad()

		self.topGraphAreaHeightConstraint?.constant = 0.0

		RollCountsController.shared.resetCountsWithNSides(initialNSides)

		Options.shared.load()

		NotificationCenter.default.addObserver(self, selector: #selector(loadedSecondDie), name: NSNotification.Name(rawValue: "loadedSecondDie"), object: nil)

		/*
		///////////////////
//		RollCountsController.shared.loadCountsWithTitle(">2-008-2018-06-22")
		RollCountsController.shared.loadCountsWithTitle(">2-008-2018-07-13")
		let secondCounts = RollCountsController()
//		secondCounts.loadCountsWithTitle(">2-008-2018-06-22")
		secondCounts.loadCountsWithTitle(">2-008-2018-07-13")
		RollCountsController.shared.setSecondRollCounts(secondCounts.rollCounts)
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadedSecondDie"),
												  object: secondCounts.rollCounts)
		///////////////////
*/
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// if we're showing multiple dice, change display options
		if RollCountsController.shared.secondRollCounts != nil {
			let individualOptions = Options.shared.copy() as! Options
			individualOptions.drawFairnessEnvelope = false
			let groupOptions = Options.shared.copy() as! Options

			if let graphView = self.graphVCTop?.view as? GraphView {
				graphView.options = groupOptions
			}
			if let graphView = self.graphVCMiddle?.view as? GraphView {
				graphView.options = individualOptions
			}
			if let graphView = self.graphVCBottom?.view as? GraphView {
				graphView.options = individualOptions
			}
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		// https://stackoverflow.com/questions/47754472/
		self.optionsButton?.isEnabled = false
		self.optionsButton?.isEnabled = true
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		if let buttonVC = segue.destination as? ButtonViewController {
			self.buttonVC = buttonVC
			buttonVC.buttonAreaHeightConstraint = self.buttonAreaHeightConstraint
		}
		else if let graphVC = segue.destination as? GraphViewController {
			if graphVC.restorationIdentifier == "GraphViewControllerTop" {
				self.graphVCTop = graphVC
			}
			else {
				self.graphVCBottom = graphVC
				if let graphView = graphVC.view as? GraphView {
					graphView.showFullStats = true
				}
			}
		}
	}

	@IBAction func pressedResetCounts() {
		RollCountsController.shared.secondRollCounts = nil
		RollCountsController.shared.resetCounts()
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadedSecondDie"), object: nil)
	}

	@objc func loadedSecondDie(note: Notification) {
		let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

		// remove button view, if present
		self.removeMiddleVC(self.buttonVC)
		self.buttonVC = nil

		// remove old graph view, if present
		self.removeMiddleVC(self.graphVCMiddle)
		self.graphVCMiddle = nil

		if note.object == nil {
			// second die is hidden

			self.topGraphAreaHeightConstraint?.constant = 0.0

			if let buttonVC = storyboard.instantiateViewController(withIdentifier: "ButtonViewController") as? ButtonViewController {
				self.buttonVC = buttonVC
				buttonVC.buttonAreaHeightConstraint = self.buttonAreaHeightConstraint
				self.layoutNewMiddleVC(buttonVC)
			}

			if let graphView = self.graphVCBottom?.view as? GraphView {
				graphView.showFullStats = true
				graphView.options = Options.shared
			}
		}
		else if let secondRollCounts = note.object as? RollCounts {
			// second die is shown

			var ownHeight = self.view.frame.size.height - UIApplication.shared.statusBarFrame.size.height
			if self.navigationController != nil {
				ownHeight -= self.navigationController!.navigationBar.frame.size.height
			}

			let topGraphHeight = 0.4*ownHeight
			self.topGraphAreaHeightConstraint?.constant = topGraphHeight
			self.buttonAreaHeightConstraint?.constant = (ownHeight - topGraphHeight)/2.0

			if let graphVC = storyboard.instantiateViewController(withIdentifier: "GraphViewController") as? GraphViewController {
				if let graphView = graphVC.view as? GraphView {
					graphView.rollCounts = secondRollCounts
				}
				self.graphVCMiddle = graphVC
				self.layoutNewMiddleVC(graphVC)
			}

			if let graphView = self.graphVCTop?.view as? GraphView {
				graphView.rollCounts = RollCountsController.shared.combinedRollCounts
				graphView.setupLabels()
			}

			if let graphView = self.graphVCBottom?.view as? GraphView {
				graphView.rollCounts = RollCountsController.shared.rollCounts
				graphView.showFullStats = false
			}
		}
	}

	func removeMiddleVC(_ vc: UIViewController?) {
		vc?.willMove(toParent: nil)
		vc?.view.removeFromSuperview()
		vc?.removeFromParent()
	}

	func layoutNewMiddleVC(_ vc: UIViewController) {
		self.addChild(vc)
		vc.view.translatesAutoresizingMaskIntoConstraints = false
		self.buttonAreaView?.addSubview(vc.view)
		vc.didMove(toParent: self)
		self.buttonAreaView?.addConstraints([
            NSLayoutConstraint(item: vc.view as Any, attribute: .top, relatedBy: .equal, toItem: self.buttonAreaView, attribute: .top, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: vc.view as Any, attribute: .left, relatedBy: .equal, toItem: self.buttonAreaView, attribute: .left, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: vc.view as Any, attribute: .right, relatedBy: .equal, toItem: self.buttonAreaView, attribute: .right, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: vc.view as Any, attribute: .bottom, relatedBy: .equal, toItem: self.buttonAreaView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
		])
	}
}
