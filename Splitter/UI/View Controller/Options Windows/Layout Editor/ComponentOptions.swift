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

class ComponentOptionsFontStack: NSGridView {
	//default font size is system 36
	
	/*
	 TODO: Setup state
	 - If default font, disable the other options
	 */
	
	var font: LiveSplitFont? = nil
	
	
	typealias SizeChangeHandler = (Int?) -> ()
	
	var titleLabel: NSTextField!
	var fontLabel = NSTextField(labelWithString: "Font")
	private var fontFamilyPopUp: FontPopUpButton!
	private var stylePopUp, weightPopUp: NSPopUpButton!
	var onFontChange: FontChangeHandler!
	var onSizeChange: SizeChangeHandler!
	var defaultStyleItem, defaultWeightItem, defaultStretchItem: NSMenuItem!
	
	var headlineFont: NSFont {
		if #available(macOS 11.0, *) {
			return NSFont.preferredFont(forTextStyle: .headline)
		}
		return NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
	}
	
	convenience init(title: String, font: LiveSplitFont?, onFontChange: @escaping FontChangeHandler = {_ in}, onSizeChange: @escaping SizeChangeHandler = {_ in}) {
		self.init(numberOfColumns: 2, rows: 0)
		self.titleLabel = NSTextField(labelWithString: title)
		self.titleLabel.font = headlineFont
		self.titleLabel.alignment = .left
		self.onFontChange = onFontChange
		self.onSizeChange = onSizeChange
		addRow(with: [titleLabel, NSView()])
		mergeCells(inHorizontalRange: .init(0...1), verticalRange: .init(0...0))
		
		self.fontFamilyPopUp = FontPopUpButton(frame: .zero, callback: fontSelected(_:))
		self.font = font
		if let font {
			let nsFont = NSFontManager.shared.font(withFamily: font.family, traits: [], weight: 0, size: 1)
			fontFamilyPopUp.selectedFont = nsFont
		}
		addRow(with: [fontLabel, fontFamilyPopUp])
		
		stylePopUp = fontStylePopUp()
		let styleLabel = NSTextField(labelWithString: "Style")
		let styleRow = addRow(with: [styleLabel, stylePopUp])
		styleRow.cell(at: 1).xPlacement = .fill
		if let style = font?.style {
			stylePopUp.selectItem(withTitle: style.displayName)
		}
		
		weightPopUp = fontWeightPopUp()
		let weightLabel = NSTextField(labelWithString: "Weight")
		let weightRow = addRow(with: [weightLabel, weightPopUp])
		weightRow.cell(at: 1).xPlacement = .fill
		if let weight = font?.weight {
			weightPopUp.selectItem(withTitle: weight.displayName)
		}
		
		updateState(callFontChange: false)
	}
	
	func updateState(callFontChange: Bool = true) {
		stylePopUp.isEnabled = !font.isNil
		weightPopUp.isEnabled = !font.isNil
		if callFontChange {
			let nsFont = self.font?.toNSFont()
			onFontChange(nsFont)
		}
	}
	
	func fontWeightPopUp() -> NSPopUpButton {
		let popup = NSPopUpButton(frame: .zero, pullsDown: false)
	
		let weightMenu = NSMenu(title: "")
		for weight in LiveSplitFont.Weight.allCases {
			let item = NSMenuItem(title: weight.displayName, action: #selector(Self.weightPopUpSelected(_:)), keyEquivalent: "", representedObject: weight)
			item.target = self
			weightMenu.addItem(item)
		}
		popup.menu = weightMenu
		return popup
	}
	
	func fontStylePopUp() -> NSPopUpButton {
		let popup = NSPopUpButton(frame: .zero, pullsDown: false)
	
		let styleMenu = NSMenu(title: "")
		for style in LiveSplitFont.Style.allCases {
			let item = NSMenuItem(title: style.displayName, action: #selector(Self.stylePopUpSelected(_:)), keyEquivalent: "", representedObject: style)
			item.target = self
			styleMenu.addItem(item)
		}
		popup.menu = styleMenu
		return popup
	}
	
	func fontSelected(_ font: NSFont? ) {
		if let font, let family = font.familyName {
			let lsFont = LiveSplitFont(family: family, style: self.font?.style ?? .normal, weight: self.font?.weight ?? .medium, stretch: self.font?.stretch ?? .normal)
			self.font = lsFont
		} else {
			self.font = nil
		}
		updateState()
		
	}
	
	@objc func weightPopUpSelected(_ sender: NSMenuItem) {
		if let weight = sender.representedObject as? LiveSplitFont.Weight {
			font?.weight = weight
		}
		updateState()
	}
	
	@objc func stylePopUpSelected(_ sender: NSMenuItem) {
		if let style = sender.representedObject as? LiveSplitFont.Style {
			font?.style = style
		}
		updateState()
	}
	
	
	private func sizeChanged(to: Int?) {
		
	}
}
