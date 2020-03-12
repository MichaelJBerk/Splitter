//
//  Menu Items.swift
//  Splitter
//
//  Created by Michael Berk on 2/4/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController {
	//MARK: - Actions for the Menu Bar
		
	
	//MARK - File Menu
	//TODO: Move liveSplit loading to another file
	func loadLS(ls: LiveSplit) {
		ls.parseLivesplit()
		if ls.splits.count > 0 {
			var i = 0
			
			while i < ls.splits.count {
				currentSplits.append(ls.splits[i].copy() as! splitTableRow)
				i = i + 1
			}
			
		}
		var i = 0
		if ls.iconArray.count > 0 {
			while i < currentSplits.count {
				if ls.iconArray[i] != nil {
					currentSplits[i].splitIcon = ls.iconArray[i]
				}
				i = i + 1
			}
		}
		
		if let gn = ls.runTitle {
			if gn.count > 0 {
				runTitleField.stringValue = gn
			}
		}
		if let sb = ls.category {
			if sb.count > 0 {
				categoryField.stringValue = sb
			}
		}
		
		if let att = ls.attempts {
			attempts = att
		}
		if let reg = ls.region {
			gameRegion = ls.region
		}
		if let plat = ls.platform {
			platform = ls.platform
		}
		
		
		self.lsPointer = ls.lsPointer
		self.gameIcon = ls.gameIcon
		splitsTableView.reloadData()
	}
	
	//MARK: Run Menu
	///Action for Menu Bar that starts/pauses the timer
	@IBAction func startSplitMenuItem(_ sender: Any?) {
		startSplitTimer()
		
	}
	@IBAction func pauseMenuItem(_ sender: Any?) {
		pauseResumeTimer()
	}
	
	@IBAction func stopMenuItem(_ sender: Any?) {
		stopTimer()
	}

	@IBAction func prevSplitMenuItem(_ sender: Any?) {
		goToPrevSplit()
	}
	
	@IBAction func resetRunMenuItem(_ sender: Any) {
		resetRun()
	}
	
	@IBAction func resetCurrentSplitMenuItem(_ sender: Any) {
		resetCurrentSplit()
	}
	
	@IBAction func showInfoPanelMenuItem(_ sender: Any) {
		displayInfoPopover(sender)
	}
	@IBAction func showColumnOptionsMenuItem(_ sender: Any) {
		displayColumnOptionsPopover(sender)
	}
	
	
	//MARK: Appearance Menu
	
	
	///Action for Menu Bar that allows the user to hide or show the buttons in the UI
	@IBAction func toggleShowHideUIMenuItem(_ sender: Any) {
		if let menuItem = sender as? NSMenuItem {
			UIHidden.toggle()
//			if UIHidden {
//				menuItem.title = "Hide Buttons/UI"
//				showHideUI()
//			} else {
//				menuItem.title = "Show Buttons/UI"
				showHideUI()
//			}
			
		}
	}
	
		
		
		
		
		
		//MARK: Window Menu
		
		//TODO: Figure out what this and `floatingWindow` are used for
		@IBAction func toggleKeepOnTop(_ sender: Any? ) {
			windowFloat.toggle()
			setFloatingWindow()
			
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
		
		///Action for Menu Bar that closes the current window. This can be useful if the title bar has been hidden by the user
		@IBAction func closeMenuItem(_ sender: Any) {
			view.window?.close()
		}
}
