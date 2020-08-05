//
//  CategoryViewController.swift
//  Splitter
//
//  Created by Michael Berk on 8/2/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class CategoryViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		popitem = categoryPopUpButton.selectedItem
    }
	@IBOutlet weak var cancelButton: NSButton!
	@IBOutlet weak var nextButton: NSButton!
	
	@IBAction func cancelButtonAction(_ sender: NSButton) {
		dismiss(nil)
	}
	
	@IBAction func nextButtonAction(_ sender: NSButton) {
		
	}
	
	
	@IBOutlet weak var categoryPopUpButton: NSPopUpButton!
	var popitem: NSMenuItem? = nil
	
	@IBAction func popUpAction(_ sender: NSPopUpButton) {
		popitem = sender.selectedItem
	}
}
