//
//  UISettings.swift
//  Splitter
//
//  Created by Michael Berk on 1/7/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController {
	
	var showHideTitleBarItemText: String {
		get {
			if titleBarHidden {
				return "Show Title Bar"
			} else {
				return "Hide Title Bar"
			}
		}
	}
	///Sets the window to stay on top, depending on the current setting
	func setFloatingWindow() {
		if !Settings.menuBarMode {
			let id = menuIdentifiers.windowMenu.windowFloat
			if let menuItem = NSApp.mainMenu?.item(withIdentifier: id) {
				if windowFloat {
					view.window?.level = .floating
					menuItem.state = .on
				} else {
					view.window?.level = .normal
					menuItem.state = .off
				}
			}
		}
	}
	
	///Shows or hides the title bar, depending on the current setting
	func showHideTitleBar() {
		if titleBarHidden {
			
			view.window?.styleMask.insert(.fullSizeContentView)
			view.window?.standardWindowButton(.closeButton)?.isHidden = true
			view.window?.standardWindowButton(.documentIconButton)?.isHidden = true
			view.window?.titleVisibility = .hidden
		} else {
			view.window?.standardWindowButton(.closeButton)?.isHidden = false
			view.window?.standardWindowButton(.documentIconButton)?.isHidden = false
			view.window?.titleVisibility = .visible
			view.window?.styleMask.remove(.fullSizeContentView)
		}
		let showHideTitleBarItem = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.appearanceMenu.hideTitleBar)
		showHideTitleBarItem?.title = showHideTitleBarItemText
	}
	func showHideTitle() {
		if hideTitle {
			view.window?.titleVisibility = .hidden
		} else {
			view.window?.titleVisibility = .visible
		}
	}
	
	
	@IBAction func showHideTitleBarMenuItem(_ sender: Any? ) {
		titleBarHidden.toggle()
		showHideTitleBar()
	}
	
	var showHideButtonsText: String {
		get {
			if buttonHidden {
				return "Show Buttons"
			} else {
				return "Hide Buttons"
			}
		}
	}
}

extension NSWindow {
	var titlebarHeight: CGFloat {
		if let windowFrameHeight = contentView?.frame.height {
			let contentLayoutRectHeight = contentLayoutRect.height
			let fullSizeContentViewNoContentAreaHeight = windowFrameHeight - contentLayoutRectHeight
			return fullSizeContentViewNoContentAreaHeight
		}
		return 0
	}
}
