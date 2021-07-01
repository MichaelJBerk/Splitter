//
//	SplitsEditorOutlineView.swift
//  Splitter
//
//  Created by Michael Berk on 6/29/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class SplitsEditorOutlineView: NSOutlineView {
	var editor: RunEditor!
	var editorState: RunEditorState {
		editor.getState()
	}
	
	override func selectRowIndexes(_ indexes: IndexSet, byExtendingSelection extend: Bool) {
		for row in 0..<numberOfRows {
			let rowView = rowView(atRow: row, makeIfNecessary: false)
			if indexes.contains(row) {
				if extend {
					editor.selectAdditionally(row)
				} else {
					editor.selectOnly(row)
				}
				rowView?.isSelected = true
			} else {
				editor.unselect(row)
				rowView?.isSelected = false
			}
		}
	}
	override var selectedRowIndexes: IndexSet {
		var indices = IndexSet()
		if let segments = editorState.segments {
			for i in 0..<segments.count {
				if segments[i].selected.bool() {
					indices.insert(i)
				}
			}
		}
		return indices
	}
	override var numberOfSelectedRows: Int {
		return selectedRowIndexes.count
	}
	
	override func deselectRow(_ row: Int) {
		editor.unselect(row)
	}
	var fullIndexSet: IndexSet {
		let array = Array(0...numberOfRows-1)
		let iSet = IndexSet(array)
		return iSet
	}
	
	override func selectAll(_ sender: Any?) {
		selectRowIndexes(fullIndexSet, byExtendingSelection: false)
	}
	override func deselectAll(_ sender: Any?) {
		selectRowIndexes(IndexSet(), byExtendingSelection: false)
	}
	
	override var selectedRow: Int {
		editorState.segments?.firstIndex(where:{$0.selected.bool()}) ?? -1
	}
	override func isRowSelected(_ row: Int) -> Bool {
		editorState.segments?[row].selected.bool() ?? false
	}
	
	override func moveItem(at fromIndex: Int, inParent oldParent: Any?, to toIndex: Int, inParent newParent: Any?) {
		var old = fromIndex
		editor.selectOnly(old)
		if old > toIndex {
			while old > toIndex {
				editor.moveSegmentsUp()
				old-=1
			}
		} else {
			while old < toIndex {
				editor.moveSegmentsDown()
				old+=1
			}
		}
		
		super.moveItem(at: fromIndex, inParent: oldParent, to: toIndex, inParent: newParent)
		
	}
	var splitsDelegate: SplitsEditorOutlineViewDelegate {
		delegate as! SplitsEditorOutlineViewDelegate
	}
	
	///Used to make the segment icons selectable
	override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
		if let view = responder as? NSView,
		   let sup = view.superview {
			let row = self.row(for: sup)
			if row > -1, selectedRowIndexes.contains(row) {
				return true
			}
		}
		return super.validateProposedFirstResponder(responder, for: event)
	}
}

///This protocol doesn't do anything special right now, but I made it at one point, and it could save time in the future, so it's here.
@objc
protocol SplitsEditorOutlineViewDelegate: NSOutlineViewDelegate {}
