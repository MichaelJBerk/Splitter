//
//  TimeRow.swift
//  
//
//  Created by Michael Berk on 3/22/21.
//

import Cocoa

class TimeRow: NSStackView, LoadableNib, SplitterComponent {
	var optionsView: NSView! {
		let optionsView = NSGridView(views: defaultComponentOptions())
		return optionsView
	}
	
	var displayTitle: String = "Time Row"
	var displayDescription: String = ""
	@IBOutlet var contentView: NSView!
	@IBOutlet var timeLabel: NSTextField!
	@IBOutlet var attemptsField: MetadataField!
	var viewController: ViewController?
	var isSelected = false {
		didSet {
			self.didSetSelected()
		}
	}
	
	
//	@IBAction func attemptEdited(_ sender: Any) {
//
//	}
}
