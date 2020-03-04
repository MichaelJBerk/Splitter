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
	@IBOutlet weak var runTitleField: NSTextField!
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		let realAppearance = view.effectiveAppearance.name
		popover.appearance = NSAppearance(named: realAppearance)
		return true
	}
	
	func setupDelegate() {
		runTitleField.stringValue = delegate!.GameTitleLabel.stringValue
	}
	
	
    
}
