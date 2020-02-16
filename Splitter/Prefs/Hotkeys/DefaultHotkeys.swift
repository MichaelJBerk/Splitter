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
	
//	public static let bringToFront = "bringToFront"
//	public static let startSplitTimer = "startSplitTimer"
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
	var menuItem: NSUserInterfaceItemIdentifier?
	
	init(settings: KeybindSettingsKey, title: KeybindTitle, menuItem: NSUserInterfaceItemIdentifier?) {
//		self.init(settings: settings, title: title)
		self.settings = settings
		self.title = title
//		self.menuItem = menuItem
	}
	
}

extension AppDelegate {
	
	func loadDefaultSplitterKeybinds() {
		appKeybinds = [
			SplitterKeybind(settings: .bringToFront, title: .BringToFront, menuItem: nil),
			SplitterKeybind(settings: .startSplitTimer, title: .StartSplitTimer, menuItem: menuIdentifiers.timerMenu.StartSplit),
			SplitterKeybind(settings: .pauseTimer, title: .PauseTimer, menuItem: menuIdentifiers.timerMenu.pause),
			SplitterKeybind(settings: .prevSplit, title: .PrevSplit, menuItem: menuIdentifiers.timerMenu.back),
			SplitterKeybind(settings: .stopTimer, title: .StopTimer, menuItem: menuIdentifiers.timerMenu.stop),
			SplitterKeybind(settings: .clearTimer, title: .ClearTimer, menuItem: menuIdentifiers.timerMenu.resetRun),
			SplitterKeybind(settings: .resetCurrentSplit, title: .ResetCurrentSplit, menuItem: menuIdentifiers.timerMenu.reset)
		]
		
		
		var i = 0
		while i < appKeybinds.count {
			if let k = appKeybinds[i] {
//				if k.keybind != nil {
				var sView = MASShortcutView()
				sView.associatedUserDefaultsKey = k.settings.rawValue
				//Need to edit the array directly, so can't use k
				appKeybinds[i]!.keybind = sView.shortcutValue
				let a = keybindAction(keybind: k.title)
				MASShortcutMonitor.shared()?.register(appKeybinds[i]!.keybind, withAction: a)
//				}
			}
			i = i + 1
			
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
		
		
		
	}
	
	
	//Preforms the action for the given keybind
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
