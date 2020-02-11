//
//  globalKeybinds.swift
//  Splitter
//
//  Created by Michael Berk on 1/14/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa
import HotKey
import Carbon



class Keybind {
	var Title: KeybindTitle!
	var hotkey: HotKey? {
		didSet {
			setKeyEquivalent()
		}
	}
	var globalKeybind: GlobalKeybindPreferences?
	var menuItemID: NSUserInterfaceItemIdentifier?
	var menuItem: NSMenuItem? {
		get {
			if let menuID = menuItemID {
				let menu = NSApp.mainMenu?.item(withIdentifier: menuID)
				return menu
			}
			return nil
		}
	}
	
	var KeybindFileName: String {
		let keyTitle = Title.rawValue
		return keyTitle.replacingOccurrences(of: "/", with: "") + ".json"
	}
	
	convenience init(title: KeybindTitle, keyDownHandler: @escaping () -> Void) {
		self.init(title: title)
		hotkey?.keyDownHandler = keyDownHandler
	}
	
	convenience init(title: KeybindTitle, keyDownHandler: @escaping () -> Void, menuItemID: NSUserInterfaceItemIdentifier) {
		self.init(title: title, keyDownHandler: keyDownHandler)
		self.menuItemID = menuItemID
		setKeyEquivalent()
	}
	
	init(title: KeybindTitle) {
		self.Title = title
		

		if Storage.fileExists(KeybindFileName, in: .appSupport) {
			print(KeybindFileName)
			self.globalKeybind = Storage.retrieve(KeybindFileName, from: .appSupport, as: GlobalKeybindPreferences.self)
			self.hotkey = HotKey(carbonKeyCode: self.globalKeybind!.keyCode, carbonModifiers: self.globalKeybind!.carbonFlags)
			if let app = NSApplication.shared.delegate as? AppDelegate {
			}
		}
		
		
	}
	
	func setKeyEquivalent() {
		if let item = menuItem {
			if let ke = hotkey?.keyCombo.key?.description {
				item.keyEquivalent = ke.lowercased()
				if let mod = hotkey?.keyCombo.modifiers {
					item.keyEquivalentModifierMask = (hotkey?.keyCombo.modifiers)!
				}
			}
		}
	}
	

	
	func eventToKeybindPrefs(from event: NSEvent) -> GlobalKeybindPreferences? {
		//originally GetNewGlobalKeybind
		print("flags ",  event.modifierFlags)
		print("has fn: ",event.modifierFlags.contains(.function))
		var notEnough = false
		if !event.modifierFlags.contains(.command) && !event.modifierFlags.contains(.control) && !event.modifierFlags.contains(.option) {
			notEnough = true
		}
		if notEnough {
//		if event.modifierFlags.description == "" || event.modifierFlags == [.function] {
			let alert = NSAlert()
			alert.alertStyle = .informational
			alert.informativeText = "A hotkey must at least include \(modifierChars.command.rawValue), \(modifierChars.option.rawValue), or \(modifierChars.control.rawValue)"
			if event.modifierFlags.contains(.function) {
				alert.informativeText.append("And, no, Fn alone doesn't count.")
			}
			alert.messageText = "Invalid Hotkey"
			alert.icon = #imageLiteral(resourceName: "Hotkeys")
			alert.runModal()
			return nil
		}
		
		if let characters = event.charactersIgnoringModifiers {
			let newGlobalKeybind = GlobalKeybindPreferences(
//				function: event.modifierFlags.contains(.function),
				control: event.modifierFlags.contains(.control),
				command: event.modifierFlags.contains(.command),
				shift: event.modifierFlags.contains(.shift),
				option: event.modifierFlags.contains(.option),
				capsLock: event.modifierFlags.contains(.capsLock),
				carbonFlags: event.modifierFlags.carbonFlags,
				characters: characters,
				keyCode: UInt32(event.keyCode)
			)
			
			return newGlobalKeybind
		}
		return nil
		
	}
	
	///Updates the keybind file in the application support folder.
	 func updateKeybind(from event: NSEvent) {
		//originally UpdateGlobalShortcut
		

		if let characters = event.charactersIgnoringModifiers {
			if let newGlobalKeybind = eventToKeybindPrefs(from: event) {
				Storage.store(newGlobalKeybind, to: .appSupport, as: KeybindFileName)
				
			}
		}
//		self.cellForEvent = nil
	}
	
}




