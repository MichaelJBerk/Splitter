//
//  DefaultHotkeys.swift
//  Splitter
//
//  Created by Michael Berk on 1/31/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa
import HotKey

enum KeybindTitle: String {
	case BringToFront = "Bring To Front"
	case StartSplitTimer = "Start Timer/Split"
	case PauseTimer = "Pause Timer"
	case PrevSplit = "Previous Split"
	case StopTimer = "Stop Timer"
	case ClearTimer = "Reset Run"
	case resetCurrentSplit = "Reset Current Split"
	
}

	


extension AppDelegate {
	
	func setDefaultKeybindValues() {
		
		var newKeybinds: [Keybind] = []
		if let vc = self.viewController {
			newKeybinds.append(contentsOf: [
				Keybind(title: .BringToFront, keyDownHandler: self.frontHandler),
				Keybind(title: .StartSplitTimer, keyDownHandler: vc.startSplitTimer, menuItemID: menuIdentifiers.timerMenu.StartSplit),
				Keybind(title: .PauseTimer, keyDownHandler: vc.pauseResumeTimer, menuItemID: menuIdentifiers.timerMenu.pause),
				Keybind(title: .PrevSplit, keyDownHandler: vc.goToPrevSplit, menuItemID: menuIdentifiers.timerMenu.back),
				Keybind(title: .StopTimer, keyDownHandler: vc.stopTimer, menuItemID: menuIdentifiers.timerMenu.stop),
				Keybind(title: .ClearTimer, keyDownHandler: vc.resetRun),
				Keybind(title: .resetCurrentSplit, keyDownHandler: vc.resetCurrentSplit, menuItemID: menuIdentifiers.timerMenu.reset)
			])
			
		}
		
		self.keybinds = newKeybinds
	}
}
