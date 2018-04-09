//
//  RecentRollsViewController.swift
//  dice-fairness
//
//  Created by John Bender on 4/8/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

class RecentRollsViewController: UIViewController {
	@IBOutlet weak var textView: UITextView? = nil
	@IBOutlet weak var blurView: UIView? = nil

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(countsUpdated), name: NSNotification.Name(rawValue: "countsUpdated"), object: nil)

		self.textView?.text = "\n\n\n\n\n\n\n\n\n\n"
	}

	override func viewDidLayoutSubviews() {
		if self.blurView == nil { return }

		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = self.blurView!.bounds
		gradientLayer.colors = [UIColor(white: 0.0, alpha: 1.0).cgColor, UIColor(white: 0.0, alpha: 0.0).cgColor]
		gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
		gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
		self.blurView!.layer.mask = gradientLayer
	}

	@objc func countsUpdated(note: Notification) {
		if let number = note.userInfo?["number"] as? Int {
			self.textView?.text.append(String(format: "%d\n", number))
			self.textView?.scrollRangeToVisible(NSRange(location: (self.textView?.text.count)! - 2, length: 0))
			self.textView?.isScrollEnabled = false
			self.textView?.isScrollEnabled = true
		}
		else {
			self.textView?.text = "\n\n\n\n\n\n\n\n\n\n"
		}
	}
}
