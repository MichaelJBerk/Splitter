//
//  SplitterTableDelegate.swift
//  Splitter
//
//  Created by Michael Berk on 2/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa
import LiveSplitKit

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
		var lsColName: String
		///Column index for interfacing with LiveSplitCore
		let lsColIndex = colIdx - 2
		switch colIdx {
		case 0:
			//Icon Column
			lsColName = ""
		case 1:
			//Title Column
			lsColName = "Split"
		default:
			lsColName = splitsState.columnLabel(lsColIndex)
		}
		
		tableView.tableColumns[colIdx].title = lsColName
		var colID: NSUserInterfaceItemIdentifier = id
		if colID.rawValue.prefix(2) == "LS" {
			colID = STVColumnID.splitTitleColumn
		}
		
		guard let cell = tableView.makeView(withIdentifier: colID, owner: nil) as? NSTableCellView else {return nil}
		
		//Highlight the current row if the user is in the middle of a run
		let isCurrentSplit = run.layoutSplits.splits[row].isCurrentSplit
		if timerState != .stopped && isCurrentSplit {
			tableView.selectRowIndexes(IndexSet(arrayLiteral: row), byExtendingSelection: false)
		}
		
		let setThemeColor = { (textField: NSTextField) in
			let color = splitsState.textColor(for: row, column: lsColIndex)
			textField.textColor = color
		}
		let setFont = { (textField: NSTextField) in
			if let font = self.run.splitsFont {
				textField.font = font
			} else {
				let size = NSFont.systemFontSize + self.run.splitsFontSize
				textField.font = NSFont.systemFont(ofSize: size)
			}
		}
		
		if id == STVColumnID.imageColumn {
			let imageView = cell.imageView as! ThemedImage
			imageView.run = self.run
			if let image = run.icon(for: row) {
				imageView.image = image
			} else {
				imageView.image = nil
			}
			imageView.setColor()
			return cell
		}
		setFont(cell.textField!)
		
		if id == STVColumnID.splitTitleColumn {
			let name = splitsState.name(row)
			cell.textField?.stringValue = name
			cell.textField?.textColor = run.textColor
			return cell
		}
		
		let ct = splitsState.columnValue(row, lsColIndex)
		cell.textField?.stringValue = ct
		setThemeColor(cell.textField!)
		
		return cell
	}
	
	func tableViewColumnDidMove(_ notification: Notification) {
		let newIdx = (notification.userInfo!["NSNewColumn"] as! NSNumber).intValue
		let oldIdx = (notification.userInfo!["NSOldColumn"] as! NSNumber).intValue
		
		//TODO: Move to `SplitterRun`?
		run.undoManager?.registerUndo(withTarget: self, handler: { del in
			del.splitsComponent.splitsTableView.moveColumn(newIdx, toColumn: oldIdx)
		})
		run.undoManager?.setActionName("Undo Move Column")
		
		let editor = LayoutEditor(run.layout)!
		editor.select(splitsComponent.componentIndex)
		//Need to subtract here and not when I define the variable, or there will be problems when undoing, because of when the variables are captured
		editor.moveColumn(oldIdx - 2, to: newIdx - 2)
		run.layout = editor.close()
		NotificationCenter.default.post(name: .runEdited, object: run)
	}
	
	//MARK: - Drag and Drop
	
	//TODO: Don't make new columns for title and icon in LiveSplit
	
	func tableView(_ tableView: NSTableView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
		//If it's the title or icon - don't rearrange
		if columnIndex < 2 {
			return false
		}
		if newColumnIndex != -1 && newColumnIndex < 2 {
			return false
		}
		
		return true
	}
	
	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
//		let font = run.runFont ?? NSFont.systemFont(ofSize: 13)
		return tableView.rowHeight
	}
}
