//
//  ButtonViewController.swift
//  dice-fairness
//
//  Created by John Bender on 3/27/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

let horzContainerSize = CGFloat(130)
let vertContainerMinSize = CGFloat(35)
let vertContainerMaxSize = CGFloat(55)
let vertContainerMaxSpacing = CGFloat(20)

class ButtonViewController: UIViewController {

	weak var buttonAreaHeightConstraint: NSLayoutConstraint?

	var numberViews: [NumberView] = []

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(countsUpdated), name: NSNotification.Name(rawValue: "countsUpdated"), object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.updateLayout()
	}

	func updateLayout() {
		let nButtons = RollCountsController.shared.currentNSides()
		if nButtons == self.numberViews.count { return }

		for v in self.numberViews {
			v.removeFromSuperview()
		}
		self.numberViews = []

		// decide on spacing for layout
		let buttonsPerCol = nButtons/2
		let vertViewDefaultSize = CGFloat(10)*vertContainerMinSize // 10 = half the max expected number
		var vertContainerSize = vertContainerMinSize
		var vertContainerSpacing = (vertViewDefaultSize - CGFloat(buttonsPerCol)*vertContainerSize)/CGFloat(buttonsPerCol + 1)
		if vertContainerSpacing > vertContainerMaxSpacing {
			vertContainerSpacing = vertContainerMaxSpacing
			vertContainerSize = (vertViewDefaultSize - CGFloat(buttonsPerCol + 1)*vertContainerSpacing)/CGFloat(buttonsPerCol)
			if vertContainerSize > vertContainerMaxSize {
				vertContainerSize = vertContainerMaxSize
			}
		}
		let desiredViewHeight = CGFloat(buttonsPerCol)*(vertContainerSize + vertContainerSpacing) + vertContainerSpacing
		self.buttonAreaHeightConstraint?.constant = desiredViewHeight
		if self.buttonAreaHeightConstraint == nil { print("no constraint") }

		// add individual number buttons
		for i in 0..<nButtons {
			if let nibViews = Bundle.main.loadNibNamed("NumberView", owner: self, options: nil), nibViews.count > 0, let numberView = nibViews[0] as? NumberView {
				numberView.translatesAutoresizingMaskIntoConstraints = false
				numberView.button?.setTitle(String(format: "%d", i + 1), for: .normal)
				numberView.button?.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
				if (numberView.button?.gestureRecognizers?.count)! > 0 {
					numberView.button!.gestureRecognizers![0].addTarget(self, action: #selector(buttonLongPressed))
				}
				numberView.label?.text = String(format: "%d", RollCountsController.shared.rollCounts.countsForNumbers[i + 1]!)

				self.numberViews.append(numberView)
				self.view.addSubview(numberView)

				let y = vertContainerSpacing + CGFloat(i % buttonsPerCol)*(vertContainerSpacing + vertContainerSize)
				let viewTop = NSLayoutConstraint(item: numberView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: y)
				let viewHeight = NSLayoutConstraint(item: numberView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: vertContainerSize)
				let viewWidth = NSLayoutConstraint(item: numberView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: horzContainerSize)
				self.view.addConstraint(viewTop)
				numberView.addConstraints([viewHeight, viewWidth])

				if i < nButtons/2 {
					self.view.addConstraint(NSLayoutConstraint(item: numberView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 0.55, constant: 0.0))
				}
				else {
					self.view.addConstraint(NSLayoutConstraint(item: numberView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.45, constant: 0.0))
				}
			}
		}
	}

	func indexFromEvent(_ sender: Any?) -> Int {
		if let button = sender as? UIButton {
			for (i, v) in self.numberViews.enumerated() {
				if button.superview == v {
					return i
				}
			}
		}
		else if let gestureRecognizer = sender as? UIGestureRecognizer {
			for (i, v) in self.numberViews.enumerated() {
				if gestureRecognizer.view?.superview == v {
					return i
				}
			}
		}
		print("failed finding a sender match for event from %@", sender!)
		return -1
	}

	@objc func buttonPressed(sender: Any?) {
		let i = self.indexFromEvent(sender)
		RollCountsController.shared.incrementCountForNumber(i + 1, by: 1)
	}

	@objc func buttonLongPressed(sender: Any?) {
		if let gestureRecognizer = sender as? UIGestureRecognizer, gestureRecognizer.state == .began {
			let i = self.indexFromEvent(sender)
			RollCountsController.shared.incrementCountForNumber(i + 1, by: -1)
		}
	}

	@objc func countsUpdated(note: Notification) {
		if RollCountsController.shared.currentNSides() != self.numberViews.count {
			self.updateLayout()
		}
		else if let number = note.userInfo?["number"] as? Int,
			let count = note.userInfo?["count"] as? Int {
			self.numberViews[number - 1].label?.text = String(format: "%d", count)
		}
		else {
			for (i,v) in self.numberViews.enumerated() {
				v.label?.text = String(format: "%d", RollCountsController.shared.rollCounts.countsForNumbers[i + 1]!)
			}
		}
	}
}
