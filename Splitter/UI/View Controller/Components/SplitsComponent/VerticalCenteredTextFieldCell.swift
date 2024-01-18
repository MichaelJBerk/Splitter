//
//  VerticalCenteredTextFieldCell.swift
//  Splitter
//
//  Created by Michael Berk on 6/1/23.
//  Copyright © 2023 Michael Berk. All rights reserved.
//

import Cocoa

///A Text Field Cell that vertically centers its contents
///
///Used for the Splits component
class VerticalCenteredTextFieldCell: NSTextFieldCell {
	override func titleRect(forBounds rect: NSRect) -> NSRect {
			var titleRect = super.titleRect(forBounds: rect)

			let minimumHeight = self.cellSize(forBounds: rect).height
			titleRect.origin.y += (titleRect.height - minimumHeight) / 2
			titleRect.size.height = minimumHeight

			return titleRect
		}

		override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
			super.drawInterior(withFrame: titleRect(forBounds: cellFrame), in: controlView)
		}
}
