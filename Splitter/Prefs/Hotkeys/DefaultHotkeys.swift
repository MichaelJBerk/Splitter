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
	case PauseTimer = "Pause/Resume Timer"
	case PrevSplit = "Previous Split"
	case StopTimer = "Stop Timer"
	case ClearTimer = "Reset Run"
	case ResetCurrentSplit = "Reset Current Split"
	case ShowInfoPanel = "Get Info..."
	case ShowColumnOptions = "Show/Hide Columns..."
	
}

///Keys used to store keybinds in UserDefaults
enum KeybindSettingsKey: String {
	
	case bringToFront = "bringToFront"
	case startSplitTimer = "startSplitTimer"
	case pauseTimer = "pauseTimer"
	case prevSplit = "prevSplit"
	case stopTimer = "stopTimer"
	case clearTimer = "clearTimer"
	case resetCurrentSplit = "ResetCurrentSplit"
	case showInfoPanel = "showInfoPanel"
	case showColumnOptions = "showColumnOptions"
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
			SplitterKeybind(settings: .startSplitTimer, title: .StartSplitTimer, menuItemID: menuIdentifiers.runMenu.StartSplit),
			SplitterKeybind(settings: .pauseTimer, title: .PauseTimer, menuItemID: menuIdentifiers.runMenu.pause),
			SplitterKeybind(settings: .prevSplit, title: .PrevSplit, menuItemID: menuIdentifiers.runMenu.back),
			SplitterKeybind(settings: .stopTimer, title: .StopTimer, menuItemID: menuIdentifiers.runMenu.stop),
			SplitterKeybind(settings: .clearTimer, title: .ClearTimer, menuItemID: menuIdentifiers.runMenu.resetRun),
			SplitterKeybind(settings: .resetCurrentSplit, title: .ResetCurrentSplit, menuItemID: menuIdentifiers.runMenu.reset),
			SplitterKeybind(settings: .showInfoPanel, title: .ShowInfoPanel, menuItemID: menuIdentifiers.runMenu.infoPanel),
			SplitterKeybind(settings: .showColumnOptions, title: .ShowColumnOptions, menuItemID: menuIdentifiers.appearanceMenu.showColumnOptions)
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
				print(i?.keybind?.keyCodeStringForKeyEquivalent)
				mi!.keyEquivalent = i?.keybind?.keyCodeStringForKeyEquivalent ?? ""
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
		case .ShowInfoPanel:
			return {
				self.showInfoHandler()
			}
		case .ShowColumnOptions:
		return {
			self.showColumnOptionsHandler()
			}
		}
		return nil
	}
	
	
}
