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
	case SkipSplit = "Skip Split"
	case StopTimer = "Cancel Run"
	case ClearTimer = "Reset Run"
	case ResetCurrentSplit = "Reset Current Split"
	case ShowInfoPanel = "Get Info..."
	case ShowColumnOptions = "Edit Layout..."
	
}

///Keys used to store keybinds in UserDefaults
enum KeybindSettingsKey: String, CaseIterable {
	
	case bringToFront = "bringToFront"
	case startSplitTimer = "startSplitTimer"
	case pauseTimer = "pauseTimer"
	case prevSplit = "prevSplit"
	case skipSplit = "skipSplit"
	case stopTimer = "stopTimer"
	case clearTimer = "clearTimer"
	case resetCurrentSplit = "ResetCurrentSplit"
	case showInfoPanel = "showInfoPanel"
	case showColumnOptions = "showColumnOptions"
}

struct SplitterKeybind: Equatable {
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
	
	static func == (lhs: SplitterKeybind, rhs: NSEvent) -> Bool {
		let code = lhs.keybind?.keyCode
		let mods = lhs.keybind?.modifierFlags
		let eventMods = rhs.modifierFlags.intersection(.deviceIndependentFlagsMask)
		return Int(rhs.keyCode) == code && eventMods == mods
	}
	
	
}

extension AppDelegate {
	
	func makeSplitterKeybinds() {
		appKeybinds = [
			SplitterKeybind(settings: .bringToFront, title: .BringToFront, menuItemID: nil),
			SplitterKeybind(settings: .startSplitTimer, title: .StartSplitTimer, menuItemID: menuIdentifiers.runMenu.StartSplit),
			SplitterKeybind(settings: .pauseTimer, title: .PauseTimer, menuItemID: menuIdentifiers.runMenu.pause),
			SplitterKeybind(settings: .prevSplit, title: .PrevSplit, menuItemID: menuIdentifiers.runMenu.back),
			SplitterKeybind(settings: .skipSplit, title: .SkipSplit, menuItemID: menuIdentifiers.runMenu.skipSplit),
			SplitterKeybind(settings: .stopTimer, title: .StopTimer, menuItemID: menuIdentifiers.runMenu.stop),
			SplitterKeybind(settings: .clearTimer, title: .ClearTimer, menuItemID: menuIdentifiers.runMenu.resetRun),
			//TODO: See if it should be removed permanantly
			//Removing this for now, because LiveSplit doesn't seem to have this as a feature
//			SplitterKeybind(settings: .resetCurrentSplit, title: .ResetCurrentSplit, menuItemID: menuIdentifiers.runMenu.reset),
			SplitterKeybind(settings: .showInfoPanel, title: .ShowInfoPanel, menuItemID: menuIdentifiers.runMenu.info),
			SplitterKeybind(settings: .showColumnOptions, title: .ShowColumnOptions, menuItemID: menuIdentifiers.appearanceMenu.showColumnOptions)
		]
	}
	
	func setupKeybinds() {
		makeSplitterKeybinds()
		var i = 0
		while i < appKeybinds.count {
			let k = appKeybinds[i]!
			let settings = k.settings.rawValue
			if Settings.enableGlobalHotkeys {
				MASShortcutBinder.shared().bindShortcut(withDefaultsKey: settings, toAction: self.keybindAction(keybind: k.title))
			}
			let sView = MASShortcutView()
			sView.associatedUserDefaultsKey = settings
			appKeybinds[i]!.keybind = sView.shortcutValue
			i = i + 1
		}
		updateKeyEquivs()
	}
	
	func breakAllKeybinds() {
		for k in appKeybinds {
			MASShortcutBinder.shared().breakBinding(withDefaultsKey: k!.settings.rawValue)
		}
	}
	
	///Refreshes the "Key Equivalents" displayed in the Menu Bar to be the user's custom hotkeys
	func updateKeyEquivs() {
		for i in appKeybinds {
			if i?.menuItemID != nil {
				let mi = NSApp.mainMenu?.item(withIdentifier: i!.menuItemID!)
				mi!.keyEquivalent = i?.keybind?.keyCodeStringForKeyEquivalent ?? ""
				if let mods = i?.keybind?.modifierFlags {
					mi!.keyEquivalentModifierMask = mods
				}
			}
		}
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
		case .SkipSplit:
			return {
				self.skipHandler()
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
	}
	
	
}
