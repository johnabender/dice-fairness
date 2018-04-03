//
//  LoadRollsTableViewController.swift
//  dice-fairness
//
//  Created by John Bender on 4/2/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

class LoadRollsTableViewController: UITableViewController {

	var savedRolls: [String] = []

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		self.savedRolls = RollCountsController.shared.listSavedCounts()
		return self.savedRolls.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "savedRollsCell", for: indexPath)

		if indexPath.row < self.savedRolls.count {
			cell.textLabel?.text = self.savedRolls[indexPath.row]
		}
		else {
			cell.textLabel?.text = "---"
		}

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		RollCountsController.shared.loadCountsWithTitle(self.savedRolls[indexPath.row])
		tableView.deselectRow(at: indexPath, animated: true)
		self.navigationController?.popToRootViewController(animated: true)
	}

	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
	// Return false if you do not want the specified item to be editable.
		return true
	}

	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			RollCountsController.shared.deleteSavedCountsWithTitle(self.savedRolls[indexPath.row])
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}
}
