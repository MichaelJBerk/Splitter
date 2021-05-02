//
//  ImageButtonCellView.swift
//  Splitter
//
//  Created by Michael Berk on 1/26/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa


class ImageButtonCellView: NSTableCellView {
	
	var image: NSImage = .gameControllerIcon
	@IBOutlet var imageWell: CellImageWell!

	var cellNumber: Int! {
		didSet {
			imageWell.row = cellNumber
		}
	}
}

class CellImageWell: ThemedImage {
	
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
	
	@objc func imageChanged(_ sender: Any?) {
		run.setIcon(for: row, image: self.image)
		setPlaceholderImage()
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
		
		let indexSet = IndexSet(arrayLiteral: row)
		splitController.splitsTableView.selectRowIndexes(indexSet, byExtendingSelection: false)
	}

	/// Prompts the user to select an image for the split icon
	func setImage() {
		let dialog = splitController.pictureFileDialog()
		
		let response = dialog.runModal()
			if response == .OK {
				let result = dialog.url
				
				if (result != nil) {
					let imageFile = try? Data(contentsOf: result!)
					let myImage = NSImage(data: imageFile!)
					run.setIcon(for: row, image: myImage)
					splitController.splitsTableView.reloadData(forRowIndexes: .init(arrayLiteral: row), columnIndexes: .init(arrayLiteral: 0))
			}
		}
	}

	
}
