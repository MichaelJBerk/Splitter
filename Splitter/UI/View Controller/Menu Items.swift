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
	
	func loadLS(ls: LiveSplit) {
		ls.parseLivesplit()
		if ls.loadedSplits.count > 0 {
			self.currentSplits = ls.loadedSplits
			
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
		
		if let gn = ls.gameName {
			if gn.count > 0 {
				GameTitleLabel.stringValue = gn
			}
		}
		if let sb = ls.subtitle {
			if sb.count > 0 {
				SubtitleLabel.stringValue = sb
			}
		}
		self.gameIcon = ls.img
		splitsTableView.reloadData()
	}
	
	//MARK: Timer Menu
	///Action for Menu Bar that starts/pauses the timer
	@IBAction func startPauseTimerMenuItem(_ sender: Any?) {
			switch timerState {
			case .stopped:
				startTimer()
			default:
				pauseResumeTimer()
			}
		
	}
	
	@IBAction func pauseMenuItem(_ sender: Any?) {
		stopTimer()
	}

	
	@IBAction func nextSplitMenuItem(_ sender: Any?) {
		
//
		
		goToNextSplit()
	}


	@IBAction func prevSplitMenuItem(_ sender: Any?) {
		goToPrevSplit()
	}
	
	//MARK: Info menu
	
	
	//TODO: See if I should remove the two menu bar items below, as they're not really necessary
	///Action for Menu Bar that allows the user to edit the subtitle
	@IBAction func editTitle(_ sender: Any) {
		GameTitleLabel.becomeFirstResponder()
	}
	
	///Action for Menu Bar that allows the user to edit the subtitle
	@IBAction func editSubtitle(_ sender: Any) {
		SubtitleLabel.becomeFirstResponder()
	}
	
	///Action for Menu Bar that clears the current splits
		@IBAction func clearMenuItem(_ sender: Any) {
			askToClearTimer()
	//		return false
		}
	
	@IBAction func resetCurrentSplitMenuItem(_ sender: Any) {
		resetCurrentSplit()
	}
	
	
	//MARK: Appearance Menu
	
	
	///Action for Menu Bar that allows the user to hide or show the "best splits" column
	@IBAction func showHideBestSplitsMenuItem(_ sender: Any) {
		//TODO: See if there's a way I can get it to scroll to the colun when shown
		//TODO: refactor this so that it's separate from the menu item action
		showBestSplits.toggle()
		showHideBestSplits()
	}
	
	
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
			floatingWindow()
			
		}
		
		func floatingWindow() {
			let id = menuIdentifiers.windowMenu.windowFloat
			if let menuItem = NSApp.mainMenu?.item(withIdentifier: id) {
				print(windowFloat)
	
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
