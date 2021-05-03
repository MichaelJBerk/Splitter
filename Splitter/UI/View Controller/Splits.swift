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
	
	//MARK: - Adding and Removing Splits
	func removeSplits(at index: Int? = nil) {
		if let index = index {
			run.removeSegment(index)
		} else {
			run.removeBottomSegment()
		}
	}
	
	///Adds a blank split to the table view
	func addBlankSplit() {
		let blankSplitNumber = currentSplits.count + 1
		let blankSplit = TimeSplit(mil: 0, sec: 0, min: 0, hour: 0)
		let blankTableRow = SplitTableRow(splitName: "\(blankSplitNumber)", bestSplit: blankSplit, currentSplit: blankSplit, previousSplit: blankSplit, previousBest: blankSplit, splitIcon: nil)
		currentSplits.append(blankTableRow)
		splitsTableView.reloadData()
	}
	
	///Adds a new split to the table view, if the timer hasn't started yet.
	func addSplit() {
		run.addSegment(title: "\(run.segmentCount + 1)")
		splitsTableView.reloadData()
		splitsTableView.scrollRowToVisible(run.segmentCount - 1)
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
	
	//MARK: - Best Split
	///If `lSplit` is smaller than `rSplit`, changes the `bestSplit` in the given row of the table
	func addBestSplit(lSplit: TimeSplit, rSplit: TimeSplit, splitRow: Int) {
		if lSplit < rSplit {
			currentSplits[splitRow].bestSplit = lSplit
		} else if rSplit.timeString == TimeSplit().timeString {
			currentSplits[splitRow].bestSplit = lSplit
		}
		
	}
	///Updates the best splits for a given row in the table
	///`row` - Row in `CurrentSplits` to update
	func updateBestSplits(of row: Int) {
		let lSplit = currentSplits[row].currentSplit.tsCopy()
		let rSplit = currentSplits[row].bestSplit.tsCopy()
		addBestSplit(lSplit: lSplit, rSplit: rSplit, splitRow: row)
	}
	
	//TODO: See if it makes more sense to implement this in the split table row itself
	///Updates the "previous best " for the segment to the "best" of that segment
	func updatePreviousBestSplit(of row: Int) {
		currentSplits[row].previousBest = currentSplits[row].bestSplit.tsCopy()
	}
	
	///Updates the "previous best"  for each segment in the run to the "best" of that segment
	func updateAllPreviousBestSplits() {
		var i = 0
		while i < currentSplits.count {
			updatePreviousBestSplit(of: i)
			i = i + 1
		}
	}
	
	
	
	func updateAllBestSplits() {
		var i = 0
		while i < currentSplits.count {
			updateBestSplits(of: i)
			i = i + 1
		}
	}
	
	//MARK: - Previous Splits
	
	//TODO: See if it makes more sense to implement this in the split table row itself
	
	///Updates the "previous split"  for each segment in the run to the "current split" of that segment
	func updatePreviousSplits() {
		var i = 0
		while i < currentSplits.count {
			if currentSplits[i].currentSplit.timeString != TimeSplit().timeString {
				currentSplits[i].previousSplit = currentSplits[i].currentSplit.tsCopy()
			}
			i = i + 1
		}
	}

	
	//MARK: - Other functions
	
	/// Returns the user's best split for a given `splitNumber`. If there isn't a best split for that time, it's equal to the current split
	/// - Parameter splitNumber: The row that the split appears in the Table View
	func getBestSplit(splitNumber: Int) -> TimeSplit{
		if !currentSplits.isEmpty && splitNumber < currentSplits.count {
			return currentSplits[splitNumber].bestSplit
		} else {
			return TimeSplit(mil: 0, sec: 0, min: 0, hour: 0)
		}
	}
}
