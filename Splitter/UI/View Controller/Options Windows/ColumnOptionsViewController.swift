//
//  ColumnOptionsViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/3/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa



class ColumnOptionsViewController: NSViewController, NSPopoverDelegate {
	var delegate: ViewController?
	
	
	@IBOutlet weak var CheckboxGridView: NSGridView!
	
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		return true
	}
	
	///Loads the view with checkboxes for each column, in the order the user has left them
	func loadCheckBoxes() {
		if delegate != nil {
			CheckboxGridView.removeRow(at: 0)
			for c in delegate!.splitsTableView.tableColumns {
				let cName: String = colIds.first(where: {$1 == c.identifier})?.key ?? "nil"
				let checkButton = SplitterCheckbox(checkboxWithTitle: cName, target: self, action: #selector(checkboxAction(sender:)))
				if c.isHidden {
					checkButton.state = .off
				} else {
					checkButton.state = .on
				}
				CheckboxGridView.addRow(with: [checkButton])
			}
		}
	}
	
	///Called when a user clicks on the checkbox to show/hide a row
	@objc func checkboxAction(sender: NSButton) {
		let checkID = colIds[sender.title]!
		if delegate != nil {
			let colID = delegate!.splitsTableView.column(withIdentifier: checkID)
		
			if sender.state == .on {
				delegate?.splitsTableView.tableColumns[colID].isHidden = false
			} else {
				delegate?.splitsTableView.tableColumns[colID].isHidden = true
			}
		}
	}
}

class SplitterCheckbox: NSButton {
	
	
}
