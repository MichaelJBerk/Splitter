//
//  ComponentOptions.swift
//  Splitter
//
//  Created by Michael Berk on 7/5/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
class ComponentOptionsButton: NSButton {
	var clickAction: (NSButton) -> () = {_ in}
	override func mouseDown(with event: NSEvent) {
		super.mouseDown(with: event)
		clickAction(self)
	}
	
	convenience init (checkboxWithTitle title: String, clickAction: @escaping (NSButton) -> ()) {
		self.init(checkboxWithTitle: title, target: nil, action: nil)
		self.clickAction = clickAction
	}
	convenience init (title: String, clickAction: @escaping (NSButton) -> ()) {
		self.init(title: title, target: nil, action: nil)
		self.clickAction = clickAction
	}
}

class ComponentOptionsVstack: NSStackView {
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.orientation = .vertical
		self.alignment = .leading
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var isFlipped: Bool {
		return true
	}
}
