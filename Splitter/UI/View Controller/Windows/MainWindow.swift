//
//  MainWindow.swift
//  Splitter
//
//  Created by Michael Berk on 1/13/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

///This class is needed for the Hotkeys to work. I don't remeber why at the moment.
class MainWindow: NSWindow {
	
	var observer: Any!
	override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
		super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
		observer = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: nil, using: { _ in
			if AppSettings.menuBarMode {
				self.orderFront(self)
			}
		})
	}
	
	override func setTitleWithRepresentedFilename(_ filename: String) {
		super.setTitleWithRepresentedFilename(filename)
		
	}
	
	//need to override `close` and remove the observer or the window will reappear after changing spaces in Overlay Mode
	override func close() {
		super.close()
		NSWorkspace.shared.notificationCenter.removeObserver(observer!, name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
	}
}


