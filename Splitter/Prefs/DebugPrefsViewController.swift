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
	let toolbarItemIcon = NSImage(named: NSImage.mobileMeName)!

	override var nibName: NSNib.Name? { "DebugPrefsViewController" }
	

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		preferredContentSize = NSSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
}
#endif
