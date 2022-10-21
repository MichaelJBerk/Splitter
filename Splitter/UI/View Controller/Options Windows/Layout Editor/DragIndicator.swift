//
//  DragIndicator.swift
//  Splitter
//
//  Created by Michael Berk on 10/21/22.
//  Copyright © 2022 Michael Berk. All rights reserved.
//

import AppKit

@available(macOS 11.0, *)
class DragIndicator: NSView {
	
	var imageView: NSView!
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		imageView = NSImageView(image: NSImage(systemSymbolName: "line.3.horizontal", accessibilityDescription: nil)!)
		self.addSubview(imageView)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
