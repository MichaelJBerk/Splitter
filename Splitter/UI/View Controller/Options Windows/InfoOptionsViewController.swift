//
//  InfoOptionsViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/3/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa



class InfoOptionsViewController: NSViewController, NSPopoverDelegate, advancedTabDelegate {

	var delegate: ViewController?
	@IBOutlet weak var runTitleField: MetadataField!
	@IBOutlet weak var categoryField: MetadataField!
	@IBOutlet weak var attemptField: MetadataField!
	@IBOutlet weak var platformField: MetadataField!
	@IBOutlet weak var versionField: MetadataField!
	@IBOutlet weak var regionField: MetadataField!
	
	@IBOutlet weak var startTimeLabel: NSTextField!
	@IBOutlet weak var endTimeLabel: NSTextField!
	
	@IBOutlet weak var iconWell: MetadataImage!
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear() {
		super.viewWillAppear()
		if let d = delegate {
			d.infoPanelPopover?.contentSize.height = 325
		}
	}
	
	@IBOutlet weak var startEndDateFormatter: DateFormatter!
	
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		let realAppearance = view.effectiveAppearance.name
		popover.appearance = NSAppearance(named: realAppearance)
		return true
	}
	
	func setupDelegate() {
		getDataFromMain()
		attemptField.formatter = OnlyIntegerValueFormatter()
	}
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
			}
		}
	}
}

class OnlyIntegerValueFormatter: NumberFormatter {

	override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {

		if partialString.isEmpty {
			return true
		}

		return Int(partialString) != nil
	}
}
