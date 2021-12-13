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
	
	override init() {
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
		super.init()
		if let button = statusItem.button {
			if #available(macOS 11.0, *) {
				button.image = NSImage(systemSymbolName: "gamecontroller", accessibilityDescription: nil)!
			}
			button.target = self
			button.action = #selector(clickItem(_:))
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
	
	@objc func clickItem(_ sender: Any?) {
		NSApp.activate(ignoringOtherApps: true)
		//Always 1 window - status item
		AppDelegate.shared?.newWindowIfNone()
	}
	
	static func setMenuBarMode(_ bool: Bool) {
		Settings.menuBarMode = bool
		let pol: NSApplication.ActivationPolicy = bool ? .accessory : .regular
		NSApp.setActivationPolicy(pol)
	}
}
