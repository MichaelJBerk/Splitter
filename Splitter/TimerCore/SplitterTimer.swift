//
//  SplitterTimer.swift
//  Splitter
//
//  Created by Michael Berk on 5/3/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation
class SplitterTimer {
	var splitterRun: SplitterRun!
	var lsTimer: LSTimer
	var lsRun: RunRef {
		return lsTimer.getRun()
	}
	init(run: Run) {
		lsTimer = LSTimer(run)!
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
	}
	func splitOrStart() {
		/// - Note: If there's a negative offset, and the time < 0, then it won't be counted as having "ended" for some reason
		let initialPhase = lsTimer.currentPhase()
		resetIfNeeded(update: true)
		lsTimer.splitOrStart()
		splitterRun.updateLayoutState()
		let newPhase = lsTimer.currentPhase()
		NotificationCenter.default.post(.init(name: .phaseChanged, object: nil, userInfo: ["phase": newPhase, "oldPhase": initialPhase]))
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

	
	//TODO: Figure out how resetting run should behave
	///Resets the current run
	/// - Parameter discardSplits: `true` if the current splits are to be discarded, `false` if they are to be kept. Defaults to `false`
	func resetRun(discardSplits: Bool = false) {
		lsTimer.reset(!discardSplits)
		splitterRun.updateLayoutState()
//		if let s = splitterRun.codableLayout.components[1].splits?.splits[0] {
//			for i in 0..<s.columns.count {
//				print(s.columns[i].value)
//
//			}
//		}
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
	
}
