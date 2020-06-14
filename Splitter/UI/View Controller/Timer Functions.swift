//
//  Timer Functions.swift
//  Splitter
//
//  Created by Michael Berk on 2/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController {
	// MARK: - Timer functions
	///Starts the timer.
	func startTimer() {
		timerStarted = true
		timerState = .running
		StartButton.baseTitle = "Pause"
		setupTimer()
		splitsTableView.scrollRowToVisible(currentSplitNumber)
		attempts = attempts + 1
	}
	
	///Stops/"Finshes" the timer
	func stopTimer() {
		timerStarted = false
		timerState = .stopped
		StartButton.baseTitle = "Start"
		resetTimer()
		endTime = Date()
	}
	
	///Pauses or resumes the current timer, depending on its current state.
	func pauseResumeTimer() {
		
		switch timerState {
		case .paused:
			StartButton.baseTitle = "Pause"
			currentSplit?.paused = false
			timerState = .running
			lscTimer?.resume()
		default:
			StartButton.baseTitle = "Resume"
			currentSplit?.paused = true
			timerPaused = true
			timerState = .paused
		
		}
	}
	
	
	///Sets up the timer, when it is currently stopped.
	func setupTimer() {
		var i = 0
		backupSplits = []
		while i < currentSplits.count {
			backupSplits.append(currentSplits[i].copy() as! splitTableRow)
			i = i + 1
		}
		updatePreviousSplit(of: 0)
		updateAllPreviousBestSplits()
		
//		milHundrethTimer = Cocoa.Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateMilHundreth), userInfo: nil, repeats: true)
//		RunLoop.current.add(milHundrethTimer, forMode: .common)
		refreshUITimer = Cocoa.Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
		RunLoop.current.add(refreshUITimer, forMode: .common)
		currentSplit = TimeSplit()
		
		currentSplitNumber = 0
		currentSplits[0].currentSplit = self.currentSplit!
		
		self.startTime = Date()
		
		let run = LiveSplitCore.Run()
		
		let seg = LiveSplitCore.Segment("Segment")
		run.pushSegment(seg)
		
		lscTimer = LiveSplitCore.Timer(run)
		lscTimer?.start()
	}
	
	@objc func timerInfLoop() {
		currentSplit?.updateSec(sec: lscTimer?.currentTime().realTime()?.totalSeconds() ?? 0)
			TimerLabel.stringValue = String(lscTimer?.currentTime().realTime()?.totalSeconds() ?? 0)
		
		splitsTableView.reloadData()
	}
	
	//TODO: Fix the issues mentioned below
	//TODO: Don't clear out previous; only set all to zero
	//TODO: Idea - never save 00:00:00 as "best"
	/** Clears out the current time field on all segments in the Table View
	- Warning:
		- If split is added/removed since last attempt, then previous stays the same value
			- This is because the backup array isn't the same length
			- Possible solution: Give each split an ID, and use that to update
				- Will help if I implement reordering splits in the future
			- Other solution:
				- Update backup splits when adding/removing row
		- If previous/best time is updated since last attempt, previous/best time isn't updated.
	- GOING FORWARD:
		- I want bring current splits to zero, but **don't** set PB/prev to their previous values (if the latest time was the new PB):
			- People just want it to display time as zero, and not do anything else
			- Should I reset PB if the new value (being set to zero) is the PB?
		- Fix when adding splits
			- Add new blank row to backup splits
*/
	func resetAllCurrentSplitsToZero() {
		var i = 0
		while i < currentSplits.count {
			currentSplits[i].currentSplit = TimeSplit()
			if currentSplits[i].currentSplit <= currentSplits[i].bestSplit {
				currentSplits[i].bestSplit = currentSplits[i].previousBest
			}
			if backupSplits.count == currentSplits.count {
				currentSplits[i].previousSplit = backupSplits[i].previousSplit
			}
			i = i + 1
		}
		currentSplit = TimeSplit()
		splitsTableView.reloadData()
	}
	
	
	///Prompts the user if they're *sure* they want to remove all the currently loaded segements, then calls `clearTimer()` to do so, should they choose "Yes"
	func askToClearTimer() {
		let alert = NSAlert()
		alert.messageText = "Are you sure you want to delete all segments?"
		alert.informativeText = "If you continue, you all of the segments in the file will be deleted. Other data like the run title, icon, etc. will be retained."
		alert.alertStyle = .warning
		alert.addButton(withTitle: "Cancel")
		alert.addButton(withTitle: "Delete Segments")
		alert.buttons[0].highlight(true)
		let res = alert.runModal()
		if res == NSApplication.ModalResponse.alertSecondButtonReturn {
			clearTimer()
		}
	}
	///Deletes all of the segments in the table view, leaving just one with a time of 00:00:00. Shouldn't be directly triggered by the user; use `askToClearTimer()` for that instead.
	func clearTimer() {
		milHundrethTimer.invalidate()
		refreshUITimer.invalidate()
		currentSplit = TimeSplit(mil: 0,sec: 0,min: 0,hour: 0)
		currentSplits = []
		loadedFilePath = ""


		UpdateTimer()
	}
	
	///Resets the timer to 00:00:00.
	func resetTimer() {
		milHundrethTimer.invalidate()
		refreshUITimer.invalidate()
		UpdateTimer()
	}
	
	
	@objc func updateTime() {

		if !currentSplit!.paused {
			UpdateTimer()
		}
	}
	func columnArray() -> [Int] {
		var cols: [Int] = []
		var i = 0
		while i < splitsTableView.tableColumns.count {
			cols.append(i)
			i = i + 1
		}
		return cols
	}
	///Updates the current time on the timer
	@objc func UpdateTimer() {
		if currentSplit!.paused {
			lscTimer?.pause()
		} else {
			
			currentSplit?.updateSec(sec: lscTimer?.currentTime().realTime()?.totalSeconds() ?? 0)
		}
		
		if let currentTime = currentSplit?.timeString {
			TimerLabel.stringValue = currentSplit!.timeString
		}
		//Update only the current row to ensure good performance when scrolling the tableview
		splitsTableView.reloadData(forRowIndexes: IndexSet(arrayLiteral: currentSplitNumber), columnIndexes: IndexSet(columnArray()))
		
	}
	/**
	Starts, stops, or pauses the timer, depending on the current `timerState`.
	- If the timer is currently stopped,  then it starts the timer
	- If the timer is already running, it pauses the timer
	- If the timer is currently paused, it resumes the timer
	
	This is primarily called when the user clicks on the "start/pause/resume" button
*/
	func toggleTimer() {
		if timerState == .stopped {
			startTimer()
		} else if timerState == .paused {
			//resumeTimer()
			pauseResumeTimer()
		} else if timerState == .running {
			pauseResumeTimer()
		}
	}
/**
	Starts / pauses the timer or proceeds to the next split, depending on the current `timerState`.
	- If the timer is currently stopped,  then it starts the timer
	- If the timer is already running, it proceeds to the next split
	- If the timer is currently paused, it resumes the timer
	
	This is primarily called when the "Start/Split" menu item or hotkey is used.
	*/
	func startSplitTimer() {
		if timerState == .stopped {
			startTimer()
		} else if timerState == .paused {
			pauseResumeTimer()
		} else if timerState == .running {
			goToNextSplit()
		}
	}
		
	
	@objc func updateMilHundreth() {
			self.currentSplit?.updateMil()
	}
	
	///Called when the user has finished the run.
	func finishRun() {
		///It may not look like there's a point  to this right now, but I may add other functionality when a run is finished, and it would go here in that casse
		stopTimer()
	}
}
