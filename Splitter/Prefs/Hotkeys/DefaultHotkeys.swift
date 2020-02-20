//
//  DefaultHotkeys.swift
//  Splitter
//
//  Created by Michael Berk on 1/31/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

enum KeybindTitle: String {
	case BringToFront = "Bring To Front"
	case StartSplitTimer = "Start Timer/Split"
	case PauseTimer = "Pause Timer"
	case PrevSplit = "Previous Split"
	case StopTimer = "Stop Timer"
	case ClearTimer = "Reset Run"
	case ResetCurrentSplit = "Reset Current Split"
	
}

enum KeybindSettingsKey: String {
	
	case bringToFront = "bringToFront"
	case startSplitTimer = "startSplitTimer"
	case pauseTimer = "pauseTimer"
	case prevSplit = "prevSplit"
	case stopTimer = "stopTimer"
	case clearTimer = "clearTimer"
	case resetCurrentSplit = "Reset Current Split"
}

struct SplitterKeybind {
	var keybind: MASShortcut?
	var settings: KeybindSettingsKey
	var title: KeybindTitle
	var menuItemID: NSUserInterfaceItemIdentifier?
	var menuItem: NSMenuItem? {
		if let id = self.menuItemID {
			return NSApp.mainMenu?.item(withIdentifier: id)
		}
		return nil
	}
	
	
	
	init(settings: KeybindSettingsKey, title: KeybindTitle, menuItemID: NSUserInterfaceItemIdentifier?) {
		self.settings = settings
		self.title = title
		self.menuItemID = menuItemID
	}
	
}

extension AppDelegate {
	
	func loadDefaultSplitterKeybinds() {
		MASShortcutMonitor.shared()?.unregisterAllShortcuts()
		
		appKeybinds = [
			SplitterKeybind(settings: .bringToFront, title: .BringToFront, menuItemID: nil),
			SplitterKeybind(settings: .startSplitTimer, title: .StartSplitTimer, menuItemID: menuIdentifiers.timerMenu.StartSplit),
			SplitterKeybind(settings: .pauseTimer, title: .PauseTimer, menuItemID: menuIdentifiers.timerMenu.pause),
			SplitterKeybind(settings: .prevSplit, title: .PrevSplit, menuItemID: menuIdentifiers.timerMenu.back),
			SplitterKeybind(settings: .stopTimer, title: .StopTimer, menuItemID: menuIdentifiers.timerMenu.stop),
			SplitterKeybind(settings: .clearTimer, title: .ClearTimer, menuItemID: menuIdentifiers.timerMenu.resetRun),
			SplitterKeybind(settings: .resetCurrentSplit, title: .ResetCurrentSplit, menuItemID: menuIdentifiers.timerMenu.reset)
		]
		
		
		var i = 0
		while i < appKeybinds.count {
			if let k = appKeybinds[i] {
				let sView = MASShortcutView()
				sView.associatedUserDefaultsKey = k.settings.rawValue
				//Need to edit the array directly, so can't use k
				appKeybinds[i]!.keybind = sView.shortcutValue
				let a = keybindAction(keybind: k.title)
				if appKeybinds[i]?.keybind != nil {
				MASShortcutMonitor.shared()?.register(appKeybinds[i]!.keybind, withAction: a)
				}
			}
			i = i + 1
			
		}
		updateKeyEquivs()
	}
	
	///Refreshes the "Key Equivalents" displayed in the Menu Bar to be the user's custom hotkeys
	func updateKeyEquivs() {
		for i in appKeybinds {
			if i?.menuItemID != nil {
				let mi = NSApp.mainMenu?.item(withIdentifier: i!.menuItemID!)
				
				mi!.keyEquivalent = i?.keybind?.keyCodeString ?? ""
				if let mods = i?.keybind?.modifierFlags {
					mi!.keyEquivalentModifierMask = mods
				}
			}
		}
	}
	
	func updateSplitterKeybind(keybind: KeybindTitle, shortcut: MASShortcut) {
		var i = 0
		while i < appKeybinds.count {
			if appKeybinds[i]?.title == keybind {
				MASShortcutBinder.shared()?.breakBinding(withDefaultsKey: appKeybinds[i]?.settings.rawValue)
				MASShortcutMonitor.shared()?.unregisterShortcut(appKeybinds[i]?.keybind)
				
				
				
				appKeybinds[i]?.keybind = shortcut
				let cKeybind = appKeybinds[i]
				let a = keybindAction(keybind: keybind)
				MASShortcutMonitor.shared()?.register(shortcut, withAction: a)
				MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: cKeybind?.settings.rawValue, toAction: a)
				break
			}
		i = i + 1
		}
		
		updateKeyEquivs()
		
	}
	
	
	///Given a keybind title. this will return the action to be prefromed when the keybind is pressed.
	func keybindAction(keybind: KeybindTitle) -> (() -> Void)? {
		switch keybind {
		case .BringToFront:
			return {
				self.frontHandler()
			}
		case .StartSplitTimer:
			return  {
				self.startSplitHandler()
			}
		case .PauseTimer:
			return {
				self.pauseHandler()
			}
		case .PrevSplit:
			return {
				self.prevHandler()
			}
		case .StopTimer:
			return {
				self.stopHandler()
			}
		case .ClearTimer:
			return {
				self.clearHandler()
			}
		case .ResetCurrentSplit:
			return {
				self.resetCurrentSplitHandler()
			}
		default:
			break
		}
		return nil
	}
	
	
}
