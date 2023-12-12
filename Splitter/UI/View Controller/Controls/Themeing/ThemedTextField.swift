//
//  ThemedTextField.swift
//  Splitter
//
//  Created by Michael Berk on 4/8/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class ThemedTextField: NSTextField, Themeable, Fontable {
	
	var run: SplitterRun!
	var defaultFontSize: CGFloat?
	
	@IBInspectable var fontable: Bool = true
	@IBInspectable var themeable: Bool = true
	@IBInspectable var fixedFontSize: Bool = false
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setColorObserver()
		setFontObserver()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setColorObserver()
		setFontObserver()
	}
	
	func setColor() {
		self.textColor = run.textColor
	}

    
}
