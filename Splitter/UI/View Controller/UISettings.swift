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
	
	
	@IBAction func showHideTitleBarMenuItem(_ sender: Any? ) {
		titleBarHidden.toggle()
		showHideTitleBar()
	}
	
	///Shows or hides the UI, depending on the current setting
	func showHideUI() {
		
		if buttonHidden {
			startButton.isHidden = true
			trashCanPopupButton.isHidden = true
			stopButton.isHidden = true
			
			plusButton.isHidden = true
			minusButton.isHidden = true
			nextButton.isHidden = true
			prevButton.isHidden = true
			infoPanelPopoverButton.isHidden = true
			columnOptionsPopoverButton.isHidden = true
			bottomStackView.views[0].isHidden = true
			bottomStackView.views[2].isHidden = true
			bottomStackView.views[3].isHidden = true
			gameToViewEdgeConstraint?.isActive = true
			categoryToViewEdgeConstraint?.isActive = true
		} else {
			startButton.isHidden = false
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
			bottomStackView.views[0].isHidden = false
			bottomStackView.views[2].isHidden = false
			bottomStackView.views[3].isHidden = false
			
			gameToViewEdgeConstraint?.isActive = false
			categoryToViewEdgeConstraint?.isActive = false
		}
		let mi = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.appearanceMenu.hideButtons)
		mi?.title = showHideButtonsText
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
