//
//  NumberView.swift
//  dice-fairness
//
//  Created by John Bender on 3/29/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

// https://stackoverflow.com/questions/9282365/
class NumberView: UIView {

	@IBOutlet weak var button: UIButton?
	@IBOutlet weak var label: UILabel?

	var contentView: UIView?

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.addViewFromNib()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		self.addViewFromNib()
	}

	func addViewFromNib() {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
		if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
			view.frame = self.bounds
			self.addSubview(view)
			self.contentView = view
		}
	}
}
