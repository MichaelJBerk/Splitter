//
//  InfoOptionsViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/3/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa



class InfoOptionsViewController: NSViewController, NSPopoverDelegate, advancedTabDelegate, NSTextFieldDelegate {

	var run: SplitterRun!
	var delegate: ViewController?
	@IBOutlet weak var runTitleField: NSTextField!
	@IBOutlet weak var categoryField: NSTextField!
	@IBOutlet weak var attemptField: NSTextField!
	@IBOutlet weak var platformField: NSTextField!
	@IBOutlet weak var versionField: NSTextField!
	@IBOutlet weak var regionField: NSTextField!
	
	@IBOutlet weak var startTimeLabel: NSTextField!
	@IBOutlet weak var endTimeLabel: NSTextField!
	
	@IBOutlet weak var iconWell: MetadataImage!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		runTitleField.delegate = self
		categoryField.delegate = self
		attemptField.delegate = self
		platformField.delegate = self
		versionField.delegate = self
		regionField.delegate = self
		NotificationCenter.default.addObserver(forName: .runEdited, object: nil, queue: nil, using: { _ in
			self.getDataFromMain()
		})
		NotificationCenter.default.addObserver(forName: .gameIconEdited, object: nil, queue: nil, using: { notification in
			
		})
    }
	
	@IBOutlet weak var startEndDateFormatter: DateFormatter!
	
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		let realAppearance = view.effectiveAppearance.name
		popover.appearance = NSAppearance(named: realAppearance)
		return true
	}
	
	func setupDelegate() {
		getDataFromMain()
		getImageFromMain()
		attemptField.formatter = OnlyIntegerValueFormatter()
	}
	func controlTextDidEndEditing(_ obj: Notification) {
		sendDataToMain()
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
