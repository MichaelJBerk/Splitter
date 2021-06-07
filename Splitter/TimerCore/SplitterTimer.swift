//
//  SplitterTimer.swift
//  Splitter
//
//  Created by Michael Berk on 5/3/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation

extension Notification.Name {
	///This notification is posted when the current split has changed
	static let splitChanged = Notification.Name("splitChanged")
	///When this notification is posted, the ViewController will set the document's `changeCount` to `changeDone`.
	static let updateIsEdited = Notification.Name("updateIsEdited")
}

///States that the timer can be in
enum TimerState {
	case stopped
	case running
	case paused
}

class SplitterTimer {
	var splitterRun: SplitterRun!
	var lsTimer: LSTimer
	
	var timerState: TimerState = .stopped {
		didSet {
			NotificationCenter.default.post(name: .timerStateChanged, object: self, userInfo: ["timerState": self.timerState])
		}
	}
	var lsRun: RunRef {
		return lsTimer.getRun()
	}
	init(run: Run) {
		lsTimer = LSTimer(run)!
		let ts = timerState
		timerState = ts
		self.addPhaseChangedObserver()
	}
	
	private func resetIfNeeded(update: Bool) {
		let initialPhase = lsTimer.currentPhase()
		if initialPhase == 2 {
			lsTimer.reset(update)
		}
	}
	
	func start() {
		let initialPhase = lsTimer.currentPhase()
		resetIfNeeded(update: true)
		lsTimer.start()
		let newPhase = lsTimer.currentPhase()
		splitterRun.updateLayoutState()
		if newPhase == 1 && initialPhase != 1 {
			NotificationCenter.default.post(.init(name: .phaseChanged, object: nil, userInfo: ["phase": newPhase, "oldPhase": initialPhase]))
		}
		NotificationCenter.default.post(name: .updateIsEdited, object: self, userInfo: nil)
	}
	func splitOrStart() {
		/// - Note: If there's a negative offset, and the time < 0, then it won't be counted as having "ended" for some reason
		let initialPhase = lsTimer.currentPhase()
		resetIfNeeded(update: true)
		lsTimer.splitOrStart()
		splitterRun.updateLayoutState()
		let newPhase = lsTimer.currentPhase()
		NotificationCenter.default.post(.init(name: .phaseChanged, object: nil, userInfo: ["phase": newPhase, "oldPhase": initialPhase]))
		NotificationCenter.default.post(name: .splitChanged, object: nil, userInfo: ["current": currentSplit as Any])
	}
	func togglePause() {
		let initialPhase = lsTimer.currentPhase()
		lsTimer.togglePause()
		splitterRun.updateLayoutState()
		let newPhase = lsTimer.currentPhase()
		NotificationCenter.default.post(.init(name: .phaseChanged, object: nil, userInfo: ["phase": newPhase, "oldPhase": initialPhase]))
	}
	func previousSplit() {
		lsTimer.undoSplit()
		splitterRun.updateLayoutState()
	}
	
	var currentSplit: Int? {
		let index = Int(lsTimer.currentSplitIndex())
		let len = lsTimer.getRun().len()
		if index < 0 || index >= len {
			return nil
		}
		return index
	}
	
	///
	///- NOTE: If it's the last split, it can't be skipped
	func skipSplit() {
		lsTimer.skipSplit()
		splitterRun.updateLayoutState()
//		NotificationCenter.default.post(name: .splitChanged, object: nil, userInfo: ["current": currentSplit as Any])
	}

	
	//TODO: Figure out how resetting run should behave
	///Resets the current run
	/// - Parameter discardSplits: `true` if the current splits are to be discarded, `false` if they are to be kept. Defaults to `false`
	func resetRun(discardSplits: Bool = false) {
		lsTimer.reset(!discardSplits)
		splitterRun.updateLayoutState()
		NotificationCenter.default.post(name: .splitChanged, object: nil, userInfo: ["current": currentSplit as Any])
	}
	
	func resetHistories() {
		var customComparisons = [String]()
		let run = lsTimer.getRun().clone()
		let compsLen = run.customComparisonsLen()
		for i in 0..<compsLen {
			customComparisons.append(run.customComparison(i))
		}
		if let editor = RunEditor(run) {
			editor.clearTimes()
			for i in 0..<customComparisons.count {
				_ = editor.addComparison(customComparisons[i])
			}
			_  = lsTimer.setRun(editor.close())
		}
	}
	
	private func addPhaseChangedObserver() {
		NotificationCenter.default.addObserver(forName: .phaseChanged, object: nil, queue: nil, using: { notification in
			let old: Int = Int(notification.userInfo!["oldPhase"] as! UInt8)
			let phase: Int = Int(notification.userInfo!["phase"] as! UInt8)
			if phase == 2 {
				self.timerState = .stopped
			}
			if phase == 1 && old != 1 {
				self.timerState = .running
			}
			if phase == 3 && old != 3 {
				self.timerState = .paused
			}
			
		})
	}
	
}
