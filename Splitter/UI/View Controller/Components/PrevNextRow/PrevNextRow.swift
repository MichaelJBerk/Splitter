//
//  PrevNextRow.swift
//  Splitter
//
//  Created by Michael Berk on 2/10/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

@IBDesignable
class PrevNextRow: NSStackView, LoadableNib, SplitterComponent {
	var optionsView: NSView! {
		let optionsView = NSGridView(views: defaultComponentOptions())
		return optionsView
	}
	
	var displayTitle: String = "Previous/Next Buttons"
	var displayDescription: String = ""
	
	@IBOutlet var contentView: NSView!
	@IBOutlet var prevButton: ThemedButton!
	@IBOutlet var nextButton: ThemedButton!
	
	var viewController: ViewController?
	
	@IBAction func prevButtonClick(_ sender: NSButton?) {
		viewController?.goToPrevSplit()
	}
	@IBAction func nextButtonClick(_ sender: NSButton?) {
		viewController?.goToNextSplit()
	}
	var isSelected = false {
		didSet {
			self.didSetSelected()
		}
	}
	
	
}
