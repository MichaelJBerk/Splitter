//
//  GeneralLayoutSettingsViewController.swift
//  Splitter
//
//  Created by Michael Berk on 7/9/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class GeneralLayoutSettingsViewController: NSViewController {
	override func loadView() {
		stackView = ComponentOptionsVstack()
		self.view = stackView
	}
	var run: SplitterRun!
	var stackView: NSStackView!
	
	func buildStack() {
		buildColorsSection()
		buildSeparator()
		buildBGImageSection()
	}
	var backgroundImageWell: NSImageView!
	
	func buildColorsSection() {
		let colorsLabel = NSTextField(labelWithString: "Colors")
		colorsLabel.font = NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .bold)
		stackView.addArrangedSubview(colorsLabel)
		let bgColorLabel = NSTextField(labelWithString: "Background Color")
		let bgColorWell = SplitterColorWell()
		bgColorWell.color = run.backgroundColor
		bgColorWell.allowsOpacity = true
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
		textColorWell.target = self
		textColorWell.action = #selector(textColorWellAction(_:))
		let textResetButton = ComponentOptionsButton(title: "Reset", clickAction: { _ in
			textColorWell.color = .white
			self.textColorWellAction(textColorWell)
		})
		
		let textColorStack = NSStackView(views: [textColorLabel, textColorWell, textResetButton])
		textColorStack.orientation = .horizontal
		stackView.addArrangedSubview(textColorStack)
		
		NSLayoutConstraint.activate([
			bgColorStack.heightAnchor.constraint(equalToConstant: 30),
			textColorStack.heightAnchor.constraint(equalToConstant: 30),
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
		backgroundImageWell = NSImageView(image: #imageLiteral(resourceName: "Hotkeys"))
		backgroundImageWell.isEditable = true
		backgroundImageWell.animates = true
		backgroundImageWell.target = self
		backgroundImageWell.action = #selector(imageWellAction(_:))
		backgroundImageWell.image = run.backgroundImage
		backgroundImageWell.imageFrameStyle = .grayBezel
		let imageStack = NSStackView(views: [imageLabel, backgroundImageWell])
		imageStack.orientation = .horizontal
		stackView.addArrangedSubview(imageStack)
		NSLayoutConstraint.activate([
			backgroundImageWell.heightAnchor.constraint(equalToConstant: 64)
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
