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
	var run: SplitterRun {
		return splitController.run
	}
	
	override var image: NSImage? {
		didSet {
			//Need to do this here to support removing icon via backpsace
			if image == nil {
				run.setIcon(for: row, image: nil)
				splitController.splitsTableView.reloadData(forRowIndexes: .init(arrayLiteral: row), columnIndexes: .init(arrayLiteral: 0))
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
