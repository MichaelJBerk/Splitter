//
//  GeneralLayoutSettingsViewController.swift
//  Splitter
//
//  Created by Michael Berk on 7/9/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
import LiveSplitKit

class GeneralLayoutSettingsViewController: NSViewController {
	override func loadView() {
		stackView = ComponentOptionsVstack()
		self.view = stackView
	}
	var run: SplitterRun!
	var stackView: ComponentOptionsVstack!
	var backgroundImageWell: NSImageView!
	var fontStack: ComponentOptionsFontStack!
	
	func buildStack() {
		buildColorsSection()
		stackView.addSeparator()
		buildBGImageSection()
		stackView.addSeparator()
		buildFontStackSection()
	}
	
	func buildColorsSection() {
		let colorsLabel = NSTextField(labelWithString: "Colors")
		colorsLabel.font = .headingFont
		stackView.addArrangedSubview(colorsLabel)
		let bgColorLabel = NSTextField(labelWithString: "Background Color")
		let bgColorWell = SplitterColorWell()
		bgColorWell.color = run.backgroundColor
		bgColorWell.allowsOpacity = true
		bgColorWell.setAccessibilityIdentifier("Background Color Well")
		bgColorWell.target = self
		bgColorWell.action = #selector(colorWellAction(_:))
		let bgResetButton = ComponentOptionsButton(title: "Reset", clickAction: { _ in
			bgColorWell.color = .splitterDefaultColor
			self.colorWellAction(bgColorWell)
		})
		let bgColorStack = NSStackView(views: [bgColorLabel, bgColorWell, bgResetButton])
		bgColorStack.orientation = .horizontal
		stackView.addArrangedSubview(bgColorStack)
		
		let textColorLabel = NSTextField(labelWithString: "Text Color")
		let textColorWell = SplitterColorWell()
		textColorWell.color = run.textColor
		textColorWell.allowsOpacity = false
		textColorWell.setAccessibilityIdentifier("Text Color Well")
		textColorWell.target = self
		textColorWell.action = #selector(textColorWellAction(_:))
		let textResetButton = ComponentOptionsButton(title: "Reset", clickAction: { _ in
			textColorWell.color = .splitterDefaultTextColor
			self.textColorWellAction(textColorWell)
		})
		
		let textColorStack = NSStackView(views: [textColorLabel, textColorWell, textResetButton])
		textColorStack.orientation = .horizontal
		stackView.addArrangedSubview(textColorStack)
		bgColorStack.distribution = .fill
		bgColorWell.setContentHuggingPriority(.defaultLow, for: .horizontal)
		bgResetButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		
		if #available(macOS 13.0, *) {
			bgColorWell.colorWellStyle = .expanded
			textColorWell.colorWellStyle = .expanded
		}
		
		NSLayoutConstraint.activate([
			bgColorStack.heightAnchor.constraint(equalToConstant: 30),
			bgResetButton.trailingAnchor.constraint(equalTo: bgColorStack.trailingAnchor),
			bgColorStack.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
			textColorStack.heightAnchor.constraint(equalToConstant: 30),
			textColorWell.widthAnchor.constraint(equalTo: bgColorWell.widthAnchor),
			textColorWell.widthAnchor.constraint(equalTo: bgColorWell.widthAnchor),
			textColorWell.leadingAnchor.constraint(equalTo: bgColorWell.leadingAnchor)
		])
		NotificationCenter.default.addObserver(forName: .runColorChanged, object: run, queue: nil, using: { notification in
			let run = notification.object as! SplitterRun
			bgColorWell.color = run.backgroundColor
			textColorWell.color = run.textColor
		})
	}
	func buildSeparator() {
		let separatorView = NSView()
		separatorView.wantsLayer = true
		separatorView.layer?.backgroundColor = NSColor.separatorColor.cgColor
		stackView.addArrangedSubview(separatorView)
		NSLayoutConstraint.activate([
			separatorView.heightAnchor.constraint(equalToConstant: 1)
		])
	}
	
	func buildBGImageSection() {
		let imageLabel = NSTextField(labelWithString: "Background Image")
		imageLabel.font = .headingFont
		backgroundImageWell = NSImageView(image: #imageLiteral(resourceName: "Hotkeys"))
		backgroundImageWell.isEditable = true
		backgroundImageWell.animates = true
		backgroundImageWell.target = self
		backgroundImageWell.action = #selector(imageWellAction(_:))
		backgroundImageWell.image = run.backgroundImage
		backgroundImageWell.imageFrameStyle = .grayBezel
		stackView.addArrangedSubview(imageLabel)
		stackView.addArrangedSubview(backgroundImageWell)
		NSLayoutConstraint.activate([
			backgroundImageWell.heightAnchor.constraint(equalToConstant: 64),
			backgroundImageWell.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 2),
			backgroundImageWell.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -10),
		])
		NotificationCenter.default.addObserver(forName: .backgroundImageEdited, object: self.run, queue: nil, using: { notification in
			if self.run.undoManager?.isUndoing ?? false ||
				self.undoManager?.isRedoing ?? false {
				if let image = notification.userInfo?["image"] as? NSImage {
					self.backgroundImageWell.image = image
				} else {
					self.backgroundImageWell.image = nil
				}
			}
		})
	}
	
	func buildFontStackSection() {
		fontStack = ComponentOptionsFontStack(title: "Text Font", fontSize: self.run.fontManager.textFontSize, helpText: "Font used for most text in the Run window.", font: self.run.codableLayout.textFont, onFontChange: fontChanged(to:), onSizeChange: sizeChanged(to:))
		stackView.addArrangedSubview(fontStack)
	}
	
	func fontChanged(to newFont: LiveSplitFont?) {
		run.fontManager.setTextFont(to: newFont)
	}
	func sizeChanged(to newSize: CGFloat) {
		run.fontManager.textFontSize = newSize
	}
	
	@objc func colorWellAction(_ sender: NSColorWell) {
		run.backgroundColor = sender.color
	}
	@objc func textColorWellAction(_ sender: NSColorWell) {
		run.textColor = sender.color
	}
	@objc func imageWellAction(_ sender: NSImageView) {
		run.backgroundImage = sender.image
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		buildStack()
        // Do view setup here.
    }
    
}
