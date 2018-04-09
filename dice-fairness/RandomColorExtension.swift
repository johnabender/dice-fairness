//
//  RandomColorExtension.swift
//  RandomColor
//
//  Created by Claudio Carnino on 22/10/2014.
//  Copyright (c) 2014 Tugulab. All rights reserved.
//

import Foundation
import UIKit



public extension UIColor {

	private class func RC_randomValueForColor() -> CGFloat {
		return CGFloat(CGFloat(arc4random()).truncatingRemainder(dividingBy: 256.0) / 255.0)
	}

	public class func random() -> UIColor {
		return UIColor(red: RC_randomValueForColor(), green: RC_randomValueForColor(), blue: RC_randomValueForColor(), alpha: 1.0)
	}

	public class func randomToneForColor(color: UIColor) -> UIColor {
		var hue: CGFloat = 0
		var saturation: CGFloat = 0
		var brightness: CGFloat = 0
		var alpha: CGFloat = 0

		color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

		return UIColor(hue: hue, saturation: RC_randomValueForColor(), brightness: RC_randomValueForColor(), alpha: alpha)
	}

	/**
	Random color using the golden ratio, so proper random colors
	Inspired by http://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
	*/
	public class func randomGoldenRatioColor(saturation: CGFloat = 0.5, brightness: CGFloat = 0.95) -> UIColor {
		let goldenRatioConjugate: CGFloat = 0.618033988749895
		var hue = RC_randomValueForColor()

		hue += goldenRatioConjugate
		hue = hue.truncatingRemainder(dividingBy: 1.0)

		return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
	}
}


public extension Bundle {
	var releaseVersionNumber: String? {
		return infoDictionary?["CFBundleShortVersionString"] as? String
	}
	var buildVersionNumber: String? {
		return infoDictionary?["CFBundleVersion"] as? String
	}
}
