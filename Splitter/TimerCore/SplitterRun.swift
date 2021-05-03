//
//  TimerCore.swift
//  Splitter
//
//  Created by Michael Berk on 3/2/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON

extension Notification.Name {
	static let phaseChanged = Notification.Name("timerPhaseChanged")
	static let runEdited = Notification.Name("runEdited")
	static let splitsEdited = Notification.Name("splitsEdited")
	static let gameIconEdited = Notification.Name("gameIconEdited")
	static let segmentIconEdited = Notification.Name("segmentIconChanged")
}


class SplitterRun: NSObject {
	var layout: Layout
	var timer: SplitterTimer
	var runPtr: UnsafeMutableRawPointer?
	var codableLayout: CLayout!
	var runString: String?
	var refreshTimer: Timer?
	var document: SplitterDoc!
	var undoManager: UndoManager? {
		return document!.undoManager
	}
	
	///Used to prevent crash with numberOfRowsInTableView
	var hasSetLayout = false
	
	private var layoutSettings: CodableLayoutSettings!
	init(run: Run, segments: [SplitTableRow]? = nil, isNewRun: Bool = false) {
		
		//LiveSplit-Core runs need to have at least one segment
		var vRun: Run = run
		vRun.pushSegment(Segment("1"))
		if let editor = RunEditor(vRun) {
			_ = editor.addComparison(TimeComparison.latest.rawValue)
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
			editor.setGeneralSettingsValue(4, .fromNSColor(.splitterDefaultColor))
			
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
			editor.select(1)
			//Include all splits in layout
			editor.setComponentSettingsValue(1, .fromUint(0))
			editor.setComponentSettingsValue(0, .fromAlternatingNSColor(.splitterTableViewColor, .splitterTableViewColor))
			
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
			
			editor.addComponent(LSSumOfBestComponent().intoGeneric())
			for var i in 0..<editor.state().componentLen() {
				print(editor.state().componentText(i))
				
				i+=1
			}
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
		
		//Comparisons aren't saved in LiveSplit,, so we need a custom variable.
		//We load it here, and set it. Before saving the file, we set the custom variable.
		if let comp = getCustomVariable(name: "currentComparison") {
			setComparison(comp)
		} else {
			setComparison(to: .latest, disableUndo: true)
		}
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
	
	/// Edits the run, and makes it undoable.
	/// - Parameters:
	///   - kp: The KeyPath for the variable on `SplitterRun` to write to
	///   - newValue: The new value
	///   - edit: Closure, defining how to edit the LiveSplit run
	func undoableEditRun<T: Equatable>(kp: WritableKeyPath<SplitterRun, T>, actionName: String? = nil, newValue: T, edit: @escaping (RunEditor, T) -> ()) {
		let old = self[keyPath: kp]
		if old != newValue {
			undoManager!.registerUndo(withTarget: self, handler: {hey in
				//				$0[keyPath: old]
				hey.undoableEditRun(kp: kp, newValue: old, edit: edit)
			})
			if let actionName = actionName {
				undoManager?.setActionName(actionName)
			}
			editRun({edit($0, newValue)})
			NotificationCenter.default.post(.init(name: .runEdited))
		}
	}

	
	var attempts: Int {
		get {
			let aCount = timer.lsTimer.getRun().attemptCount()
			return Int(aCount)
		}
		set {
			undoableEditRun(kp: \.attempts, actionName: "Set Attempt Count", newValue: newValue) {
				_ = $0.parseAndSetAttemptCount("\($1)")
			}
		}
	}
	
	var title: String {
		get {
			timer.lsTimer.getRun().gameName()
		}
		set {
			undoableEditRun(kp: \.title, actionName: "Set Title", newValue: newValue, edit: {$0.setGameName($1)})
		}
	}
	
	var subtitle: String {
		get {
			timer.lsTimer.getRun().categoryName()
		}
		set {
			undoableEditRun(kp: \.subtitle, actionName: "Set Category", newValue: newValue, edit: {$0.setCategoryName($1)})
		}
	}
	
	var platform: String {
		get {
			timer.lsTimer.getRun().metadata().platformName()
		}
		set {
			undoableEditRun(kp: \.platform, actionName: "Set Platform", newValue: newValue, edit: {$0.setPlatformName($1)})
		}
	}
	
	func getCustomVariable(name: String) -> String? {
		let customVars = timer.lsTimer.getRun().metadata().customVariables()
		var cVar = customVars.next()
		while (cVar?.name() != name && cVar != nil) {
			cVar = customVars.next()
		}
		return cVar?.value()
	}
	
	var gameVersion: String {
		get {
			getCustomVariable(name: "gameVersion") ?? ""
		}
		set {
			undoableEditRun(kp: \.gameVersion, actionName: "Set Game Version", newValue: newValue, edit: {
				$0.addCustomVariable("gameVersion")
				$0.setCustomVariable("gameVersion", $1)
			})
		}
	}
	
	var region: String {
		get {
			timer.lsTimer.getRun().metadata().regionName()
		}
		set {
			undoableEditRun(kp: \.region, actionName: "Undo Set Region", newValue: newValue, edit: {$0.setRegionName($1)})
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
	
	func addSegment(title: String, at i: Int? = nil) {
		var index: Int
		if let idx = i {
			index = idx - 1
		} else {
			let timerRun = timer.lsTimer.getRun()
			index = timerRun.len() - 1
		}
		undoManager?.registerUndo(withTarget: self, handler: {$0.removeSegment(index + 1)})
		undoManager?.setActionName("Add Segment")
		editRun { editor in
			editor.selectOnly(index)
			editor.insertSegmentBelow()
			editor.activeSetName(title)
		}
		updateLayoutState()
		NotificationCenter.default.post(.init(name: .splitsEdited))
	}
	func removeSegment(_ index: Int) {
		let segTitle = timer.lsRun.segment(index).name()
		undoManager?.registerUndo(withTarget: self, handler: {$0.addSegment(title: segTitle, at: index)})
		undoManager?.setActionName("Remove Segment")
		editRun { editor in
			editor.selectOnly(index)
			editor.removeSegments()
		}
		updateLayoutState()
		NotificationCenter.default.post(.init(name: .splitsEdited))
	}
	func removeBottomSegment() {
		let run = timer.lsTimer.getRun()
		let len = run.len()
		removeSegment(len - 1)
	}
	
	func icon(for segment: Int) -> NSImage? {
		let run = timer.lsTimer.getRun()
		let seg = run.segment(segment)
		let image = LiveSplit.parseImageFromLiveSplit(ptr: seg.iconPtr(), len: seg.iconLen())
		return image
	}
	func setIcon(for segment: Int, image: NSImage?) {
		let oldValue = self.icon(for: segment)?.copy() as? NSImage
		if NSImage.isDiff(oldValue, image) {
			undoManager?.registerUndo(withTarget: self, handler: { r in
				r.setIcon(for: segment, image: oldValue)
			})
			undoManager?.setActionName("Set Segment Icon")
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
			NotificationCenter.default.post(.init(name: .splitsEdited))
		}
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
			let oldValue = self.gameIcon?.copy() as? NSImage
			if NSImage.isDiff(newValue, oldValue) {
				undoManager?.registerUndo(withTarget: self, handler: { r in
					r.gameIcon = oldValue
				})
				editRun { editor in
					if let image = newValue {
						image.toLSImage { ptr, len in
							editor.setGameIcon(ptr, len)
						}
					} else {
						editor.removeGameIcon()
					}
				}
				undoManager?.setActionName("Set Game Icon")
				NotificationCenter.default.post(.init(name: .gameIconEdited, object: newValue))
			}
		}
	}
	
	var offset: Double {
		get {
			timer.lsRun.offset().totalSeconds()
		}
		set {
			undoableEditRun(kp: \.offset, actionName: "Set Offset", newValue: newValue, edit: {
				_ = $0.parseAndSetOffset("\($1)")
			})
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
		if !comparisons.contains(comparison) {
			editRun { editor in
				_ = editor.addComparison(comparison)
			}
		}
		while timer.lsTimer.currentComparison() != comparison {
			timer.lsTimer.switchToNextComparison()
		}
	}
	private func setComparison(to comparison: TimeComparison, disableUndo: Bool = false) {
		let oldValue = self.getComparision()
		if !disableUndo {
			undoManager?.registerUndo(withTarget: self, handler: { r in
				r.setComparison(to: oldValue)
			})
			undoManager?.setActionName("Set Comparison")
		}
		setComparison(comparison.rawValue)
	}
	func setComparison(to comparison: TimeComparison) {
		self.setComparison(to: comparison, disableUndo: false)
	}
	
	func getComparision() -> TimeComparison {
		//TODO: Handle if custom comparison?
		return TimeComparison(rawValue: timer.lsTimer.currentComparison())!
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
		return comparisons
	}
	
	
	///Set the title for a given segment
	func setSegTitle(index: Int, title: String) {
		timer.resetRun(discardSplits: false)
		updateLayoutState()
		let timerRun = timer.lsTimer.getRun()
		let oldName = timerRun.segment(index).name()
		undoManager?.registerUndo(withTarget: self, handler: {$0.setSegTitle(index: index, title: oldName)
			//Since the splits are edited in the table view, there's no point in posting the notification for it to refresh - the new values are already there. However, we do need it when undoing.
			NotificationCenter.default.post(.init(name: .splitsEdited))
		})
		undoManager?.setActionName("Set Segment Title")
		editRun({ editor in
			editor.selectOnly(index)
			editor.activeSetName(title)
		})
		updateLayoutState()
	}
	func setSplitTime(index: Int, time: String) {
		let oldTime = timer.lsTimer.getRun().segment(index).name()
		undoManager?.registerUndo(withTarget: self, handler: {
			$0.setSplitTime(index: index, time: oldTime)
			//We only post the notification when undoing, for the same reasons as in setSegTitle.
			NotificationCenter.default.post(.init(name: .splitsEdited))
		})
		undoManager?.setActionName("Set Segment Time")
		
		editRun { editor in
			editor.selectOnly(index)
			_ = editor.activeParseAndSetSplitTime(time)
		}
		self.updateLayoutState()
	}
	
	var layoutSplits: CSplits {
		codableLayout.components[1].splits!
	}
	
	var currentSplit: Int? {
		timer.currentSplit
	}
	
	var nextButtonTitle: String {
		var nextButtonTitle = "Split"
		if currentSplit == segmentCount - 1 && timer.timerState != .stopped {
			nextButtonTitle = "Finish"
		}
		return nextButtonTitle
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
			if let doubles = codableLayout.components[1].splits?.background.asPlainColor() {
				if doubles.count > 0 {
				}
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
		let comparison = self.getComparision()
		editRun({ editor in
			editor.addCustomVariable("currentComparison")
			editor.setCustomVariable("currentComparison", comparison.rawValue)
		})
		return timer.lsTimer.saveAsLss()
	}
	func layoutToJSON() -> String {
		layout.settingsAsJson()
	}
	func setRun(_ run: Run) {
		_ = timer.lsTimer.setRun(run)
	}
}