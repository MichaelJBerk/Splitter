//
//  TimeRow.swift
//  
//
//  Created by Michael Berk on 3/22/21.
//

import Cocoa

class TimeRow: NSStackView, LoadableNib, SplitterComponent {
	
	@IBOutlet var contentView: NSView!
	var viewController: ViewController?
	
	
	@IBOutlet var timeLabel: NSTextField!
	@IBOutlet var attemptsField: MetadataField!
	
//	@IBAction func attemptEdited(_ sender: Any) {
//
//	}
}
