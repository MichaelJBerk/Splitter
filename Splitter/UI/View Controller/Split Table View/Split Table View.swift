//
//  Split Table View.swift
//  Splitter
//
//  Created by Michael Berk on 2/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return currentSplits.count
	}
}

extension ViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		if tableColumn == tableView.tableColumns[0] {
//			cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ImageColumn")
			cellIdentifier = STVColumnID.imageColumn
		}
		if tableColumn == tableView.tableColumns[1] {
			cellIdentifier = STVColumnID.splitTitleColumn
		}
//		if tableColumn == tableView.tableColumns[1] {
//			cellIdentifier = "BestSplit"
//		}
		if tableColumn == tableView.tableColumns[2] {
			cellIdentifier = STVColumnID.differenceColumn
		}
		if tableColumn == tableView.tableColumns[3] {
			cellIdentifier = STVColumnID.currentSplitColumn
		}
		if tableColumn == tableView.tableColumns[4] {
			cellIdentifier = STVColumnID.bestSplitColumn
		}
		
		
		if let cell = tableView.makeView(withIdentifier: cellIdentifier!, owner: nil) as? NSTableCellView {
			cell.textField?.delegate = self
			
			if let imageCell = cell as? ImageButtonCellView {
				imageCell.cellNumber = row
				if let currentImage = currentSplits[row].splitIcon {
					imageCell.imageButton.image = currentImage
				} else {
					imageCell.imageButton.image = #imageLiteral(resourceName: "Game Controller")
				}
				return imageCell
			}
			
			if self.cellIdentifier!.rawValue == "SplitTitle" {
				var lastSplit = currentSplits[row]
				cell.textField?.stringValue = lastSplit.splitName
			}
//			if cellIdentifier == "BestSplit" {

//				var lastSplit = allSplits[row]
//				var best: TimeSplit
//
//
//				cell.textField?.stringValue = getBestSplit(splitNumber: row).timeString
//			}
			if self.cellIdentifier!.rawValue == "CurrentSplit" {
				var lastSplit = currentSplits[row]
				cell.textField?.stringValue = lastSplit.currentSplit.timeString
			}
//			if self.cellIdentifier == "Difference" {
//				var nilSplit = "+-00:00:00.00"
//				cell.textField?.stringValue = nilSplit
//			}
			if cell.identifier?.rawValue == "Difference" {
				let sDiff = currentSplits[row].splitDiff
				
				cell.textField?.stringValue = sDiff
				if sDiff.hasPrefix("+"){
					cell.textField?.textColor = .systemRed
				} else if sDiff.hasPrefix("-"){
					cell.textField?.textColor = .systemGreen
				} else {
					cell.textField?.textColor = .systemBlue
				}
			}
			
			if cell.identifier!.rawValue == "B" || self.cellIdentifier!.rawValue == "B"{
				let best = currentSplits[row].bestSplit
				cell.textField!.stringValue = best.timeString
			}
			
			
			
			return cell
		}
		return nil
	}

}

extension ViewController: NSTextFieldDelegate {
	func controlTextDidEndEditing(_ obj: Notification) {
//		let view = obj.object as! NSTextField
//		let c = view.superview as? NSTableCellView
//		let c2 = splitsTableView.editedColumn
//		let currentColumn = column(for: view)
//		let view = obj.object as! NSTextField
		
		splitsTableView.reloadData()
	}
	
	func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
		//TODO: Uncomment this and fix it to work with the current column layout
		
		let c = control as NSView
//
		let c2 = splitsTableView.column(for: control)
		let r = splitsTableView.row(for: control)
//
		let cellrow = splitsTableView.rowView(atRow: r, makeIfNecessary: false)
		let cell = cellrow?.view(atColumn: c2) as! NSTableCellView
		var editedSplit = currentSplits[r]
//		if c2 > 0 {
//				let newSplit = TimeSplit(timeString: cell.textField?.stringValue ?? "00:00:00.00")
//				cell.textField?.stringValue = newSplit.timeString
//			}
		if c2 == 1 {
			print(cell.textField!.stringValue)
			editedSplit.splitName = cell.textField!.stringValue
		}
//		if c2 == 1 {
//			editedSplit.bestSplit = TimeSplit(timeString: cell.textField!.stringValue)
//		}
		if c2 == 3 {
			//if r != currentSplits.count - 1 {
				editedSplit.currentSplit = TimeSplit(timeString: cell.textField!.stringValue)
			//}
		}
		if c2 == 4 {
			editedSplit.bestSplit = TimeSplit(timeString: cell.textField!.stringValue)
		}
//
//
//
//
		
		let oldSplit = currentSplits[r]
		currentSplits[r] = editedSplit
//		currentSplits.remove(at: r)
//		currentSplits.insert(editedSplit, at: r)
		
//		splitsTableView.reloadData()
		if c2 != 4 {
			let lSplit = currentSplits[r].currentSplit.copy() as! TimeSplit
			let rSplit = currentSplits[r].bestSplit.copy() as! TimeSplit
			addBestSplit(lSplit: lSplit, rSplit: rSplit, splitRow: r)
			if lSplit < rSplit {
				currentSplits[r].originalBest = lSplit.tsCopy()
			}
		}
		originalSplits = currentSplits
		print(currentSplits[r].bestSplit.veryShortTimeString)
		print(currentSplits[r].originalBest?.veryShortTimeString)
		
		
			return true
	}

	

}
