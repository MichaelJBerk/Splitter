//
//  StartRow.swift
//  Splitter
//
//  Created by Michael Berk on 3/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
@IBDesignable
class StartRow: NSStackView, LoadableNib, SplitterComponent {
	
	@IBOutlet var contentView: NSView!
	
	var displayTitle: String = "Start Row"
	var displayDescription: String = ""
	
	
	@IBOutlet var trashCanPopupButton: ThemedPopUpButton!
	@IBOutlet var startButton: ThemedButton!
	@IBOutlet var stopButton: ThemedButton!
	
	var viewController: ViewController?
	
	
	var isSelected = false {
		didSet {
			self.didSetSelected()
		}
	}
	
	var optionsView: NSView! {
		let optionsView = NSGridView(views: defaultComponentOptions())
		return optionsView
	}
	
	
	@IBAction func trashCanPopupClick(_ sender: Any) {
		viewController?.trashCanPopupClick(sender)
	}
	@IBAction func startButtonClick(_ sender: Any) {
		viewController?.timerButtonClick(sender)
	}
	@IBAction func stopButtonClick(_ sender: Any) {
		viewController?.stopButtonClick(sender)
	}
	
	
}
