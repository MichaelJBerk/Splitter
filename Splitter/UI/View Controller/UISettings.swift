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
			
			
			
//
		}
		let showHideTitleBarItem = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.appearanceMenu.hideTitleBar)
		showHideTitleBarItem?.title = showHideTitleBarItemText
	}
	
	
	@IBAction func showHideTitleBarMenuItem(_ sender: Any? ) {
		titleBarHidden.toggle()
		showHideTitleBar()
	}
	
	///Shows or hides the UI, depending on the current setting
	func showHideUI() {
			if UIHidden {
				StartButton.isHidden = true
				trashCanPopupButton.isHidden = true
				stopButton.isHidden = true
				
				plusButton.isHidden = true
				minusButton.isHidden = true
				nextButton.isHidden = true
				prevButton.isHidden = true
				infoPanelPopoverButton.isHidden = true
				columnOptionsPopoverButton.isHidden = true
				
	//			UIHidden = true
			} else {
				StartButton.isHidden = false
				if shouldStopButtonBeHidden == true {
					stopButton.isHidden = true
				} else {
					stopButton.isHidden = false
				}
				if shouldTrashCanBeHidden == true {
					trashCanPopupButton.isHidden = true
				} else {
					trashCanPopupButton.isHidden = false
				}
				infoPanelPopoverButton.isHidden = false
				columnOptionsPopoverButton.isHidden = false
				
				
				plusButton.isHidden = false
				minusButton.isHidden = false
				nextButton.isHidden = false
				prevButton.isHidden = false
				
	//			UIHidden = false
			}
		let mi = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.appearanceMenu.hideButtons)
		mi?.title = showHideButtonsText
		}
	
	var showHideButtonsText: String {
		get {
			if UIHidden {
				return "Show Timer/Splits Buttons"
			} else {
				return "Hide Timer/Splits Buttons"
			}
		}
	}
}

//static let ShowHideUIID = "HideButtonsItem"
