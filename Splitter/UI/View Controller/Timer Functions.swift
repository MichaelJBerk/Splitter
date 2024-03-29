//
//  Timer Functions.swift
//  Splitter
//
//  Created by Michael Berk on 2/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

extension Notification.Name {
	
	static let startTimer = Notification.Name("startTimer")
	static let stopTimer = Notification.Name("stopTimer")
}

extension ViewController {
	// MARK: - Timer functions
	///Starts the timer.
	func startTimer() {
		timerStarted = true
		timerState  = .running
		setupTimer()
		updateTextFields()
		splitsTableView.scrollRowToVisible(run.currentSplit ?? 0)
	}
	
	///Finshes the timer at the end of a run
	///
	///- NOTE: This method is also called when the run is first loaded
	func stopTimer() {
		timerStarted = false
		if timerState != .stopped {
			timerState = .stopped
		}
		resetTimer()
		run.updateLayoutState()
		splitsTableView.reloadData()
	}
	
	///Pauses or resumes the current timer, depending on its current state.
	func pauseResumeTimer() {
		switch timerState {
		case .paused:
			currentSplit?.paused = false
			timerState = .running
		default:
			currentSplit?.paused = true
			timerPaused = true
			timerState = .paused
		}
		run.timer.togglePause()
	}
	
	
	/// Sets up various properties of the timer, as well as dealing with LiveSplitCore to start timing.
	///
	/// This function does the grunt work of refreshing the UI timer, setting up LiveSplitCore to to time the run, etc. If all you need to do is start the timer, call `startTimer()` instead.
	private func setupTimer() {
		undoManager?.disableUndoRegistration()
		self.document.updateChangeCount(.changeDone)
		NotificationCenter.default.post(name: .startTimer, object: self.run)
		run.timer.start()
		
		self.updateButtonTitles()
		//Using reloadData to update the highlighted row in the tableview
		splitsTableView.reloadData()
	}
	//TODO: Figure out how to handle resetting
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
			//TODO: Something...
		}
	}
	
	///Resets the timer to 00:00:00.
	func resetTimer() {
		milHundrethTimer.invalidate()
		NotificationCenter.default.post(.init(name: .stopTimer, object: self.run))
		updateTimer()
	}
	
	
	func columnArray() -> [Int] {
		var cols: [Int] = []
		var i = 0
		while i < splitsTableView.tableColumns.count {
			let id = splitsTableView.tableColumns[i].identifier
			if !(id == STVColumnID.imageColumn || id == STVColumnID.splitTitleColumn) {
				cols.append(i)
			}
			i = i + 1
		}
		return cols
	}
	///Updates the current time on the timer
	@objc func updateTimer() {
		if let timer = (run.codableLayout.components[2] as? CTimer) {
			timerLabel.stringValue = timer.timeText
			touchBarTotalTimeLabel.stringValue = timer.timeText
		}
		
		//Update only the current row to ensure good performance when scrolling the tableview
		if let index = run.currentSplit {
			splitsTableView.reloadData(forRowIndexes: IndexSet(arrayLiteral: index), columnIndexes: IndexSet(columnArray()))
		}
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
		} else if timerState == .running {
			run.timer.splitOrStart()
		}
	}
	
	func cancelRun() {
		run.timer.resetRun(discardSplits: true)
//		self.document.undoManager?.disableUndoRegistration()
//		run.attempts = run.attempts - 1
//		self.document.undoManager?.enableUndoRegistration()r
		//Prevent run from appearing "Edited" if it wasn't edited before being cancelled
//		print("docChanges: \(self.document.changecount)")
//		self.document.updateChangeCount(.changeUndone)
		stopTimer()
	}
}
