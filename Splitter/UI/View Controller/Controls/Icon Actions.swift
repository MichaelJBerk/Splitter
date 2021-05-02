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
	
	//TODO: Move This to MetadataImage
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
					 
					self.run.gameIcon = myImage
					self.gameIconButton.image = self.run.gameIcon
					
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
		gameIconButton.image = .gameControllerIcon
	}
}
