//
//  Prefs.swift
//  Splitter
//
//  Created by Michael Berk on 1/1/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences

extension Preferences.PaneIdentifier {
	static let general = Self("general")
	static let advanced = Self("advanced")
	static let hotkeys = Self("hotkeys")
	static let debug = Self("debug")
	static let splitsIO = Self("splitsIO")
}
