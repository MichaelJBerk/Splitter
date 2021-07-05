//
//  Splits.swift
//  Splitter
//
//  Created by Michael Berk on 2/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController {
	
	///Updates the button titles when splitting
	func updateButtonTitles() {
		touchBarDelegate.startSplitTitle = run.nextButtonTitle
		touchBarDelegate.enableDisableButtons()
		splitsTableView.reloadData()
		splitsTableView.scrollRowToVisible(run.currentSplit ?? 0)
	}
	
	///Updates the "Skip Split" menu item
	func updateSkipItem() {
		if let currentSplit = self.run.timer.currentSplit {
			var enabled = true
			if currentSplit >= self.run.segmentCount - 1 {
				enabled = false
			}
			setMenuItemEnabled(item: skipSplitMenuitem, enabled: enabled)
		}
	}
	
	
	//MARK: - Split Navigation
	///Moves the timer to the next split, or finishes the run if the current split is the last.
	func goToNextSplit() {
		run.timer.splitOrStart()
		
	}
	///Moves the timer to the previous split, or restarts the run if the current split is the first
	func goToPrevSplit() {
		run.timer.previousSplit()
		splitsTableView.reloadData()
	}
	
	///Skips the current split. Does nothing if it's the last split.
	func skipSplit() {
		run.timer.skipSplit()
		splitsTableView.reloadData()
	}
	
	//MARK: - Adding and Removing Splits
	func removeSplits(at index: Int? = nil) {
		if let index = index {
			run.removeSegment(index)
		} else {
			run.removeBottomSegment()
		}
	}
	
	///Resets the current split to the time of the previous split, or resets the run if the current split is the last
	func resetCurrentSplit() {
		let alert = NSAlert()
		alert.alertStyle = .informational
		alert.messageText = "Not sure if this is even in LiveSplit-Core"
		alert.informativeText = "Sorry!"
		alert.runModal()
		//TODO: May not be availiable in LiveSplit-Core
	}
	
	///Resets a run (Whatever that means in LiveSplit parlance)
	func resetRun() {
		run.timer.resetRun()
		run.updateLayoutState()
	}
}
