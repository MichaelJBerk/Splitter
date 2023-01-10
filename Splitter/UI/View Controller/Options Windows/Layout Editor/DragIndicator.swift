//
//  DragIndicator.swift
//  Splitter
//
//  Created by Michael Berk on 10/21/22.
//  Copyright © 2022 Michael Berk. All rights reserved.
//

import AppKit

@IBDesignable
class DragIndicator: NSView {
	
	@IBInspectable var alwaysShowIcon: Bool = false {
		didSet {
			imageView.isHidden = !alwaysShowIcon
		}
	}
	
	var imageView: NSImageView!
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	func setup() {
		var image: NSImage
		
		if #available(macOS 11.0, *) {
			//macOS ≥ 12 has a different name for the symbol, so we need to use the proper name on macOS 11
			var imageName = "line.3.horizontal"
			if ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 11 {
				imageName = "line.horizontal.3"
			}
			image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)!
		} else {
			image = NSImage(named: "lines")!
		}
		let imageView = NSImageView(image: image)
		self.imageView = imageView
		
		self.addSubview(imageView)
		let trackingArea = NSTrackingArea(rect: bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited], owner: self)
		addTrackingArea(trackingArea)
		self.imageView.isHidden = !alwaysShowIcon
	}
	
	override func layout() {
		super.layout()
		if let imageView {
			let x = (self.frame.width - 16) * 0.5
			let y = (self.frame.height - 9) * 0.5
			let f = NSRect(x: x, y: y, width: 16, height: 9)
			imageView.frame = f
			imageView.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
		}
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	override func mouseEntered(with event: NSEvent) {
		super.mouseEntered(with: event)
		if !alwaysShowIcon {
			self.imageView.isHidden = false
		}
	}
	
	override func mouseExited(with event: NSEvent) {
		super.mouseExited(with: event)
		if !alwaysShowIcon {
			self.imageView.isHidden = true
		}
	}
	
	override func mouseUp(with event: NSEvent) {
		super.mouseUp(with: event)
		if !alwaysShowIcon {
			self.imageView.isHidden = true
		}
	}
	
}
