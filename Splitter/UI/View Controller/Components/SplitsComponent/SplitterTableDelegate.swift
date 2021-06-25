//
//  SplitterTableDelegate.swift
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
		return run.layoutSplits.splits.count
	}
}

class SplitterRowView: NSTableRowView {
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
		
		let cRow = SplitterRowView()
		cRow.selectedColor = self.selectedColor
		let l = run.layoutSplits
		cRow.isCurrentSegment = (run.layoutSplits.splits[row].isCurrentSplit && timerState != .stopped)
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
			let isCurrentSplit = run.layoutSplits.splits[row].isCurrentSplit
			if timerState != .stopped && isCurrentSplit {
				tableView.selectRowIndexes(IndexSet(arrayLiteral: row), byExtendingSelection: false)
			}
			
			let currentLayoutSegment = run.layoutSplits.splits[row]
			switch tableColumn?.identifier {
			case STVColumnID.imageColumn:
				let cell = cell as! ImageButtonCellView
				cell.cellNumber = row
				cell.imageWell.run = self.run
				cell.imageWell.splitController = self
				if let image = run.icon(for: row) {
					cell.imageWell!.image = image
				} else {
					cell.imageWell.image = .gameControllerIcon
					cell.imageWell.image?.isTemplate = true
				}
				cell.imageWell.setColor(run: run)
			case STVColumnID.splitTitleColumn:
				cell.textField?.stringValue = currentLayoutSegment.name
			case STVColumnID.currentSplitColumn:
				cell.textField?.stringValue = currentLayoutSegment.columns[0].value
			case STVColumnID.differenceColumn:
				let color = NSColor(currentLayoutSegment.columns[1].visualColor)
				cell.textField?.textColor = color
				cell.textField?.stringValue = currentLayoutSegment.columns[1].value
			case STVColumnID.bestSplitColumn:
				cell.textField?.stringValue = currentLayoutSegment.columns[2].value
			case STVColumnID.previousSplitColumn:
				let v = currentLayoutSegment.columns[3].value
				cell.textField?.stringValue = v
			default:
					break
			}
			if let tf = cell.textField as? ThemedTextField {
				if tf.themeable {
					tf.setColor(run: run)
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
		
		
		guard let cellText = cell.textField?.stringValue else {return false}
		switch colID {
		case STVColumnID.splitTitleColumn:
			run.setSegTitle(index: r, title: cellText)
		case STVColumnID.currentSplitColumn:
			run.setSplitTime(index: r, time: cellText)
			run.updateLayoutState()
		case STVColumnID.bestSplitColumn:
			run.setBestTime(index: r, time: cellText)
			break
		case STVColumnID.previousSplitColumn:
			break
		default:
			break
		}
		return true
	}

	

}
