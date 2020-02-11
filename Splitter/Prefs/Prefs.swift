//
//  Prefs.swift
//  Splitter
//
//  Created by Michael Berk on 1/1/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences

extension PreferencePane.Identifier {
	static let general = Identifier("general")
	static let advanced = Identifier("advanced")
	static let hotkeys = Identifier("hotkeys")
	
}


//
//
//final class AdvancedPreferenceViewController: NSViewController, PreferencePane {
//	let preferencePaneIdentifier = PreferencePane.Identifier.advanced
//	let preferencePaneTitle = "Advanced"
//	let toolbarItemIcon = NSImage(named: NSImage.advancedName)!
//
//	override var nibName: NSNib.Name? { "AdvancedPreferenceViewController" }
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//
//		// Setup stuff here
//	}
//}
