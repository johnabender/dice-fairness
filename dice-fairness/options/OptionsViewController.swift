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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)

		if !RollCountsController.shared.canSaveCurrentRolls() {
			self.saveButton?.isEnabled = false
		}
	}

	@IBAction func chooseDice(sender: UIButton) {
		if let newSides = Int((sender.accessibilityIdentifier)!) {
			RollCountsController.shared.resetCountsWithNSides(newSides)
			self.navigationController?.popViewController(animated: true)
		}
	}

	@IBAction func pressedSave() {
		if !RollCountsController.shared.canSaveCurrentRolls() { return }

		let saveAlert = UIAlertController.init(title: "Save Rolls",
													  message: "Enter a name for this die.",
													  preferredStyle: .alert)
		saveAlert.addTextField(configurationHandler: { (textField: UITextField) in
			textField.text = RollCountsController.shared.rollCounts.name
		})
		saveAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		saveAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction) in
			if saveAlert.textFields != nil,
				saveAlert.textFields!.count > 0,
				let text = saveAlert.textFields![0].text,
				text != "" {

				if !RollCountsController.shared.saveCountsWithTitle(text) {
					let failAlert = UIAlertController(title: "Name Exists",
																 message: "The name you chose already exists. Delete the existing die or choose a new name.",
																 preferredStyle: .alert)
					failAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
					self.present(failAlert, animated: true, completion: nil)
				}
			}
		}))
		self.present(saveAlert, animated: true, completion: nil)
	}
}
