//
//  SplitterColorWell.swift
//  Splitter
//
//  Created by Michael Berk on 6/30/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
@IBDesignable
///A control that displays a color value and lets the user change that color value.
class SplitterColorWell: NSColorWell {
	var customAction: (SplitterColorWell) -> () = {_ in}
	
	@objc func colorWellAction(_ sender: SplitterColorWell) {
		customAction(sender)
	}
	
	convenience init(action: @escaping (SplitterColorWell) -> ()) {
		self.init()
		self.target = self
		self.action = #selector(colorWellAction(_:))
		self.customAction = action
	}
	
	@IBInspectable var allowsOpacity: Bool = true
	
	///Place to save the existing shared `showsAlpha` setting
	private var sharedOpacity: Bool?
	
	override func activate(_ exclusive: Bool) {
		if allowsOpacity {
			NSColorPanel.shared.showsAlpha = true
		} else {
			NSColorPanel.shared.showsAlpha = false
		}
		super.activate(exclusive)
	}
	override func deactivate() {
		if let shared = sharedOpacity {
			NSColorPanel.shared.showsAlpha = shared
		}
		super.deactivate()
	}
}

