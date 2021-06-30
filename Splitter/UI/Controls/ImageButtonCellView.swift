//
//  ImageButtonCellView.swift
//  Splitter
//
//  Created by Michael Berk on 1/26/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class CellImageWell: ThemedImage {
	var delegate: SplitsEditorSegmentIconDelegate!
	
	@IBOutlet var splitController: ViewController!
	var row: Int!
	
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
	}
	
	func setPlaceholderImage() {
		if self.image == nil {
			self.image = .gameControllerIcon
		}
	}
	
	@objc func imageChanged(_ sender: CellImageWell) {
		let image = sender.image
		delegate.iconPicked(image, for: row)
		setPlaceholderImage()
//		run.setIcon(for: row, image: self.image)
//		setPlaceholderImage()
	}
	
	///Used in right-click menu
	@IBAction func removeImage(_ sender: Any?) {
		image = nil
	}
	///Used in right-click menu
	@IBAction func chooseImageMenuItem(_ sender: Any?) {
		setImage()
	}
}
extension CellImageWell {
	
	override func mouseDown(with event: NSEvent) {
		if event.type == .leftMouseDown, event.clickCount > 1 {
			setImage()
		}
		
//		let indexSet = IndexSet(arrayLiteral: row)
//		splitController.splitsTableView.selectRowIndexes(indexSet, byExtendingSelection: false)
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

	/// Prompts the user to select an image for the split icon
	func setImage() {
		let dialog = pictureFileDialog()

		let response = dialog.runModal()
			if response == .OK {
				let result = dialog.url

				if (result != nil) {
					let imageFile = try? Data(contentsOf: result!)
					let myImage = NSImage(data: imageFile!)
					delegate.iconPicked(myImage, for: row)
//					run.setIcon(for: row, image: myImage)
//					splitController.splitsTableView.reloadData(forRowIndexes: .init(arrayLiteral: row), columnIndexes: .init(arrayLiteral: 0))
			}
		}
	}

	
}
