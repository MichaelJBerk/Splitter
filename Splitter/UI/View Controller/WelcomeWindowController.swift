//
//  WelcomeWindowController.swift
//  Splitter
//
//  Created by Michael Berk on 7/27/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class WelcomeWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
		//Need to close the window controller so that `NSApp.windows` removes the welcome window when closed
		NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: self.window, queue: nil, using: { _ in
			self.close()
		})
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
		
    }
	
	
	
	
}

