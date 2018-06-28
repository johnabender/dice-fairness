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

		///////////////////
//		RollCountsController.shared.loadCountsWithTitle("asee-008-2018-06-21")
		RollCountsController.shared.loadCountsWithTitle(">2-008-2018-06-22")
		let secondCounts = RollCountsController()
//		secondCounts.loadCountsWithTitle("asee2-008-2018-06-22")
		secondCounts.loadCountsWithTitle(">2-008-2018-06-22")
		RollCountsController.shared.setSecondRollCounts(secondCounts.rollCounts)
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadedSecondDie"),
												  object: secondCounts.rollCounts)
		///////////////////
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
				if let graphView = graphVC.view as? GraphView {
					graphView.isMultiDie = true
				}
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
				graphVC.rollCounts = secondRollCounts
				self.graphVCMiddle = graphVC
				self.layoutNewMiddleVC(graphVC)
			}

			self.graphVCTop?.rollCounts = RollCountsController.shared.combinedRollCounts!
			if let graphView = self.graphVCTop?.view as? GraphView {
				graphView.setupLabels()
			}

			if let graphView = self.graphVCBottom?.view as? GraphView {
				graphView.showFullStats = false
			}
		}
	}

	func removeMiddleVC(_ vc: UIViewController?) {
		vc?.willMove(toParentViewController: nil)
		vc?.view.removeFromSuperview()
		vc?.removeFromParentViewController()
	}

	func layoutNewMiddleVC(_ vc: UIViewController) {
		self.addChildViewController(vc)
		vc.view.translatesAutoresizingMaskIntoConstraints = false
		self.buttonAreaView?.addSubview(vc.view)
		vc.didMove(toParentViewController: self)
		self.buttonAreaView?.addConstraints([
			NSLayoutConstraint(item: vc.view, attribute: .top, relatedBy: .equal, toItem: self.buttonAreaView, attribute: .top, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: vc.view, attribute: .left, relatedBy: .equal, toItem: self.buttonAreaView, attribute: .left, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: vc.view, attribute: .right, relatedBy: .equal, toItem: self.buttonAreaView, attribute: .right, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: vc.view, attribute: .bottom, relatedBy: .equal, toItem: self.buttonAreaView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
		])
	}
}
