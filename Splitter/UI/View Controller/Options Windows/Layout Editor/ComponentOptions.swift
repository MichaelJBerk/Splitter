//
//  ComponentOptions.swift
//  Splitter
//
//  Created by Michael Berk on 7/5/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
import FontPopUp
import LiveSplitKit

class ComponentOptionsButton: NSButton {
	var clickAction: (NSButton) -> () = {_ in}
	override func mouseDown(with event: NSEvent) {
		super.mouseDown(with: event)
		if isEnabled {
			clickAction(self)
		}
	}
	
	convenience init (checkboxWithTitle title: String, clickAction: @escaping (NSButton) -> ()) {
		self.init(checkboxWithTitle: title, target: nil, action: nil)
		self.clickAction = clickAction
	}
	convenience init (title: String, clickAction: @escaping (NSButton) -> ()) {
		self.init(title: title, target: nil, action: nil)
		self.clickAction = clickAction
	}
	convenience init(image: NSImage, clickAction: @escaping (NSButton) -> ()) {
		self.init(image: image, target: nil, action: nil)
		self.clickAction = clickAction
	}
}

class ComponentPopUpButton: NSPopUpButton {
	var customAction: (NSPopUpButton) -> () = {_ in}
	@objc func selectAction(_ sender: NSPopUpButton) {
		customAction(sender)
	}
	
	convenience init(title: String, selectAction: @escaping (NSPopUpButton) -> ()) {
		self.init(title: title, target: nil, action: #selector(selectAction(_:)))
		self.target = self
		self.customAction = selectAction
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
	
	var onFontChanged: ((_ sender: NSFontManager?) -> Void) = {_ in}
	var fontPanelModes: NSFontPanel.ModeMask = [.standardModes]
	
	@discardableResult func addSeparator() -> NSView {
		let separatorView = NSView()
		separatorView.wantsLayer = true
		separatorView.layer?.backgroundColor = NSColor.separatorColor.cgColor
		self.addArrangedSubview(separatorView)
		NSLayoutConstraint.activate([
			separatorView.heightAnchor.constraint(equalToConstant: 1)
		])
		return separatorView
	}
}
