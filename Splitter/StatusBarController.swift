//
//  StatusBarController.swift
//  Splitter
//
//  Created by Michael Berk on 12/13/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class StatusBarController: NSObject {
	
	var statusItem: NSStatusItem
	var statusMenu: NSMenu
	
	var menuItems: [NSMenuItem] = [
		NSMenuItem(title: "Quit", action: #selector(quitMenuItem(_:)), keyEquivalent: ""),
		NSMenuItem(title: "Turn Off Overlay Mode", action: #selector(turnOffOverlayAction(_:)), keyEquivalent: "")
	]
	
	override init() {
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
		statusMenu = NSMenu(title: "PopMenu")
		
		super.init()
		statusMenu.delegate = self
		for item in menuItems {
			item.target = self
			statusMenu.addItem(item)
		}
		if let button = statusItem.button {
			if #available(macOS 11.0, *) {
				button.image = NSImage(systemSymbolName: "gamecontroller", accessibilityDescription: nil)!
			}
			button.target = self
			button.action = #selector(clickItem(_:))
			statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
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
