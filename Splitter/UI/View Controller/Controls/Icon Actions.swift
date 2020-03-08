//
//  Icon Actions.swift
//  Splitter
//
//  Created by Michael Berk on 2/4/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController {
	// MARK: - Icon Actions
		
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
		
		@IBAction func rowPictureButtonPressed(_ sender: Any?) {
			if let imageButton = sender as? NSButton {
				let dialog = pictureFileDialog()
				if (dialog.runModal() == NSApplication.ModalResponse.OK) {
				let result = dialog.url
					if (result != nil) {
						let imageFile = try? Data(contentsOf: result!)
						let myImage = NSImage(data: imageFile!)
						if let sup = imageButton.superview as? NSTableCellView {
							let r = splitsTableView.row(for: sup)
							currentSplits[r].splitIcon = myImage
							imageButton.image = myImage
						}
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
		
		@IBAction func removeGameIconMenuItem(sender: Any?) {
			removeGameIcon(sender: sender)
		}
		
		@IBAction func removeRunIconMenuItem(sender: Any?) {
			removeRunIcon(sender: sender)
		}
		
		func removeGameIcon(sender: Any?) {
			if let menuItem = sender as? NSMenuItem {
				if (menuItem.representedObject as? IconButton) != nil {
					gameIcon = nil
					gameIconFileName = nil
					gameIconButton.image = #imageLiteral(resourceName: "Game Controller")
				}
			}
		}
		
		func removeRunIcon(sender: Any?) {
			let row = splitsTableView.selectedRow
			if row >= 0 {
				currentSplits[row].splitIcon = nil
				if let cell = splitsTableView.rowView(atRow: row, makeIfNecessary: false)?.view(atColumn: 0) as? ImageButtonCellView {
					cell.imageButton.image = #imageLiteral(resourceName: "Game Controller")
				}
				splitsTableView.reloadData()
			} else {
				
				let alert = NSAlert()
				alert.messageText = "You need to select a row before you can edit it"
				alert.alertStyle = .informational
				alert.addButton(withTitle: "OK")
				alert.runModal()
			}
		}
		
		
		

}
