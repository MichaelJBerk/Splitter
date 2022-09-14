//
//  SplitsEditorTextField.swift
//  Splitter
//
//  Created by Michael Berk on 6/30/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class SplitsEditorTextField: NSTextField {
	var column: NSUserInterfaceItemIdentifier!
	
	var row: Int!
	var outlineView: SplitsEditorOutlineView!
	
	override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
		return true
	}
	
	///Make sure that clicking text field selects the segment in the segment editor
	override func becomeFirstResponder() -> Bool {
		let sup = super.becomeFirstResponder()
		if !outlineView.selectedRowIndexes.contains(row) {
			outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
		}
		return sup
	}
}
