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
		if timerStarted {
			updateBestSplits(of: currentSplitNumber)
			if currentSplits.count > currentSplitNumber + 1 {
				let currentSplitCopy = self.currentSplit?.copy() as! TimeSplit
				currentSplits[currentSplitNumber].currentSplit = currentSplitCopy
				currentSplitNumber += 1
				currentSplits[currentSplitNumber].currentSplit = self.currentSplit!
				splitsTableView.scrollRowToVisible(currentSplitNumber)
			} else {
				//If it's at the last split, then stop the timer.
				stopTimer()
			}
			
		}
	}
	///Moves the timer to the previous split, or restarts the run if the current split is the first
	func goToPrevSplit() {
		if timerStarted {
			if currentSplitNumber > 0 {
				currentSplits[currentSplitNumber].currentSplit = TimeSplit(mil: 0)
				currentSplits[currentSplitNumber].bestSplit = currentSplits[currentSplitNumber].bestSplit.copy() as! TimeSplit
				currentSplitNumber -= 1
				currentSplits[currentSplitNumber].currentSplit = self.currentSplit!
			} else if currentSplitNumber == 0 {
				self.currentSplit = TimeSplit(mil: 0, sec: 0, min: 0, hour: 0)
				currentSplits[0].currentSplit = self.currentSplit!
				splitsTableView.reloadData()
			}
		}
	}
	
	//MARK: - Adding and Removing Splits
	//TODO: Make this remove a split given its index instead of the last one
	func removeSplits() {
		let oldSplitsCount = currentSplits.count
		if oldSplitsCount > 1 {
			currentSplits.removeLast()
			splitsTableView.reloadData()
		}
		else if oldSplitsCount == 1{
			currentSplits.removeLast()
			addSplit()
			splitsTableView.reloadData()
		}
	}
	
	///Adds a blank split to the table view
	func addBlankSplit() {
		let blankSplitNumber = currentSplits.count + 1
		let blankSplit = TimeSplit(mil: 0, sec: 0, min: 0, hour: 0)
		let blankTableRow = splitTableRow(splitName: "\(blankSplitNumber)", bestSplit: blankSplit, currentSplit: blankSplit, previousSplit: blankSplit, previousBest: blankSplit, splitIcon: nil)
		currentSplits.append(blankTableRow)
		splitsTableView.reloadData()
		
	}
	
	//TODO: See if all I need is addBlankSplit()
	///Adds a new split to the table view, if the timer hasn't started yet.
	func addSplit() {
		var newSplit: TimeSplit
		var bestSplit: TimeSplit
		if !timerStarted {
		
			newSplit = TimeSplit(mil: 0, sec: 0, min: 0, hour: 0)
			bestSplit = TimeSplit(mil: 0, sec: 0, min: 0, hour: 0)
		} else {
			let currentSplitCopy = self.currentSplit?.copy() as! TimeSplit
			
			let currentLastRow = currentSplits.last
			let rowNum = currentSplits.count
			let bestSplitCopy = getBestSplit(splitNumber: rowNum).copy() as! TimeSplit
			
			//TODO: Only add to "best Splits" if it's a "better" split. Requires methods for comparing TimeSplits

			let newLastRow = splitTableRow(splitName: currentLastRow!.splitName, bestSplit: bestSplitCopy, currentSplit: currentSplitCopy, previousSplit: currentLastRow!.previousSplit, previousBest: currentLastRow!.previousBest)
			currentSplits.removeLast()
			currentSplits.append(newLastRow)
			newSplit = currentSplit!
		}

		currentSplits.append(splitTableRow(splitName: String(currentSplits.count + 1), bestSplit: newSplit.copy() as! TimeSplit, currentSplit: newSplit, previousSplit: newSplit.tsCopy(), previousBest: newSplit.tsCopy()))
		splitsTableView.reloadData()
	}
	
	///Resets the current split to the time of the previous split, or resets the run if the current split is the last
	func resetCurrentSplit() {
		if currentSplitNumber > 0 {
			let lastSplit = currentSplits[currentSplitNumber - 1]
			currentSplits[currentSplitNumber] = lastSplit
			currentSplits[currentSplitNumber - 1].currentSplit = lastSplit.currentSplit.tsCopy()
			currentSplit = currentSplits[currentSplitNumber].currentSplit
		} else {
			resetRun()
		}
		
	}
	
	///Resets a run in progress to 00:00:00.
	func resetRun() {
		stopTimer()
		startTimer()
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
	
	func updateAllBestSplits() {
		var i = 0
		while i < currentSplits.count {
			updateBestSplits(of: i)
			i = i + 1
		}
	}

	
	//MARK: - Other functions
	
	/// Returns the user's best split for a given `splitNumber`. If there isn't a best split for that time, it's equal to the current split
	/// - Parameter splitNumber: The row that the split appears in the Table View
	func getBestSplit(splitNumber: Int) -> TimeSplit{
		
//		var bestSplit: TimeSplit
//		if bestSplits.count - 2 < splitNumber {
//			bestSplit = currentSplit!
//		} else {
//			bestSplit = bestSplits[splitNumber]
//		}
		if !currentSplits.isEmpty && splitNumber < currentSplits.count {
			return currentSplits[splitNumber].bestSplit
		} else {
			return TimeSplit(mil: 0, sec: 0, min: 0, hour: 0)
		}
	}
}
