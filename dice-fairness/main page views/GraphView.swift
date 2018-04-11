//
//  GraphView.swift
//  dice-fairness
//
//  Created by John Bender on 3/30/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

let barSpacing = CGFloat(3)
let sideMargins = CGFloat(20)
let topMargin = CGFloat(60)
let bottomMargin = CGFloat(30)
let labelHeight = CGFloat(20)
let whiskerDashLength = CGFloat(10)

class GraphView: UIView {

	var rollCounts: RollCounts = RollCounts()
	let totalLabel: UILabel = UILabel()
	let statsLabel: UILabel = UILabel()
	let chiLabel: UILabel = UILabel()
	var labelsToKeep: [UILabel] = []

	// https://stackoverflow.com/questions/28284063/28285447#28285447
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

		self.labelsToKeep = [self.totalLabel, self.statsLabel, self.chiLabel]

		// build out from center
		var prevLabel: UILabel? = nil
		for i in 0..<n {
			let label = UILabel()
			label.translatesAutoresizingMaskIntoConstraints = false
			label.adjustsFontSizeToFitWidth = true
			label.minimumScaleFactor = 0.5
			label.text = String(format: "%d", i + 1)
			label.textAlignment = .center
			label.textColor = .white
			self.addSubview(label)

			label.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: labelHeight))
			self.addConstraint(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
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

		self.totalLabel.translatesAutoresizingMaskIntoConstraints = false
		self.totalLabel.textAlignment = .left
		self.totalLabel.textColor = .white
		self.addSubview(self.totalLabel)
		self.totalLabel.addConstraint(NSLayoutConstraint(item: self.totalLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: labelHeight))
		self.addConstraints([NSLayoutConstraint(item: self.totalLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: sideMargins),
									NSLayoutConstraint(item: self.totalLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)])

		self.statsLabel.translatesAutoresizingMaskIntoConstraints = false
		self.statsLabel.textAlignment = .right
		self.addSubview(self.statsLabel)
		self.statsLabel.addConstraint(NSLayoutConstraint(item: self.statsLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: labelHeight))
		self.addConstraints([NSLayoutConstraint(item: self.statsLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -sideMargins),
									NSLayoutConstraint(item: self.statsLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
									NSLayoutConstraint(item: self.statsLabel, attribute: .left, relatedBy: .equal, toItem: self.totalLabel, attribute: .right, multiplier: 1.0, constant: 0.0)])

		self.chiLabel.translatesAutoresizingMaskIntoConstraints = false
		self.chiLabel.textAlignment = .right
		self.addSubview(self.chiLabel)
		self.chiLabel.addConstraint(NSLayoutConstraint(item: self.chiLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: labelHeight))
		self.addConstraints([NSLayoutConstraint(item: self.chiLabel, attribute: .right, relatedBy: .equal, toItem: self.statsLabel, attribute: .right, multiplier: 1.0, constant: 0.0),
									NSLayoutConstraint(item: self.chiLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
									NSLayoutConstraint(item: self.chiLabel, attribute: .top, relatedBy: .equal, toItem: self.statsLabel, attribute: .bottom, multiplier: 1.0, constant: 0.0)])

		DispatchQueue.main.async {
			self.fixBarLabelFontSize()
		}
	}

	func fixBarLabelFontSize() {
		// not sure if this is needed anymore, but it seems prudent
		if self.frame.size.width == 0.0 {
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
				self.fixBarLabelFontSize()
			})
			return
		}

		var minFontSize = CGFloat(100)
		for v in self.subviews {
			if let label = v as? UILabel, !self.labelsToKeep.contains(label) {
				let curFontSize = self.approximateAdjustedFontSizeWithLabel(label)
				if curFontSize < minFontSize {
					minFontSize = curFontSize
				}
			}
		}
		for v in self.subviews {
			if let label = v as? UILabel, !self.labelsToKeep.contains(label) {
				label.font = label.font.withSize(minFontSize)
			}
		}
	}

	func leftEdgeForBar(index: Int, barWidth: CGFloat) -> CGFloat {
		return sideMargins + CGFloat(index)*(barWidth + barSpacing)
	}

	func heightForBar(number: Int, usableHeight: CGFloat) -> CGFloat {
		if Options.shared.drawCumulHist && self.rollCounts.cumulHist[1]! > 0 {
			return CGFloat(self.rollCounts.cumulHist[number]!)*usableHeight/CGFloat(self.rollCounts.cumulHist[1]!)
		}
		else if !Options.shared.drawCumulHist && RollCountsController.shared.rollCounts.maxCount > 0 {
			return CGFloat(self.rollCounts.countsForNumbers[number]!)*usableHeight/CGFloat(RollCountsController.shared.rollCounts.maxCount)
		}
		return CGFloat(0)
	}

	override func draw(_ rect: CGRect) {
		let nBars = self.rollCounts.countsForNumbers.count
		if nBars == 0 { return }

		if self.subviews.count - self.labelsToKeep.count != nBars {
			DispatchQueue.main.async {
				self.setupLabels(nBars)
			}
		}

		let totalCount = RollCountsController.shared.rollCounts.totalCount
		var maxCount = RollCountsController.shared.rollCounts.maxCount
		if Options.shared.drawCumulHist {
			maxCount = self.rollCounts.cumulHist[1]!
		}

		// total count in label
		var s = "s"
		if totalCount == 1 { s = "" }
		self.totalLabel.text = String(format: "%d roll%@", totalCount, s)

		// stats in label
		var conf = "low"
		var confColor = UIColor.red
		if totalCount >= 5*nBars {
			conf = "moderate"
			confColor = .yellow
		}
		if totalCount >= 20*nBars {
			conf = "high"
			confColor = .green
		}
		self.statsLabel.text = String(format: "statistical power: %@", conf)
		self.statsLabel.textColor = confColor

		// chi-squared or K-S value in label
		if Options.shared.drawCumulHist {
			var sig = "not significantly biased"
			if RollCountsController.shared.rollCounts.isKSSignificant99() {
				self.chiLabel.textColor = .red
				sig = "significantly biased"
			}
			else if RollCountsController.shared.rollCounts.isKSSignificant95() {
				self.chiLabel.textColor = .yellow
				sig = "marginally significant bias"
			}
			else {
				self.chiLabel.textColor = .green
			}
			if totalCount >= 35 {
				self.chiLabel.text = String(format: "D: %.3f (%@)", RollCountsController.shared.rollCounts.ks, sig)
			}
			else {
				self.chiLabel.text = ""
			}
		}
		else {
			var sig = "not significantly biased"
			if RollCountsController.shared.rollCounts.isChiSqSignificant99() {
				self.chiLabel.textColor = .red
				sig = "significantly biased"
			}
			else if RollCountsController.shared.rollCounts.isChiSqSignificant95() {
				self.chiLabel.textColor = .yellow
				sig = "marginally significant bias"
			}
			else {
				self.chiLabel.textColor = .green
			}
			if totalCount >= nBars {
				self.chiLabel.text = String(format: "𝜒²: %.2f (%@)", RollCountsController.shared.rollCounts.chisq, sig)
			}
			else {
				self.chiLabel.text = ""
			}
		}

		let barWidth = (self.frame.size.width - 2.0*sideMargins - CGFloat(nBars - 1)*barSpacing)/CGFloat(nBars)
		let usableHeight = self.frame.size.height - topMargin - bottomMargin

		let context = UIGraphicsGetCurrentContext()

		if Options.shared.drawFairnessEnvelope && totalCount >= nBars {
			// draw "fairness envelope"
			context?.setFillColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
			if Options.shared.drawCumulHist {
				for i in 2...nBars {
					let fairHeight = usableHeight*CGFloat(self.rollCounts.cumulExpectedValue[i]!)/CGFloat(maxCount)
					let envelopeHeight = usableHeight*CGFloat(2.0*self.rollCounts.cumulExpectedStdev[i]!)/CGFloat(maxCount)
					let bottomY = max(fairHeight - envelopeHeight, 0.0)
					let topY = min(fairHeight + envelopeHeight, usableHeight + whiskerDashLength)
					let leftX = self.leftEdgeForBar(index: i - 1, barWidth: barWidth) - barSpacing/2.0
					UIRectFillUsingBlendMode(CGRect(x: leftX, y: topMargin + usableHeight - topY, width: barWidth + barSpacing, height: topY - bottomY), .normal)
				}
			}
			else {
				let bottomY = max(usableHeight*(CGFloat(RollCountsController.shared.rollCounts.expectedValue) - CGFloat(2.0*RollCountsController.shared.rollCounts.expectedStdev))/CGFloat(maxCount),
										0.0)
				let topY = min(usableHeight*(CGFloat(RollCountsController.shared.rollCounts.expectedValue) + CGFloat(2.0*RollCountsController.shared.rollCounts.expectedStdev))/CGFloat(maxCount),
									usableHeight + whiskerDashLength)
				let leftX = sideMargins/2.0
				let rightX = self.frame.size.width - sideMargins/2.0
				UIRectFillUsingBlendMode(CGRect(x: leftX, y: topMargin + usableHeight - topY, width: rightX - leftX, height: topY - bottomY), .normal)
			}
		}

		// draw each bar
		context?.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		for i in 1...nBars {
			let x = self.leftEdgeForBar(index: i - 1, barWidth: barWidth)
			let height = self.heightForBar(number: i, usableHeight: usableHeight)
			let whitespace = usableHeight - height
			UIRectFillUsingBlendMode(CGRect(x: x, y: topMargin + whitespace, width: barWidth, height: height), .normal)
		}

		if Options.shared.drawFairnessLine && totalCount > 0 {
			// draw dashed "fairness line"
			let fairPath = UIBezierPath()
			if Options.shared.drawCumulHist {
				fairPath.move(to: CGPoint(x: self.leftEdgeForBar(index: 0, barWidth: barWidth), y: topMargin))
				for i in 1...nBars {
					let fairHeight = usableHeight*CGFloat(self.rollCounts.cumulExpectedValue[i]!)/CGFloat(maxCount)
					if i > 1 {
						fairPath.addLine(to: CGPoint(x: self.leftEdgeForBar(index: i - 1, barWidth: barWidth) - barSpacing/2.0,
															  y: topMargin + usableHeight - fairHeight))
					}
					fairPath.addLine(to: CGPoint(x: self.leftEdgeForBar(index: i - 1, barWidth: barWidth) + barWidth + barSpacing/2.0,
														  y: topMargin + usableHeight - fairHeight))

					fairPath.setLineDash([2.0, 2.0], count: 2, phase: 0.0)
					fairPath.lineWidth = 2.0
					context?.setStrokeColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
				}
			}
			else {
				let fairHeight = usableHeight*CGFloat(totalCount)/CGFloat(nBars)/CGFloat(maxCount)
				fairPath.move(to: CGPoint(x: sideMargins/2.0, y: topMargin + usableHeight - fairHeight))
				fairPath.addLine(to: CGPoint(x: self.frame.size.width - sideMargins/2.0,
													  y: topMargin + usableHeight - fairHeight))

				fairPath.setLineDash([5.0, 3.0], count: 2, phase: 0.0)
				context?.setStrokeColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
			}
			fairPath.stroke()
		}

		if Options.shared.drawWhiskers && totalCount >= nBars {
			// draw whiskers at 2 sigma
			let whiskerPath = UIBezierPath()
			let whiskerDashPath = UIBezierPath()
			let whiskerWidth = barWidth/4.0
			for i in 1...nBars {
				let x = self.leftEdgeForBar(index: i - 1, barWidth: barWidth) + barWidth/2.0
				let height = self.heightForBar(number: i, usableHeight: usableHeight)
				let whitespace = usableHeight - height
				let whiskerHeight = usableHeight*CGFloat(2.0*RollCountsController.shared.rollCounts.stdev)/CGFloat(maxCount)

				var topY = topMargin + whitespace - whiskerHeight
				if topY < topMargin {
					topY = topMargin
					whiskerDashPath.move(to: CGPoint(x: x, y: topY))
					whiskerDashPath.addLine(to: CGPoint(x: x, y: topY - whiskerDashLength))
				}
				else {
					whiskerPath.move(to: CGPoint(x: x - whiskerWidth/2.0, y: topY))
					whiskerPath.addLine(to: CGPoint(x: x + whiskerWidth/2.0, y: topY))
				}
				whiskerPath.move(to: CGPoint(x: x, y: topY))

				var addBottomCross = true
				var bottomY = topMargin + whitespace + whiskerHeight
				if bottomY > topMargin + usableHeight {
					bottomY = topMargin + usableHeight
					whiskerDashPath.move(to: CGPoint(x: x, y: bottomY))
					whiskerDashPath.addLine(to: CGPoint(x: x, y: bottomY + whiskerDashLength))
					addBottomCross = false
				}
				whiskerPath.addLine(to: CGPoint(x: x, y: bottomY))
				if addBottomCross {
					whiskerPath.move(to: CGPoint(x: x - whiskerWidth/2.0, y: bottomY))
					whiskerPath.addLine(to: CGPoint(x: x + whiskerWidth/2.0, y: bottomY))
				}
			}
			context?.setStrokeColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
			whiskerPath.stroke()
			whiskerDashPath.setLineDash([2.0, 2.0], count: 2, phase: 0.0)
			whiskerDashPath.stroke()
		}
	}
}
