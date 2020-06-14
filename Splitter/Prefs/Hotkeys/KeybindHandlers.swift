//
//  KeybindHandlers.swift
//  Splitter
//
//  Created by Michael Berk on 2/16/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

///Stuff for handling keybind actions
extension AppDelegate {
	///Brings the current window to the front. Intended for use with keybinds.
	func frontHandler()  {
		
		NSApplication.shared.orderedWindows.forEach({ (window) in
			if let mainWindow = window as? MainWindow {
				NSApplication.shared.activate(ignoringOtherApps: true)
				mainWindow.makeKeyAndOrderFront(nil)
				mainWindow.makeKey()
			}
		})
		
	}
	
//TODO: Document why this exists
	func startSplitHandler() {
		if let vc = viewController {
			vc.startSplitTimer()
		}
	}
	
	func pauseHandler() {
		if let vc = viewController {
			vc.pauseResumeTimer()
		}
	}
	
	func prevHandler() {
		if let vc = viewController {
			vc.goToPrevSplit()
		}
	}
	func stopHandler() {
		if let vc = viewController {
			vc.stopTimer()
		}
	}
	func clearHandler() {
		if let vc = viewController {
			vc.resetRun()
		}
	}
	func resetCurrentSplitHandler() {
		if let vc = viewController {
			vc.resetCurrentSplit()
		}
	}
	
	func showInfoHandler() {
		if let vc = viewController {
			vc.displayInfoPopover(self)
		}
	}
	func showColumnOptionsHandler() {
		if let vc = viewController {
			vc.displayColumnOptionsPopover(self)
		}
	}
}
