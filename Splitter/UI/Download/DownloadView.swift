//
//  DownloadView.swift
//  Splitter
//
//  Created by Michael Berk on 8/2/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class DownloadViewController: NSViewController {

 
	@IBOutlet weak var tableView: NSTableView!
	
	@IBOutlet weak var nextButton: NSButton!
	//	@IBAction func nextButtonClick(_ sender: NSButton) {
	@IBAction func nbcThing(_ sender: Any) {
		print(tableView.selectedRow)
		
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView?.delegate = self
		tableView?.dataSource = self
	}
	
	
}

extension DownloadViewController: NSTableViewDelegate, NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return 10
	}
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "GameSearchCell"), owner: self) as! NSTableCellView
		cell.textField?.stringValue = "Hey"
		
		return cell
	}
	func tableViewSelectionDidChange(_ notification: Notification) {
		if tableView.numberOfSelectedRows > 0 {
			nextButton.isEnabled = true
		}
		else {
			nextButton.isEnabled = false
		}
	}
}
