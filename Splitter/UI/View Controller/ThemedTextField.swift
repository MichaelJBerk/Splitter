//
//  ThemedTextField.swift
//  Splitter
//
//  Created by Michael Berk on 4/8/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class ThemedTextField: NSTextField, Themeable {
	
	@IBInspectable var themeable: Bool = true
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setColorObserver()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setColorObserver()
	}
	func setColor(run: SplitterRun) {
		self.textColor = run.textColor
	}
    
}
