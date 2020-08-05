//
//  DebugPrefsViewController.swift
//  Splitter
//
//  Created by Michael Berk on 7/26/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//
#if DEBUG
import Cocoa
import Preferences

class DebugPrefsViewController: NSViewController, PreferencePane {
	var preferencePaneIdentifier: Preferences.PaneIdentifier = .debug
	
	var preferencePaneTitle: String = "Debug"
    var toolbarItemIcon: NSImage {
        if #available(macOS 11.0, *), let img = NSImage(systemSymbolName: "hammer", accessibilityDescription: nil) {
            return img
        } else {
            return NSImage(named: NSImage.mobileMeName)!
        }
    }

	override var nibName: NSNib.Name? { "DebugPrefsViewController" }
	@IBOutlet var splitsIOURLTextField: NSTextField!
	

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		preferredContentSize = NSSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
		
    }
	override func viewDidAppear() {
		super.viewDidAppear()
		splitsIOURLTextField.stringValue = Settings.splitsIOURL.absoluteString
		
	}
	
	@IBAction func editTextField(_ sender: NSTextField) {
		if let url = URL(string: sender.stringValue) {
			Settings.splitsIOURL = url
		}
	}
	
    
}
#endif
