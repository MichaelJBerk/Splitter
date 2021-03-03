//
//  TimerCore.swift
//  Splitter
//
//  Created by Michael Berk on 3/2/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Notification.Name {
	static let phaseChanged = Notification.Name("timerPhaseChanged")
}


class SplitterRun: NSObject {
	//var splits
	//var currenttime
	var layout: Layout
	var timer: SplitterTimer
	var runPtr: UnsafeMutableRawPointer?
	var codableLayout: CLayout!
	var runString: String?
	var refreshTimer: Timer?
	
	
	init(run: Run, segments: [SplitTableRow]? = nil) {
		//need to have at least one segment
		run.pushSegment(Segment("1"))
		
		self.runPtr = run.ptr
		self.timer = SplitterTimer(run: run)
		self.layout = .defaultLayout()
		
		if let editor = LayoutEditor(layout) {
			editor.select(1)
			//Include all splits in layout
			editor.setComponentSettingsValue(1, .fromUint(0))
			self.layout = editor.close()
		}
		do {
			codableLayout = try JSONDecoder().decode(CLayout.self, from: layout.stateAsJson(timer.lsTimer).data(using: .utf8)!)
			
		} catch {
			print("Decode Error: \n\(error)")
		}
		super.init()
		setObservers()
	}
	
	private func setObservers() {
		NotificationCenter.default.addObserver(forName: .phaseChanged, object: nil, queue: nil, using: { [weak self] notification in
			let old: Int = Int(notification.userInfo!["oldPhase"] as! UInt8)
			let phase: Int = Int(notification.userInfo!["phase"] as! UInt8)
			if phase == 2, old == 1 {
				self!.endTimer()
			}
			if phase == 1, old != 1 {
				self!.startTimer()
			}
		})
	}

	private func startTimer() {
		refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { timer in
			self.updateLayoutFromJson()
		})
	}
	private func endTimer() {
		refreshTimer?.invalidate()
		refreshTimer = nil
	}
	
	var attempts: Int {
		get {
			let aCount = timer.lsTimer.getRun().attemptCount()
			return Int(aCount)
		}
		set {
			editRun{
				_ = $0.parseAndSetAttemptCount("\(newValue)")
			}
		}
	}
	var title: String {
		get {
			timer.lsTimer.getRun().gameName()
		}
		set {
			editRun {$0.setGameName(newValue)}
		}
	}
	var subtitle: String {
		get {
			timer.lsTimer.getRun().categoryName()
		}
		set {
			editRun {$0.setCategoryName(newValue)}
		}
	}
	var segmentCount: Int {
		timer.lsTimer.getRun().len()
	}
	
	
	func editRun(_ edit: (RunEditor) -> ()) {
		let timerRun = timer.lsTimer.getRun()
		var newLSRun = timerRun.clone()
		if let editor = RunEditor(newLSRun) {
			edit(editor)
			newLSRun = editor.close()
			_ = timer.lsTimer.setRun(newLSRun)
		}
	}
	
	func addSegment(segment: SplitTableRow) {
		let timerRun = timer.lsTimer.getRun()
		var newLSRun = timerRun.clone()
		if let editor = RunEditor(newLSRun) {
			editor.selectOnly(timerRun.len() - 1)
			editor.insertSegmentBelow()
			editor.activeSetName(segment.splitName)
			_ = editor.activeParseAndSetSplitTime(segment.currentSplit.timeString)
			editor.setGameName("laaaaa")
			newLSRun = editor.close()
			_ = timer.lsTimer.setRun(newLSRun)
		}
		updateLayoutFromJson()
	}
	func updateLayoutFromJson() {
		
		let state = layout.state(timer.lsTimer)
		let refMutState = LayoutStateRefMut(ptr: state.ptr)
		let json = layout.updateStateAsJson(refMutState, timer.lsTimer)
		let jData = json.data(using: .utf8)
		do {
			codableLayout = try JSONDecoder().decode(CLayout.self, from: jData!)
		} catch {
			print("Decode Error:\n \(error)")
		}
	}
	
	func updateLayoutToJson() {
		let encoder = JSONEncoder()
		do {
			let jData = try encoder.encode(codableLayout)
			let jString = String(data: jData, encoding: .utf8)
			if let newLayout = Layout.parseJson(jString!) {
				self.layout = newLayout
			}
		} catch {
			print("Encode Error:\n \(error)")
		}
	}
	
	func setSegTitle(index: Int, title: String) {
		var timerRun = timer.lsTimer.getRun()
		var newLSRun = timerRun.clone()
		
		if let editor = RunEditor(newLSRun) {
			editor.selectOnly(index)
			editor.activeSetName(title)
			
			newLSRun = editor.close()
			_ = timer.lsTimer.setRun(newLSRun)
		}
	}
	
}
class SplitterTimer {
	var lsTimer: LSTimer
	var lsRun: Run
	init(run: Run) {
		self.lsRun = run
		lsTimer = LSTimer(run)!
	}
	
	private func resetIfNeeded(update: Bool) {
		let initialPhase = lsTimer.currentPhase()
		if initialPhase == 2 {
			lsTimer.reset(update)
			let a = lsTimer.getRun().attemptCount()
			print(a)
		}
	}
	
	func start() {
		let initialPhase = lsTimer.currentPhase()
		resetIfNeeded(update: true)
		lsTimer.start()
		let newPhase = lsTimer.currentPhase()
		if newPhase == 1 && initialPhase != 1 {
			NotificationCenter.default.post(.init(name: .phaseChanged, object: nil, userInfo: ["phase": newPhase, "oldPhase": initialPhase]))
		}
	}
	func splitOrStart() {
		/// - Note: If there's a negative offset, and the time < 0, then if won't be counted as having "ednqed" for some reason;
		let initialPhase = lsTimer.currentPhase()
		resetIfNeeded(update: true)
		lsTimer.splitOrStart()
		let newPhase = lsTimer.currentPhase()
		NotificationCenter.default.post(.init(name: .phaseChanged, object: nil, userInfo: ["phase": newPhase, "oldPhase": initialPhase]))
	}
	
}
