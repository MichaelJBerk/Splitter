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
	var layout: Layout
	var timer: SplitterTimer
	var runPtr: UnsafeMutableRawPointer?
	var codableLayout: CLayout!
	var runString: String?
	var refreshTimer: Timer?
	
	///Used to prevent crash with numberOfRowsInTableView
	var hasSetLayout = false
	
	private var layoutSettings: CodableLayoutSettings!
	init(run: Run, segments: [SplitTableRow]? = nil) {
		//LiveSplit-Core runs need to have at least one segment
		var vRun: Run = run
		vRun.pushSegment(Segment("1"))
		if let editor = RunEditor(vRun) {
			_ = editor.addComparison(LSComparison.latest.rawValue)
			vRun = editor.close()
		}
		for i in 0..<vRun.customComparisonsLen() {
			let comp = vRun.customComparison(i)
			print(comp)
		}
		self.runPtr = vRun.ptr
		self.timer = SplitterTimer(run: vRun)
		timer.lsTimer.switchToNextComparison()
		self.layout = .defaultLayout()
		self.layout.updateState(self.layout.state(timer.lsTimer), timer.lsTimer)
		let settings = layout.settingsAsJson()
		do {
			self.layoutSettings = try JSONDecoder().decode(CodableLayoutSettings.self, from: settings.data(using: .utf8)!)
		} catch {
			print("Decode error: \(error)")
		}
		if let editor = LayoutEditor(layout) {
			/**
			# General Layout Settings
			0: Layout Direction
			1: Custom Timer Font
			2: Custom Times Font
			3: Custom Text Font
			4: Background
			5: Best Segment
			6: Ahead (Gaining Time)
			7: Ahead (Losing Time)
			8: Behind (Gaining Time)
			9: Behind (Losing Time)
			10: Not Running
			11: Personal Best
			12: Paused
			13: Thin Separators
			14: Separators
			15: Text
			*/
			
			editor.select(1)
			//Include all splits in layout
			editor.setComponentSettingsValue(1, .fromUint(0))
			
			editor.setComponentSettingsValue(10, .fromUint(4))
			editor.setComponentSettingsValue(9, .fromBool(true))
			
			//Setup Diffs Column
			
			editor.setColumn(1, updateWith: ColumnUpdateWith.segmentDelta)
			editor.setColumn(1, updateTrigger: ColumnUpdateTrigger.onStartingSegment)
			
			//Setup PB column
			editor.setColumn(2, name: "PB")
			editor.setColumn(2, comparison: "Personal Best")
			editor.setColumn(2, startWith: .comparisonTime)
			editor.setColumn(2, updateWith: ColumnUpdateWith.dontUpdate)
			editor.setColumn(2, updateTrigger: ColumnUpdateTrigger.onEndingSegment)
			
			//Setup Previous column
			editor.setColumn(3, name: "previous")
			editor.setColumn(3, comparison: "Latest Run")
			editor.setColumn(3, startWith: ColumnStartWith.comparisonTime)
			editor.setColumn(3, updateWith: ColumnUpdateWith.dontUpdate)
			editor.setColumn(3, updateTrigger: ColumnUpdateTrigger.onStartingSegment)
			//TODO: Set rounding
			
			/**
			- NOTE: Settings for Splits component:
			0 :  Background
			1 :  Total Splits
			2 :  Upcoming Splits
			3 :  Show Thin Separators
			4 :  Show Separator Before Last Split
			5 :  Always Show Last Split
			6 :  Fill with Blank Space if Not Enough Splits
			7 :  Display 2 Rows
			8 :  Current Split Gradient
			9 :  Show Column Labels
			10:  Columns
			- Indices from 11 onwards are each column's settings.
				- The next column's settings are right after the previous one - i.e. column 2 starts at 17.
			
			#Column Settings
			11:  Column Name
			12:  Start With
			13:  Update With
			14:  Update Trigger
			15:  Comparison
			16:  Timing Method
			
			
			- NOTE: Must have column labels on to set column names
			**/
			
			
			self.layout = editor.close()
		}
		do {
			let json = layout.stateAsJson(timer.lsTimer)
			codableLayout = try JSONDecoder().decode(CLayout.self, from: json.data(using: .utf8)!)
		} catch {
			print("Decode Error: \n\(error)")
		}
		super.init()
		self.timer.splitterRun = self
		setObservers()
		setComparison(to: .latest)
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
			self.updateLayoutState()
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
	
	var platform: String {
		get {
			timer.lsTimer.getRun().metadata().platformName()
		}
		set {
			editRun { editor in
				editor.setPlatformName(newValue)
			}
		}
	}
	var region: String {
		get {
			timer.lsTimer.getRun().metadata().regionName()
		}
		set {
			editRun { editor in
				editor.setRegionName(newValue)
			}
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
	
	func addSegment(title: String) {
		let timerRun = timer.lsTimer.getRun()
		var newLSRun = timerRun.clone()
		if let editor = RunEditor(newLSRun) {
			editor.selectOnly(timerRun.len() - 1)
			editor.insertSegmentBelow()
			editor.activeSetName(title)
			newLSRun = editor.close()
			_ = timer.lsTimer.setRun(newLSRun)
		}
		updateLayoutState()
	}
	func removeSegment(_ index: Int) {
		editRun { editor in
			editor.selectOnly(index)
			editor.removeSegments()
		}
	}
	func removeBottomSegment() {
		let run = timer.lsTimer.getRun()
		let len = run.len()
		removeSegment(len - 1)
		updateLayoutState()
	}
	
	func icon(for segment: Int) -> NSImage? {
		let run = timer.lsTimer.getRun()
		let seg = run.segment(segment)
		let image = LiveSplit.parseImageFromLiveSplit(ptr: seg.iconPtr(), len: seg.iconLen())
		return image
	}
	func setIcon(for segment: Int, image: NSImage?) {
		editRun({ editor in
			editor.selectOnly(segment)
			if let image = image {
				image.toLSImage { ptr, len in
					editor.activeSetIcon(ptr, len)
				}
			} else {
				editor.activeRemoveIcon()
			}
		})
		
	}
	//TODO: Implement this in the game icon button
	//why?
	var gameIcon: NSImage? {
		get {
			let run = timer.lsTimer.getRun()
			let ptr = run.gameIconPtr()
			let len = run.gameIconLen()
			return LiveSplit.parseImageFromLiveSplit(ptr: ptr, len: len)
		}
		set {
			editRun { editor in
				if let image = newValue {
					image.toLSImage { ptr, len in
						editor.setGameIcon(ptr, len)
					}
				} else {
					editor.activeRemoveIcon()
				}
			}
		}
	}
	
	///Updates CodableLayout to be
	func updateLayoutState() {
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
	
	///Updates layout from codableLayout
	func updateFromCodableLayout() {
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
	
	//TODO: Set current comparison
	func setComparison(_ comparison: String) {
//		timer.lsRun.customComparisonsLen()
		if !comparisons.contains(comparison) {
			editRun { editor in
				_ = editor.addComparison(comparison)
			}
		}
		while timer.lsTimer.currentComparison() != comparison {
			timer.lsTimer.switchToNextComparison()
		}
		
	}
	func setComparison(to comparison: LSComparison) {
		setComparison(comparison.rawValue)
	}
	
	func getComparision() -> LSComparison {
		//TODO: Handle if custom comparison?
		return LSComparison(rawValue: timer.lsTimer.currentComparison())!
	}
	
	var comparisons: [String] {
		let runCopy = timer.lsRun.clone()
		let newTimer = LSTimer(runCopy)!
		
		let originalComparison = newTimer.currentComparison()
		var currentComparison: String = originalComparison
		var comparisons = [String]()
		newTimer.switchToNextComparison()
		currentComparison = newTimer.currentComparison()
		
		while originalComparison != currentComparison {
			comparisons.append(currentComparison)
			newTimer.switchToNextComparison()
			currentComparison = newTimer.currentComparison()
			
		}
		
//		for i in 0..<2 {
//
//			comparisons.append(newTimer.currentComparison())
//			newTimer.switchToNextComparison()
//		}
		return comparisons
	}
	
	
	///Set the title for a given segment
	func setSegTitle(index: Int, title: String) {
		timer.resetRun(discardSplits: false)
		updateLayoutState()
		let timerRun = timer.lsTimer.getRun()
		var newLSRun = timerRun.clone()
		
		if let editor = RunEditor(newLSRun) {
			editor.selectOnly(index)
			editor.activeSetName(title)
			
			newLSRun = editor.close()
			_ = timer.lsTimer.setRun(newLSRun)
		}
		updateLayoutState()
	}
	
	var layoutSplits: CSplits {
		codableLayout.components[1].splits!
	}
	
	var currentSplit: Int? {
		let index = Int(timer.lsTimer.currentSegmentIndex())
		let len = timer.lsTimer.getRun().len()
		if index < 0 || index >= len {
			return nil
		}
		return index
	}
	
	func editLayout(_ edit: (LayoutEditor) -> ()) {
		if let editor = LayoutEditor(layout) {
			edit(editor)
			self.layout = editor.close()
			self.updateLayoutState()
		}
	}
	
	var longerColor: NSColor {
		get {
			let editor = LayoutEditor(layout)
			let color = editor!.state().fieldValue(false, 8).toColor()!
			layout = editor!.close()
			return color
			
		}
		set {
			let color = [Float(newValue.redComponent), Float(newValue.greenComponent), Float(newValue.blueComponent), Float(newValue.alphaComponent)]
			if let editor = LayoutEditor(layout) {
				editor.setGeneralSettingsValue(8, SettingValue.fromColor(color[0], color[1], color[2], color[3]))
				editor.setGeneralSettingsValue(9, SettingValue.fromColor(color[0], color[1], color[2], color[3]))
				self.layout = editor.close()
			}
		}
	}
	var shorterColor: NSColor {
		get {
			let editor = LayoutEditor(layout)
			let color = editor!.state().fieldValue(false, 6).toColor()!
			layout = editor!.close()
			return color
		}
		set {
			let color = [Float(newValue.redComponent), Float(newValue.greenComponent), Float(newValue.blueComponent), Float(newValue.alphaComponent)]
			if let editor = LayoutEditor(layout) {
				editor.setGeneralSettingsValue(6, SettingValue.fromColor(color[0], color[1], color[2], color[3]))
				editor.setGeneralSettingsValue(7, SettingValue.fromColor(color[0], color[1], color[2], color[3]))
				self.layout = editor.close()
			}
		}
		
	}
	
	var backgroundColor: NSColor {
		get {
			if let doubles = codableLayout.background.asPlainColor() {
				return NSColor(doubles)
			}
			return NSColor.splitterDefaultColor
		}
		set {
			if let layoutEditor = LayoutEditor(layout) {
				let doubles = newValue.toDouble().map({Float($0)})
				let setting = SettingValue.fromColor(doubles[0], doubles[1], doubles[2], doubles[3])
				layoutEditor.setGeneralSettingsValue(4, setting)
				self.layout = layoutEditor.close()
			}
		}
	}
	var tableColor: NSColor {
		get {
			let state = layout.stateAsJson(timer.lsTimer)
			print(state)
			if let doubles = codableLayout.components[1].splits?.background.asPlainColor() {
				return NSColor(doubles)
			}
			return .splitterTableViewColor
		}
		set {
			editLayout { editor in
				editor.select(1)
				editor.setComponentSettingsValue(0, .fromAlternatingNSColor(newValue, newValue))
			}
		}
	}
	
	var textColor: NSColor {
		get {
			let doubles = codableLayout.textColor
			return NSColor(doubles)
		}
		set {
			editLayout{ editor in
				let setting = SettingValue.fromNSColor(newValue)
				editor.setGeneralSettingsValue(15, setting)
			}
		}
	}
	
	func saveToLSS() -> String {
		timer.lsTimer.saveAsLss()
	}
	func layoutToJSON() -> String {
		layout.settingsAsJson()
	}
	func setRun(_ run: Run) {
		_ = timer.lsTimer.setRun(run)
	}
}
class SplitterTimer {
	fileprivate var splitterRun: SplitterRun!
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
		/// - Note: If there's a negative offset, and the time < 0, then if won't be counted as having "ednqed" for some reason;
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
enum LSComparison: String, CaseIterable {
	///Defines the Comparison Generator for calculating the Average Segments of a Run. The Average Segments are calculated through a weighted arithmetic mean that gives more recent segments a larger weight so that the Average Segments are more suited to represent the current performance of a runner.
	case averageSegments = "Average Segments"
	///Defines the Comparison Generator for calculating the Latest Run. Using the Segment History, this comparison reconstructs the splits of the furthest, most recent attempt. If at least one attempt has been finished, this comparison will show the most recent finished attempt. If no attempts have been finished yet, this comparison will show the attempt that got the furthest.
	case latest = "Latest Run"
	///Defines the Personal Best comparison.
	case personalBest = "Personal Best"
	///Defines the Comparison Generator for calculating a comparison which has the same final time as the runner's Personal Best. Unlike the Personal Best however, all the other split times are automatically balanced by the runner's history in order to balance out the mistakes present in the Personal Best throughout the comparison. Running against an unbalanced Personal Best can cause frustrations. A Personal Best with a mediocre early game and a really good end game has a high chance of the runner losing a lot of time compared to the Personal Best towards the end of a run. This may discourage the runner, which may lead them to reset the attempt. That's the perfect situation to compare against the Balanced Personal Best comparison instead, as all of the mistakes of the early game in such a situation would be smoothed out throughout the whole comparison.
	case balancedPB = "Balanced PB"
	///Defines the Comparison Generator for calculating the Best Segments of a Run.
	case bestSegments = "Best Segments"
	///Defines the Comparison Generator for the Best Split Times. The Best Split Times represent the best pace that the runner was ever on up to each split in the run. The Best Split Times are calculated by taking the best split time for each individual split from all of the runner's attempts.
	case bestSplitTimes = "Best Split Times"
	///Defines the Comparison Generator for calculating the Median Segments of a Run. The Median Segments are calculated through a weighted median that gives more recent segments a larger weight so that the Median Segments are more suited to represent the current performance of a runner.
	case medianSegments = "Median Segments"
	///	Defines the Comparison Generator for calculating the Worst Segments of a Run.
	case worstSegments = "Worst Segments"
}
extension SettingValueRef {
	func toColor() -> NSColor? {

		let json = JSON(self.asJson().data(using: .utf8)!)
		if let doubles = json["Color"].arrayObject?.compactMap({ $0 as? Double}) {
			return NSColor(doubles)
		}
		return nil
	}
}
