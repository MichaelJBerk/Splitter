//
//  TimeSplitCell.swift
//  Splitter
//
//  Created by Michael Berk on 2/27/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class TimeSplitCell: NSTableCellView {
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		textField?.placeholderString = "00:00:00.00"
		textField?.isEditable = true
	}
}
