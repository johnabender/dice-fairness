//
//  StatsTutorialViewController.swift
//  dice-fairness
//
//  Created by John Bender on 4/3/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

class StatsTutorialViewController: UIViewController {

	@IBOutlet weak var textView: UITextView? = nil

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.textView?.setContentOffset(.zero, animated: false)
	}
}

/*
extension StatsTutorialViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.scrollView
	}
}
*/
