//
//  ButtonViewController.swift
//  dice-fairness
//
//  Created by John Bender on 3/27/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

let horzContainerSize = CGFloat(130)
let vertContainerMinSize = CGFloat(44)
let vertContainerMaxSize = CGFloat(55)
let vertContainerMaxSpacing = CGFloat(20)

class ButtonViewController: UIViewController {

	weak var buttonAreaHeightConstraint: NSLayoutConstraint?

	var numberViews: [NumberView] = []
	var countsForNumbers: Dictionary<Int,Int> = [:]

	func setNButtons(_ n: Int) {
		DispatchQueue.main.async {
			self.updateLayout(n)
		}
	}

	func updateLayout(_ nButtons: Int) {
		for v in self.numberViews {
			v.removeFromSuperview()
		}
		self.numberViews = []
		self.countsForNumbers = Dictionary<Int,Int>()

		// decide on spacing for layout
		let buttonsPerCol = nButtons/2
		let horzContainerSpacing = (self.view.frame.size.width - 2*horzContainerSize)/3
		var vertContainerSize = vertContainerMinSize
		var vertContainerSpacing = (self.view.frame.size.height - CGFloat(buttonsPerCol)*vertContainerSize)/CGFloat(buttonsPerCol + 1)
		if vertContainerSpacing > vertContainerMaxSpacing {
			vertContainerSpacing = vertContainerMaxSpacing
			vertContainerSize = (self.view.frame.size.height - CGFloat(buttonsPerCol + 1)*vertContainerSpacing)/CGFloat(buttonsPerCol)
			if vertContainerSize > vertContainerMaxSize {
				vertContainerSize = vertContainerMaxSize
				let desiredViewHeight = CGFloat(buttonsPerCol)*(vertContainerSize + vertContainerSpacing) + vertContainerSpacing
				self.buttonAreaHeightConstraint?.constant = desiredViewHeight
			}
		}

		// add individual number buttons
		for i in 0..<nButtons {
			if let nibViews = Bundle.main.loadNibNamed("NumberView", owner: self, options: nil), nibViews.count > 0, let numberView = nibViews[0] as? NumberView {
				numberView.translatesAutoresizingMaskIntoConstraints = false
				numberView.button?.setTitle(String(format: "%d", i + 1), for: .normal)
				numberView.button?.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
				if (numberView.button?.gestureRecognizers?.count)! > 0 {
					numberView.button!.gestureRecognizers![0].addTarget(self, action: #selector(buttonLongPressed))
				}

				self.countsForNumbers[i + 1] = 0
				self.numberViews.append(numberView)
				self.view.addSubview(numberView)

				var x = horzContainerSpacing
				if i >= buttonsPerCol {
					x += horzContainerSize + horzContainerSpacing
				}
				let y = vertContainerSpacing + CGFloat(i % buttonsPerCol)*(vertContainerSpacing + vertContainerSize)
				let viewTop = NSLayoutConstraint(item: numberView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: y)
				let viewLeft = NSLayoutConstraint(item: numberView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: x)
				let viewHeight = NSLayoutConstraint(item: numberView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: vertContainerSize)
				let viewWidth = NSLayoutConstraint(item: numberView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: horzContainerSize)

				self.view.addConstraints([viewTop, viewLeft])
				numberView.addConstraints([viewHeight, viewWidth])
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
		let curCount = self.countsForNumbers[i + 1]!
		self.countsForNumbers[i + 1] = curCount + 1
		self.numberViews[i].label?.text = String(format: "%d", curCount + 1)
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countsUpdated"), object: self.countsForNumbers, userInfo: nil)
	}

	@objc func buttonLongPressed(sender: Any?) {
		if let gestureRecognizer = sender as? UIGestureRecognizer, gestureRecognizer.state == .began {
			let i = self.indexFromEvent(sender)
			let curCount = self.countsForNumbers[i + 1]!
			if curCount > 0 {
				self.countsForNumbers[i + 1] = curCount - 1
				self.numberViews[i].label?.text = String(format: "%d", curCount - 1)
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countsUpdated"), object: self.countsForNumbers, userInfo: nil)
			}
		}
	}
}
