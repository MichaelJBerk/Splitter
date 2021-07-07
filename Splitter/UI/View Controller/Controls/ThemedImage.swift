//
//  ThemedImage.swift
//  Splitter
//
//  Created by Michael Berk on 7/7/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class ThemedImage: NSImageView, Themeable {
	@IBInspectable var themeable: Bool = true
	var run: SplitterRun!
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setColorObserver()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setColorObserver()
	}
	func setColor() {
		if let image = self.image, image.isTemplate {
			self.contentTintColor = run.textColor
		}
	}
}
