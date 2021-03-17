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
	//MARK: - Split Navigation
	///Moves the timer to the next split, or finishes the run if the current split is the last.
	func goToNextSplit() {
		run.timer.splitOrStart()
//		if timerStarted {
//			updateBestSplits(of: currentSplitNumber)
//			if currentSplits.count > currentSplitNumber + 1 {
//
//				updatePreviousSplit(of: currentSplitNumber + 1)
//				let currentSplitCopy = self.currentSplit?.copy() as! TimeSplit
//				currentSplits[currentSplitNumber].currentSplit = currentSplitCopy
//				currentSplitNumber += 1
//				currentSplits[currentSplitNumber].currentSplit = self.currentSplit!
//				splitsTableView.scrollRowToVisible(currentSplitNumber)
//			} else {
//				//If it's at the last split, then stop the timer.
//				stopTimer()
//			}
//		}
		//Need to reload the entire table view so that the hightlighted row in the table view will update
		//Since this only happens when advancing to the next split, it shouldn't affect scrolling performance
		splitsTableView.reloadData()
		
	}
	///Moves the timer to the previous split, or restarts the run if the current split is the first
	func goToPrevSplit() {
		run.timer.previousSplit()
		splitsTableView.reloadData()
//		if timerStarted {
//			if currentSplitNumber > 0 {
//				currentSplits[currentSplitNumber - 1].currentSplit = currentSplit!
//				currentSplits.replaceSubrange(currentSplitNumber...currentSplitNumber, with: [backupSplits[currentSplitNumber]])
//				currentSplitNumber = currentSplitNumber - 1
//
//				self.currentSplit = currentSplits[currentSplitNumber].currentSplit
//				splitsTableView.reloadData()
//
//			} else if currentSplitNumber == 0 {
//				self.currentSplit = TimeSplit(mil: 0, sec: 0, min: 0, hour: 0)
//				currentSplits[0].currentSplit = self.currentSplit!
//				splitsTableView.reloadData()
//			}
//		}
	}
	
	//MARK: - Adding and Removing Splits
	//TODO: Make this remove a split given its index instead of the last one
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
	
	//TODO: See if all I need is addBlankSplit()
	///Adds a new split to the table view, if the timer hasn't started yet.
	func addSplit() {
		run.addSegment(title: "new")
		splitsTableView.reloadData()
	}
	
	//TODO: May not be availiable in LiveSplit-Core
	///Resets the current split to the time of the previous split, or resets the run if the current split is the last
	func resetCurrentSplit() {
		if currentSplitNumber > 0 {
			let lastSplit = currentSplits[currentSplitNumber - 1]
			currentSplits[currentSplitNumber].currentSplit = lastSplit.currentSplit
			currentSplits[currentSplitNumber - 1].currentSplit = lastSplit.currentSplit.tsCopy()
			currentSplit = currentSplits[currentSplitNumber].currentSplit
		} else {
			resetRun()
		}
		
	}
	
	///Resets a run in progress to 00:00:00.
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
	///`row` - Row in `CurrentSplits` to update
	///Updates the best splits for a given row in the table
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
