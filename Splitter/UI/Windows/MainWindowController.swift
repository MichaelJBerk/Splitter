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
//		windowToolbar.
		DispatchQueue.main.async {
//			self.view.window?.becomeFirstResponder()
//			self.window?.becomeFirstResponder()
		}
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
//	override func keyDown(with event: NSEvent) {
//		super.keyDown(with: event)
//		if let h = self.contentViewController as? HotkeysViewController {
//			if h.listening{
//				h.updateGlobalShortcut(event)
//			}
//		}
//	}

}
