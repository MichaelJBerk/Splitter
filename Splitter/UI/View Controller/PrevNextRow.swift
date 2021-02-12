//
//  PrevNextRow.swift
//  Splitter
//
//  Created by Michael Berk on 2/10/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

@IBDesignable
class PrevNextRow: NSStackView, LoadableNib {
	@IBOutlet var contentView: NSView!
	@IBOutlet var prevButton: NSButton!
	@IBOutlet var nextButton: NSButton!
	
	var viewController: ViewController?
	
//	required init?(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
//		loadViewFromNib()
//	}
//	
//	init(viewController: ViewController) {
//		super.init(frame: NSRect.infinite)
//		loadViewFromNib()
//		self.viewController = viewController
//	}
	
	@IBAction func prevButtonClick(_ sender: NSButton?) {
		viewController?.goToPrevSplit()
	}
	@IBAction func nextButtonClick(_ sender: NSButton?) {
		viewController?.goToNextSplit()
	}
	
	
}
