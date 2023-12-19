//
//  SplitsEditorTextField.swift
//  Splitter
//
//  Created by Michael Berk on 6/30/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class TableViewTextField: NSTextField {
	var column: NSUserInterfaceItemIdentifier!
	
	var row: Int!
	
	override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
		return true
	}
}

class SplitsEditorTextField: TableViewTextField {
	
	var outlineView: SplitsEditorOutlineView!
	///Previous of the text field before the user edited it
	///
	///This is used to prevent changing text in LiveSplit if text didn't change, in ``SplitsEditorViewController/controlTextDidEndEditing(_:)``
	var previousValue: String!
	
	///Make sure that clicking text field selects the segment in the segment editor
	override func becomeFirstResponder() -> Bool {
		let sup = super.becomeFirstResponder()
		if !outlineView.selectedRowIndexes.contains(row) {
			outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
		}
		return sup
	}
}
