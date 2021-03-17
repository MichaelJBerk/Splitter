//
//  Icon Actions.swift
//  Splitter
//
//  Created by Michael Berk on 2/4/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

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

extension ViewController {
	// MARK: - Icon Actions
	
	/// Prompts the user to select a game icon image
	///
	///Used in right-click menu
	@IBAction func pictureButtonPressed(_ sender: Any) {
		let dialog = pictureFileDialog()
		
		dialog.beginSheetModal(for: view.window!) { (response) in
			if response == .OK {
				let result = dialog.url // Pathname of the file
				
				if (result != nil) {
					 let imageFile = try? Data(contentsOf: result!)
					 
					 let myImage = NSImage(data: imageFile!)
					 
					self.gameIcon = myImage
					self.gameIconButton.image = self.gameIcon
					
				}
			}
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
	///Used in right-click menu for game icon
	@IBAction func removeGameIconMenuItem(sender: Any?) {
		removeGameIcon(sender: sender)
	}
	///Used in right-click menu for game icon
	func removeGameIcon(sender: Any?) {
		gameIconButton.image = #imageLiteral(resourceName: "Game Controller")
	}
}
