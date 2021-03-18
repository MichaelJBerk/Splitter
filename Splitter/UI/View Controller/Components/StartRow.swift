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
	
	@IBOutlet var trashCanPopupButton: NSPopUpButton!
	@IBOutlet var startButton: NSButton!
	@IBOutlet var stopButton: NSButton!
	
	var viewController: ViewController?
	
	
	
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
