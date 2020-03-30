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
		StartButton.title = "Pause"
		setupTimer()
		splitsTableView.scrollRowToVisible(currentSplitNumber)
		attempts = attempts + 1
	}
	
	///Stops/"Finshes" the timer
	func stopTimer() {
		timerStarted = false
		timerState = .stopped
		StartButton.title = "Start"
		resetTimer()
		endTime = Date()
	}
	
	///Pauses or resumes the current timer, depending on its current state.
	func pauseResumeTimer() {
		
		switch timerState {
		case .paused:
			StartButton.title = "Pause"
			currentSplit?.paused = false
			timerState = .running
		default:
			StartButton.title = "Resume"
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
		
		milHundrethTimer = Cocoa.Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateMilHundreth), userInfo: nil, repeats: true)
		RunLoop.current.add(milHundrethTimer, forMode: .common)
		refreshUITimer = Cocoa.Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
		RunLoop.current.add(refreshUITimer, forMode: .common)
		
		
		//lsc: milHundrethTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateMilHundreth), userInfo: nil, repeats: true)
		
		
		
//		refreshUITimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
		currentSplit = TimeSplit()
		
		currentSplitNumber = 0
		currentSplits[0].currentSplit = self.currentSplit!
		
		self.startTime = Date()
		
		let lsc = LiveSplitCore.self
		let run = LiveSplitCore.Run()
		let seg = LiveSplitCore.Segment("Segment")
		run.pushSegment(seg)
		//lsc:
//		lscTimer = lsc.Timer(run)
//		lscTimer?.start()

		
		
	}
	
	///Clears out the current time field on all segments in the Table View
	func resetAllCurrentSplitsToZero() {
		var i = 0
		while i < currentSplits.count {
			currentSplits[i].currentSplit = TimeSplit(timeString: "00:00:00.00")
			splitsTableView.reloadData()
			i = i + 1
		}
	}
	
	
	///Prompts the user if they're *sure* they want to remove all the currently loaded segements, then calls `clearTimer()` to do so, should they choose "Yes"
	func askToClearTimer() {
		let alert = NSAlert()
		alert.messageText = "Are you sure you want to reset?"
		alert.informativeText = "By clicking \"Yes\", you will remove all of the currently loaded segments."
		alert.alertStyle = .warning
		alert.addButton(withTitle: "No")
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
	
	///Updates the current time on the timer
	func UpdateTimer() {
		if let currentTime = currentSplit?.timeString {
			TimerLabel.stringValue = String(currentSplit!.timeString)//currentTime
		}
		splitsTableView.reloadData()
		
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
		
//		let cTimeString = timer?.currentTime()
//		currentSplit?.updateMil()
		
//		TimerLabel.stringValue = currentSplit?.timeString
//		if let currentTime = currentSplit?.timeString {
//			TimerLabel.stringValue = currentTime
//		}
		
//
//		//lsc:
//		if let currentTimer = lscTimer?.currentTime().realTime()?.totalSeconds() {
//			let timeInt = Int(currentTimer * 100)
//
//			TimerLabel.stringValue = timeInt.toFormatedTimeString()
//		}
//		DispatchQueue.global(qos: .background).async {
			self.currentSplit?.updateMil()
//		}
		
		
		
	
//		splitsTableView.reloadData()
	}
	
	///Called when the user has finished the run.
	func finishRun() {
		///It may not look like there's a point  to this right now, but I may add other functionality when a run is finished, and it would go here in that casse
		stopTimer()
	}
}
