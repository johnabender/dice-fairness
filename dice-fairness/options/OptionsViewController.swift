//
//  OptionsViewController.swift
//  dice-fairness
//
//  Created by John Bender on 3/30/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {

	@IBOutlet weak var saveButton: UIButton? = nil
	@IBOutlet weak var loadSecondDieButton: UIButton? = nil
	@IBOutlet weak var sidesSelector: UISegmentedControl? = nil
	@IBOutlet weak var histogramTypeSelector: UISegmentedControl? = nil
	@IBOutlet weak var showFairnessLineSwitch: UISwitch? = nil
	@IBOutlet weak var showFairnessEnvelopeSwitch: UISwitch? = nil
	@IBOutlet weak var showBarWhiskersSwitch: UISwitch? = nil
	@IBOutlet weak var aboutStatsSpinner: UIActivityIndicatorView? = nil
	@IBOutlet weak var versionLabel: UILabel? = nil

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)

		self.saveButton?.isEnabled = RollCountsController.shared.canSaveCurrentRolls()
		self.loadSecondDieButton?.isEnabled = !RollCountsController.shared.hasChanged

		if RollCountsController.shared.secondRollCounts != nil {
			self.sidesSelector?.selectedSegmentIndex = -1
			self.sidesSelector?.isEnabled = false
		}
		else {
			switch RollCountsController.shared.currentNSides() {
			case 4:
				self.sidesSelector?.selectedSegmentIndex = 0
			case 6:
				self.sidesSelector?.selectedSegmentIndex = 1
			case 8:
				self.sidesSelector?.selectedSegmentIndex = 2
			case 10:
				self.sidesSelector?.selectedSegmentIndex = 3
			case 12:
				self.sidesSelector?.selectedSegmentIndex = 4
			case 20:
				self.sidesSelector?.selectedSegmentIndex = 5
			default:
				break
			}
		}

		switch Options.shared.drawCumulHist {
		case false:
			self.histogramTypeSelector?.selectedSegmentIndex = 0
		case true:
			self.histogramTypeSelector?.selectedSegmentIndex = 1
		}

		self.showFairnessLineSwitch?.isOn = Options.shared.drawFairnessLine
		self.showFairnessEnvelopeSwitch?.isOn = Options.shared.drawFairnessEnvelope
		self.showBarWhiskersSwitch?.isOn = Options.shared.drawWhiskers

		self.versionLabel?.text = String(format: "v%@ (%@)", Bundle.main.releaseVersionNumber!, Bundle.main.buildVersionNumber!)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		self.aboutStatsSpinner?.stopAnimating()
	}

	@IBAction func pressedAboutStats() {
		DispatchQueue.main.async {
			self.aboutStatsSpinner?.startAnimating()

			DispatchQueue.main.async {
				let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
				let statsVC = storyboard.instantiateViewController(withIdentifier: "statsTutorialViewController")
				self.navigationController?.pushViewController(statsVC, animated: true)
			}
		}
	}

	@IBAction func chooseDice(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			RollCountsController.shared.resetCountsWithNSides(4)
		case 1:
			RollCountsController.shared.resetCountsWithNSides(6)
		case 2:
			RollCountsController.shared.resetCountsWithNSides(8)
		case 3:
			RollCountsController.shared.resetCountsWithNSides(10)
		case 4:
			RollCountsController.shared.resetCountsWithNSides(12)
		case 5:
			RollCountsController.shared.resetCountsWithNSides(20)
		default:
			break
		}

		self.navigationController?.popViewController(animated: true)
	}

	@IBAction func chooseHistogramType(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			Options.shared.drawCumulHist = false
		case 1:
			Options.shared.drawCumulHist = true
		default:
			break
		}

		Options.shared.save()
		self.navigationController?.popViewController(animated: true)
	}

	@IBAction func switchedGraphOption() {
		if self.showFairnessLineSwitch != nil {
			Options.shared.drawFairnessLine = self.showFairnessLineSwitch!.isOn
		}
		if self.showFairnessEnvelopeSwitch != nil {
			Options.shared.drawFairnessEnvelope = self.showFairnessEnvelopeSwitch!.isOn
		}
		if self.showBarWhiskersSwitch != nil {
			Options.shared.drawWhiskers = self.showBarWhiskersSwitch!.isOn
		}

		Options.shared.save()
	}

	@IBAction func pressedSave() {
		if !RollCountsController.shared.canSaveCurrentRolls() { return }

		let saveAlert = UIAlertController.init(title: "Save Rolls",
															message: String(format: "Enter a name for this d%d.", RollCountsController.shared.currentNSides()),
															preferredStyle: .alert)
		saveAlert.addTextField(configurationHandler: { (textField: UITextField) in
			let curName = RollCountsController.shared.rollCounts.name
			if curName != nil {
				let suffixLength = RollCountsController.shared.getCurrentDateStamp().count + "-000-".count
				let nameOnly = (curName! as NSString).substring(to: curName!.count - suffixLength)
				textField.text = nameOnly
			}
		})
		saveAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		saveAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction) in
			if saveAlert.textFields != nil,
				saveAlert.textFields!.count > 0,
				let text = saveAlert.textFields![0].text,
				text != "" {
				RollCountsController.shared.saveCountsWithTitle(text)
			}
		}))
		self.present(saveAlert, animated: true, completion: nil)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)

		if let s = sender as? UIButton,
			s == self.loadSecondDieButton,
			let loadVC = segue.destination as? LoadRollsTableViewController {
			loadVC.isLoadingSecond = true
		}
	}
}
