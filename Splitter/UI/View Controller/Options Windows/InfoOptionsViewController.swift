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
	
	@IBOutlet weak var startEndDateFormatter: DateFormatter!
	
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		let realAppearance = view.effectiveAppearance.name
		popover.appearance = NSAppearance(named: realAppearance)
		return true
	}
	
	func setupDelegate() {
		getDataFromMain()
		attemptField.formatter = OnlyIntegerValueFormatter()
		
//		StartDateFormatter.date(from: startTimeLabel.stringValue)
		
	}
	
	
	
    
}

class OnlyIntegerValueFormatter: NumberFormatter {

	override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {

		// Ability to reset your field (otherwise you can't delete the content)
		// You can check if the field is empty later
		if partialString.isEmpty {
			return true
		}

		// Optional: limit input length
		/*
		if partialString.characters.count>3 {
			return false
		}
		*/

		// Actual check
		return Int(partialString) != nil
	}
}
