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

	var selectedColor: NSColor {
		run.selectedColor
	}
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
		guard let id = tableColumn?.identifier else {return nil}
		let colIdx = tableView.column(withIdentifier: id)
		let layoutState = run.layout.state(run.timer.lsTimer)
		let splitsState = layoutState.componentAsSplits(1)
		let lsColName = splitsState.columnName(colIdx)
		
		var colID: NSUserInterfaceItemIdentifier = id
		tableView.tableColumns[colIdx].title = lsColName
		
		if lsColName == STVColumnID.iconColumnTitle {
			colID = STVColumnID.imageColumn
			tableView.tableColumns[colIdx].title = ""
		}
		if lsColName == STVColumnID.titleColumnTitle {
			colID = STVColumnID.splitTitleColumn
			tableView.tableColumns[colIdx].title = "Title"
		}
		
		if let cell = tableView.makeView(withIdentifier: colID, owner: nil) as? NSTableCellView {
			
			//Highlight the current row if the user is in the middle of a run
			let isCurrentSplit = run.layoutSplits.splits[row].isCurrentSplit
			if timerState != .stopped && isCurrentSplit {
				tableView.selectRowIndexes(IndexSet(arrayLiteral: row), byExtendingSelection: false)
			}
			
			let setThemeColor = { (textField: NSTextField) in
				textField.textColor = self.run.textColor
			}
			
			if colID == STVColumnID.imageColumn {
				let imageView = cell.imageView as! ThemedImage
				imageView.run = self.run
				if let image = run.icon(for: row) {
					imageView.image = image
				} else {
					imageView.image = .gameControllerIcon
					imageView.image?.isTemplate = true
				}
				imageView.setColor()
				return cell
			}
			
			let ct = splitsState.columnValue(row, colIdx)
			cell.textField?.stringValue = ct
			setThemeColor(cell.textField!)
			
			return cell
		}
		return nil
	}
}
