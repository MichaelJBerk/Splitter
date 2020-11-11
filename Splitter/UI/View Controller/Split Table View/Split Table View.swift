//
//  Split Table View.swift
//  Splitter
//
//  Created by Michael Berk on 2/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa


//MARK - Number of Rows
extension ViewController: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return currentSplits.count
	}
}

class myRowView: NSTableRowView {
	var selectedColor: NSColor = .splitterRowSelected
    var isCurrentSegment: Bool = false
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		

		if isSelected == true || isCurrentSegment {
			selectedColor.set()
			dirtyRect.fill()
		   }
	   }
}


extension ViewController: NSTableViewDelegate {
	
	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		
		let cRow = myRowView()
		cRow.selectedColor = self.selectedColor
        cRow.isCurrentSegment = (currentSplitNumber == row && timerState != .stopped)
		
		return cRow
	}
	
	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		if timerState == .running {
			return false
		} else {
			return true
		}
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		cellIdentifier = tableColumn?.identifier
		
		if let cell = tableView.makeView(withIdentifier: cellIdentifier!, owner: nil) as? NSTableCellView {
			cell.textField?.delegate = self
			
			
			//Highlight the current row if the user is in the middle of a run
			if timerState != .stopped && row == currentSplitNumber {
				tableView.selectRowIndexes(IndexSet(arrayLiteral: currentSplitNumber), byExtendingSelection: false)
			}
			
			currentSplits[row].roundTo = self.roundTo
			
			switch tableColumn?.identifier {
			case STVColumnID.imageColumn:
				let cell = cell as! ImageButtonCellView
				cell.cellNumber = row
				if let currentImage = currentSplits[row].splitIcon {
					cell.imageWell!.image = currentImage
				} else {
					cell.imageWell.image = nil
				}
			case STVColumnID.splitTitleColumn:
				let lastSplit = currentSplits[row]
				cell.textField?.stringValue = lastSplit.splitName
			case STVColumnID.currentSplitColumn:
				let lastSplit = currentSplits[row]
				cell.textField?.stringValue = lastSplit.currentSplit.timeString
			case STVColumnID.differenceColumn:
				let sDiff = currentSplits[row].splitDiff
				cell.textField?.stringValue = sDiff
				if sDiff.hasPrefix("+"){
					cell.textField?.textColor = diffsLongerColor
				} else if sDiff.hasPrefix("-"){
					cell.textField?.textColor = diffsShorterColor
				} else {
					cell.textField?.textColor = diffsNeutralColor
				}
			case STVColumnID.bestSplitColumn:
				let best = currentSplits[row].bestSplit
				if best.timeString == TimeSplit().timeString {
					cell.textField!.stringValue = "00:00:00.00"
				}
				cell.textField!.stringValue = best.timeString
			case STVColumnID.previousSplitColumn:
				let prev = currentSplits[row].previousSplit
				cell.textField!.stringValue = prev.timeString
			default:
					break
			}
			if let tf = cell.textField {
				if tableColumn!.identifier != STVColumnID.differenceColumn {
					cell.textField?.attributedStringValue = NSAttributedString(string: tf.stringValue, attributes: [.foregroundColor : textColor])
				}
			}
			return cell
		}
		return nil
	}

}

extension ViewController: NSTextFieldDelegate {
	func controlTextDidEndEditing(_ obj: Notification) {
		
		splitsTableView.reloadData()
	}
	
	///Function called after editing the text field in a row
	func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
		//Get the column, row, and cell from the control
		let colIndex = splitsTableView.column(for: control)
		let colID = splitsTableView.tableColumns[colIndex].identifier
		let r = splitsTableView.row(for: control)
		let cellrow = splitsTableView.rowView(atRow: r, makeIfNecessary: false)
		let cell = cellrow?.view(atColumn: colIndex) as! NSTableCellView
		
		
		var editedSplit = currentSplits[r]
		
		
		guard let cellText = cell.textField?.stringValue else {return false}
		if colID == STVColumnID.splitTitleColumn {
			editedSplit.splitName = cellText
		} else {
			if let newSplit = TimeSplit(timeString: cellText){
			
				
				switch colID {
				case STVColumnID.currentSplitColumn:
					editedSplit.currentSplit = newSplit
				case STVColumnID.bestSplitColumn:
					editedSplit.bestSplit = newSplit
					editedSplit.previousBest = newSplit
				case STVColumnID.previousSplitColumn:
					editedSplit.previousSplit = newSplit
				default:
					break
				}
			}
		}
		currentSplits[r] = editedSplit
		if colID != STVColumnID.bestSplitColumn {
			let lSplit = currentSplits[r].currentSplit.copy() as! TimeSplit
			let rSplit = currentSplits[r].bestSplit.copy() as! TimeSplit
			addBestSplit(lSplit: lSplit, rSplit: rSplit, splitRow: r)
			if lSplit < rSplit {
				currentSplits[r].previousBest = lSplit.tsCopy()
			}
		}
		
			return true
	}

	

}
