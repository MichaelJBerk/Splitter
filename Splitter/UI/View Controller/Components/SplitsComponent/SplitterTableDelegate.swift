//
//  SplitterTableDelegate.swift
//  Splitter
//
//  Created by Michael Berk on 2/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

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


class SplitsComponentDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
	var run: SplitterRun
	var selectedColor = NSColor.splitterRowSelected
	var splitsComponent: SplitsComponent
	var timerState: TimerState {
		get {
			run.timer.timerState
		}
		set {
			run.timer.timerState = newValue
		}
	}
	
	init(run: SplitterRun, component: SplitsComponent) {
		self.run = run
		self.splitsComponent = component
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return run.layoutSplits.splits.count
	}
	
	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		
		let cRow = SplitterRowView()
		cRow.selectedColor = self.selectedColor
		cRow.isCurrentSegment = (run.layoutSplits.splits[row].isCurrentSplit && timerState != .stopped)
		return cRow
	}
	
	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		return false
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

		if let id = tableColumn?.identifier, let cell = tableView.makeView(withIdentifier: id, owner: nil) as? NSTableCellView {
			
			//Highlight the current row if the user is in the middle of a run
			let isCurrentSplit = run.layoutSplits.splits[row].isCurrentSplit
			if timerState != .stopped && isCurrentSplit {
				tableView.selectRowIndexes(IndexSet(arrayLiteral: row), byExtendingSelection: false)
			}
			
			let currentLayoutSegment = run.layoutSplits.splits[row]
			let setThemeColor = { (textField: NSTextField) in
				textField.textColor = self.run.textColor
			}
			switch tableColumn?.identifier {
			case STVColumnID.imageColumn:
				let imageView = cell.imageView as! ThemedImage
				imageView.run = self.run
				if let image = run.icon(for: row) {
					imageView.image = image
				} else {
					imageView.image = .gameControllerIcon
					imageView.image?.isTemplate = true
				}
				imageView.setColor()
			case STVColumnID.splitTitleColumn:
				cell.textField?.stringValue = currentLayoutSegment.name
				setThemeColor(cell.textField!)
			case STVColumnID.currentSplitColumn:
				cell.textField?.stringValue = currentLayoutSegment.columns[0].value
				setThemeColor(cell.textField!)
			case STVColumnID.differenceColumn:
				let color = NSColor(currentLayoutSegment.columns[1].visualColor)
				cell.textField?.textColor = color
				cell.textField?.stringValue = currentLayoutSegment.columns[1].value
			case STVColumnID.bestSplitColumn:
				cell.textField?.stringValue = currentLayoutSegment.columns[2].value
				setThemeColor(cell.textField!)
			case STVColumnID.previousSplitColumn:
				let v = currentLayoutSegment.columns[3].value
				cell.textField?.stringValue = v
				setThemeColor(cell.textField!)
			default:
				break
			}
			if let tf = cell.textField as? ThemedTextField {
				tf.run = run
				if tf.themeable {
					tf.setColor()
				}
			}
			return cell
		}
		return nil
	}
}
