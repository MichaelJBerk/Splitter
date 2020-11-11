//
//  ImageButtonCellView.swift
//  Splitter
//
//  Created by Michael Berk on 1/26/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa


class ImageButtonCellView: NSTableCellView {
	
	
	var image: NSImage = #imageLiteral(resourceName: "Game Controller")
	@IBOutlet var imageWell: CellImageWell!

	var cellNumber: Int! {
		didSet {
			imageWell.row = cellNumber
		}
	}
}

class CellImageWell: NSImageView {
	@IBOutlet var splitController: ViewController!
	var row: Int!
	
	override var image: NSImage? {
		didSet {
			var newValue = self.image
			if newValue == nil {
				newValue = #imageLiteral(resourceName: "Game Controller")
				newValue?.isTemplate = true
				self.image = newValue?.image(with: splitController.textColor)
				splitController.currentSplits[row].splitIcon = nil
			} else {
				splitController.currentSplits[row].splitIcon = newValue
			}
			
		}
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
