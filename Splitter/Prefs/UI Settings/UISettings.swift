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
	
	func showHideTitleBar() {
		if titleBarHidden {
			view.window?.styleMask.insert(.fullSizeContentView)
			view.window?.standardWindowButton(.closeButton)?.isHidden = true
			view.window?.standardWindowButton(.documentIconButton)?.isHidden = true
			view.window?.titleVisibility = .hidden
			
			
		
			var mI0 = NSApp.mainMenu?.items[5]
			print(mI0?.hasSubmenu)
//
		} else {
			view.window?.standardWindowButton(.closeButton)?.isHidden = false
//
			view.window?.standardWindowButton(.documentIconButton)?.isHidden = false
			view.window?.titleVisibility = .visible

			view.window?.styleMask.remove(.fullSizeContentView)
			
			
			
//
		}
		let showHideTitleBarItem = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.appearanceMenu.hideTitleBar)
		showHideTitleBarItem?.title = showHideTitleBarItemText
	}
	
	
	func showHideBestSplits() {
		 let menuItem = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.appearanceMenu.showBestSplits)
			
			
		if showBestSplits {
			splitsTableView.tableColumns[4].isHidden = false
			
		} else if !splitsTableView.tableColumns[4].isHidden {
			splitsTableView.tableColumns[4].isHidden = true
			
			
		}
		menuItem?.title = showHideBestSplitsItemText
	}
	
	var showHideBestSplitsItemText: String {
		get {
			if showBestSplits {
				return "Hide Best Splits Column"
			} else {
				return "Show Best Splits Column"
			}
		}
	}
	@IBAction func showHideTitleBarMenuItem(_ sender: Any? ) {
		titleBarHidden.toggle()
		showHideTitleBar()
	}
}

//static let ShowHideUIID = "HideButtonsItem"
