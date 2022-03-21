//
//  StatusBarController.swift
//  Splitter
//
//  Created by Michael Berk on 12/13/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class StatusBarController: NSObject {
	
	var statusItem: NSStatusItem!
	var statusMenu: NSMenu!
	
	var quitItem: NSMenuItem {
		let quit = NSMenuItem(title: "Quit", action: #selector(quitMenuItem(_:)), keyEquivalent: "q")
		quit.keyEquivalentModifierMask = [.command]
		return quit
	}
	
	var turnOffOverlayItem = NSMenuItem(title: "Turn Off Overlay Mode", action: #selector(turnOffOverlayAction(_:)), keyEquivalent: "")
	
	var prefsItem: NSMenuItem {
		let item = NSMenuItem(title: "Preferences", action: #selector(showPrefsMenuItem(_:)), keyEquivalent: ",")
		item.keyEquivalentModifierMask = [.command]
		item.target = self
		return item
	}
	
	func setupItem() {
		let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
		statusMenu = NSMenu(title: "PopMenu")
		self.statusItem = item
		if let button = item.button {
			let img = NSImage(named: "menuBarIcon")
			button.image = img!
			button.imageScaling = .scaleProportionallyDown
			button.target = self
			button.action = #selector(clickItem(_:))
			item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
		}
		
		
		statusMenu.delegate = self
		let menuItems = [quitItem, .separator(), turnOffOverlayItem, prefsItem]
		for item in menuItems {
			item.target = self
			statusMenu.addItem(item)
		}
		
		
		
		NotificationCenter.default.addObserver(forName: .menuBarModeChanged, object: nil, queue: nil, using: { _ in
			self.toggleVisible()
		})
		Self.setMenuBarMode(Settings.menuBarMode)
	}
	
	func toggleVisible() {
		if Settings.menuBarMode {
			statusItem.isVisible = true
		} else {
			statusItem.isVisible = false
		}
	}
	
	@objc func quitMenuItem(_ sender: Any?) {
		NSApp.terminate(nil)
	}
	@objc func turnOffOverlayAction(_ sender: Any?) {
		Self.setMenuBarMode(false)
	}
	@objc func showPrefsMenuItem(_ sender: Any?) {
		AppDelegate.shared?.preferencesMenuItemActionHandler(sender as! NSMenuItem)
	}
	
	@objc func clickItem(_ sender: Any?) {
		let event = NSApp.currentEvent!
		if event.type == .rightMouseUp {
			statusItem.menu = statusMenu
			statusItem.button?.performClick(nil)
		} else {
			NSApp.activate(ignoringOtherApps: true)
			//Always 1 window - status item
			AppDelegate.shared?.newWindowIfNone()
		}
	}
	
	static func setMenuBarMode(_ bool: Bool) {
		Settings.menuBarMode = bool
		let pol: NSApplication.ActivationPolicy = bool ? .accessory : .regular
		NSApp.setActivationPolicy(pol)
	}
}

extension StatusBarController: NSMenuDelegate {
	func menuDidClose(_ menu: NSMenu) {
		statusItem.menu = nil
	}
}
