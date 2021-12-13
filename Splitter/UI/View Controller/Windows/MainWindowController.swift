//
//  MainWindowController.swift
//  Splitter
//
//  Created by Michael Berk on 12/22/19.
//  Copyright © 2019 Michael Berk. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

	override func windowDidLoad() {
        super.windowDidLoad()
		NotificationCenter.default.addObserver(forName: .menuBarModeChanged, object: nil, queue: nil, using: { _ in
			self.updateFromMenuBarMode()
		})
		updateFromMenuBarMode()
    }
	
	func updateFromMenuBarMode() {
		if Settings.menuBarMode {
			window?.level = .statusBar
			window?.collectionBehavior = .canJoinAllSpaces
		} else {
			window?.collectionBehavior = .fullScreenAuxiliary
		}
		
		
	}
	
	

}
