//
//  MetadataImage.swift
//  Splitter
//
//  Created by Michael Berk on 7/7/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

///Game Icon
class MetadataImage: ThemedImage {
	override var themeable: Bool {
		get {
			if run.gameIcon == nil {
				return true
			}
			return false
		}
		set {}
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	func setup() {
		self.target = self
		self.action = #selector(imageChanged(_:))
		NotificationCenter.default.addObserver(forName: .gameIconEdited, object: nil, queue: nil, using: { notification in
			self.image = self.run.gameIcon
			self.setPlaceholderImage()
			self.setColor()
		})
	}
	override func setColor() {
		if themeable {
			self.contentTintColor = run.textColor
		}
	}
	
	func setPlaceholderImage() {
		if self.image == nil {
			self.image = .gameControllerIcon
		}
	}
	
	@objc func imageChanged(_ sender: Any?) {
		run.gameIcon = self.image
		setPlaceholderImage()
	}
	
	var allowsUpdate = true
	
}
extension MetadataImage {
	override func mouseDown(with event: NSEvent) {
		if event.clickCount > 1 {
			self.setImage()
		}
	}
	func pictureFileDialog() -> NSOpenPanel{
		let dialog = NSOpenPanel();
		dialog.title                   = "Choose an image file"
		dialog.showsResizeIndicator    = true
		dialog.showsHiddenFiles        = false
		dialog.canChooseDirectories    = false
		dialog.canCreateDirectories    = false
		dialog.allowsMultipleSelection = false
		dialog.allowedFileTypes        = ["png"]
		return dialog
	}
	
	func setImage() {
		let dialog = pictureFileDialog()
		
		let response = dialog.runModal()
		if response == .OK {
			let result = dialog.url
			
			if (result != nil) {
				let imageFile = try? Data(contentsOf: result!)
				
				let myImage = NSImage(data: imageFile!)
				
				self.image = myImage
				self.imageChanged(nil)
			}
		}
	}
}

