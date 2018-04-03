//
//  GraphView.swift
//  dice-fairness
//
//  Created by John Bender on 3/30/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

let barSpacing = CGFloat(2)
let sideMargins = CGFloat(20)
let topMargin = CGFloat(20)
let bottomMargin = CGFloat(30)
let labelHeight = CGFloat(20)

class GraphView: UIView {

	var rollCounts: RollCounts = RollCounts()

	// https://stackoverflow.com/questions/28284063/how-do-i-get-auto-adjusted-font-size-in-ios-7-0-or-later/28285447#28285447
	func approximateAdjustedFontSizeWithLabel(_ label: UILabel) -> CGFloat {
		var currentFont: UIFont = label.font
		let originalFontSize = currentFont.pointSize
		var currentSize: CGSize = (label.text! as NSString).size(withAttributes: [NSAttributedStringKey.font: currentFont])

		while currentSize.width > label.frame.size.width && currentFont.pointSize > (originalFontSize * label.minimumScaleFactor) {
			currentFont = currentFont.withSize(currentFont.pointSize - 1.0)
			currentSize = (label.text! as NSString).size(withAttributes: [NSAttributedStringKey.font: currentFont])
		}

		return currentFont.pointSize
	}

	func setupLabels(_ n: Int) {
		if n == self.subviews.count { return }
		self.subviews.forEach { $0.removeFromSuperview() }

		// build out from center
		var prevLabel: UILabel? = nil
		for i in 0..<n {
			let label = UILabel()
			label.translatesAutoresizingMaskIntoConstraints = false
			label.adjustsFontSizeToFitWidth = true
			label.minimumScaleFactor = 0.5
			label.text = String(format: "%d", i + 1)
			label.textAlignment = .center
			label.textColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
			self.addSubview(label)

			label.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: labelHeight))
			self.addConstraint(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -bottomMargin + labelHeight))
			if i == 0 {
				self.addConstraint(NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: sideMargins))
			}
			else {
				self.addConstraints([NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: prevLabel, attribute: .right, multiplier: 1.0, constant: barSpacing),
											NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: prevLabel, attribute: .width, multiplier: 1.0, constant: 0.0)])
			}
			if i == n - 1 {
				self.addConstraint(NSLayoutConstraint(item: label, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -sideMargins))
			}

			prevLabel = label
		}

		// choose minimum constant font size
		DispatchQueue.main.async {
			var minFontSize = CGFloat(100)
			for v in self.subviews {
				if let label = v as? UILabel {
					let curFontSize = self.approximateAdjustedFontSizeWithLabel(label)
					if curFontSize < minFontSize {
						minFontSize = curFontSize
					}
				}
			}
			for v in self.subviews {
				if let label = v as? UILabel {
					label.font = label.font.withSize(minFontSize)
				}
			}
		}
	}

	override func draw(_ rect: CGRect) {
		let nBars = self.rollCounts.countsForNumbers.count
		if nBars == 0 { return }

		if nBars != self.subviews.count {
			DispatchQueue.main.async {
				self.setupLabels(nBars)
			}
		}

		var maxCount = 0
		for i in 1...nBars {
			if self.rollCounts.countsForNumbers[i]! > maxCount {
				maxCount = self.rollCounts.countsForNumbers[i]!
			}
		}

		let barWidth = (self.frame.size.width - 2.0*sideMargins - CGFloat(nBars - 1)*barSpacing)/CGFloat(nBars)
		let context = UIGraphicsGetCurrentContext()
		context?.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//		context?.setStrokeColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

		for i in 1...nBars {
			let x = sideMargins + CGFloat(i - 1)*(barWidth + barSpacing)
			let height = CGFloat(self.rollCounts.countsForNumbers[i]!)*(self.frame.size.height - topMargin - bottomMargin)/CGFloat(maxCount)
			let whitespace = self.frame.size.height - topMargin - bottomMargin - height
			UIRectFill(CGRect(x: x, y: topMargin + whitespace, width: barWidth, height: height))
		}
	}
}
