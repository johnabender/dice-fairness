//
//  LoadRollsTableViewController.swift
//  dice-fairness
//
//  Created by John Bender on 4/2/18.
//  Copyright © 2018 Bender Systems. All rights reserved.
//

import UIKit

class LoadRollsTableViewController: UITableViewController {

	var isLoadingSecond = false

	var savedRolls: [String] = []

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		self.savedRolls = RollCountsController.shared.listSavedCounts().sorted()
		return self.savedRolls.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "savedRollsCell", for: indexPath)

		if indexPath.row < self.savedRolls.count {
			let dateParser = ISO8601DateFormatter()
			dateParser.formatOptions = .withFullDate
			dateParser.timeZone = TimeZone.current
			let breakpoint2 = dateParser.string(from: Date.init()).count // counted from tail
			let breakpoint1 = breakpoint2 + "-000".count // counted from tail

			let nameAndDate = self.savedRolls[indexPath.row]
			let name = (nameAndDate as NSString).substring(to: nameAndDate.count - breakpoint1 - 1)
			cell.textLabel?.text = name

			let sidesString = (nameAndDate as NSString).substring(with: NSRange.init(location: nameAndDate.count - breakpoint1, length: breakpoint1 - breakpoint2 - 1))
			let sides = Int(sidesString)
			var sidesText = ""
			if sides != nil {
				sidesText = String(format: "d%d, ", sides!)
			}

			let dateString = (nameAndDate as NSString).substring(from: nameAndDate.count - breakpoint2)
			let date = dateParser.date(from: dateString)
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .short
			var dateText = ""
			if date == nil {
				dateText = String(format: "saved %@", dateString)
			}
			else {
				dateText = String(format: "saved %@", dateFormatter.string(from: date!))
			}

			cell.detailTextLabel?.text = sidesText + dateText
		}
		else {
			cell.textLabel?.text = "---"
		}

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if self.isLoadingSecond {
			DispatchQueue.main.async {
				let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
				let scrimVC = storyboard.instantiateViewController(withIdentifier: "ScrimViewController")
				self.present(scrimVC, animated: true, completion: nil)

				DispatchQueue.main.async {
					let secondCounts = RollCountsController()
					secondCounts.loadCountsWithTitle(self.savedRolls[indexPath.row])
					RollCountsController.shared.setSecondRollCounts(secondCounts.rollCounts)
					NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadedSecondDie"),
															  object: secondCounts.rollCounts)

					DispatchQueue.main.async {
						scrimVC.dismiss(animated: true, completion: nil)
					}
					DispatchQueue.main.async {
						tableView.deselectRow(at: indexPath, animated: true)
					}
					self.navigationController?.popToRootViewController(animated: true)
				}
			}
		}
		else {
			RollCountsController.shared.loadCountsWithTitle(self.savedRolls[indexPath.row])
			RollCountsController.shared.secondRollCounts = nil
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadedSecondDie"),
													  object: nil)

			DispatchQueue.main.async {
				tableView.deselectRow(at: indexPath, animated: true)
			}
			self.navigationController?.popToRootViewController(animated: true)
		}
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			RollCountsController.shared.deleteSavedCountsWithTitle(self.savedRolls[indexPath.row])
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}
}
