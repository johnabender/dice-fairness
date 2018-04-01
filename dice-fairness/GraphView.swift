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

	func setupLabels(_ n: Int) {
		if n == self.subviews.count { return }
		self.subviews.forEach { $0.removeFromSuperview() }

		let barWidth = (self.frame.size.width - 2.0*sideMargins - CGFloat(n - 1)*barSpacing)/CGFloat(n)

		for i in 0..<n {
			let label = UILabel()
			label.translatesAutoresizingMaskIntoConstraints = false
			label.adjustsFontSizeToFitWidth = true
			label.minimumScaleFactor = 0.5
			label.text = String(format: "%d", i + 1)
			label.textAlignment = .center
			label.textColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
			self.addSubview(label)

			let x = sideMargins + CGFloat(i)*(barWidth + barSpacing)
			let labelLeftConstraint = NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: x)
			let labelWidthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: barWidth)
			let labelBottomConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -bottomMargin + labelHeight)
			let labelHeightConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: labelHeight)

			self.addConstraints([labelBottomConstraint, labelLeftConstraint])
			label.addConstraints([labelHeightConstraint, labelWidthConstraint])
		}

		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
			var minFontSize = CGFloat(100)
			for v in self.subviews {
				if let label = v as? UILabel {
					if label.font.pointSize < minFontSize {
						minFontSize = label.font.pointSize
					}
				}
			}
			print("min font size is", minFontSize)
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
