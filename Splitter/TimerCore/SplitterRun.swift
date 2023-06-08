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
import Codextended
import ZippyJSON
import LiveSplitKit
extension Notification.Name {
	static let phaseChanged = Notification.Name("timerPhaseChanged")
	static let runEdited = Notification.Name("runEdited")
	static let splitsEdited = Notification.Name("splitsEdited")
	static let gameIconEdited = Notification.Name("gameIconEdited")
	static let segmentIconEdited = Notification.Name("segmentIconChanged")
	static let backgroundImageEdited = Notification.Name("backgroundImageEdited")
	static let fontChanged = Notification.Name("fontChanged")
}
///Layout notifications
extension Notification.Name {
	static let runColorChanged = Notification.Name("runColorChanged")
}


class SplitterRun: NSObject {
	var layout: Layout
	var timer: SplitterTimer
	var runPtr: UnsafeMutableRawPointer?
	var codableLayout: CLayout!
	var runString: String?
	var refreshTimer: Timer?
	var document: SplitterDoc!
	
	///Font used for the timer component
	///
	///Analagous to the `timerFont` in LiveSplitCore
	var timerFont: NSFont? {
		didSet {
			NotificationCenter.default.post(name: .fontChanged, object: self)
		}
	}
	
	///Font used for labels in the run window
	///
	///Analagous to the `textFont` in LiveSplitCore
	///>NOTE: Unlike LiveSplit, this does not control the font for the splits component header. The splits component header uses ``splitsFont``
	var textFont: NSFont? {
		didSet {
			NotificationCenter.default.post(name: .fontChanged, object: self)
		}
	}
	
	///Font used for the Splits component
	///
	///Analagous to the `timesFont` in LiveSplitCore
	///>NOTE: Unlike LiveSplit, this controls the font for the splits component header, instead of ``textFont``, so that the header will be the same height as the table rows.
	var splitsFont: NSFont? {
		didSet {
			NotificationCenter.default.post(name: .fontChanged, object: self)
		}
	}
	
	
	var undoManager: UndoManager? {
		return document?.undoManager
	}
	
	///Used to prevent crash with numberOfRowsInTableView
	var hasSetLayout = false
	
	init(run: Run, isNewRun: Bool = false) {
		var vRun: Run = run
		//LiveSplit-Core runs need to have at least one segment, so if there's a new run, we need to add a blank segment.
		if isNewRun == true || run.len() == 0 {
			vRun.pushSegment(Segment(""))
		}
		
		if let editor = RunEditor(vRun) {
			_ = editor.addComparison(TimeComparison.latest.rawValue)
			vRun = editor.close()
		}
		timer = SplitterTimer(run: vRun)
		layout = .defaultLayout()
		layout.updateState(layout.state(timer.lsTimer), timer.lsTimer)
		let settings = layout.settingsAsJson()
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
			 0 :  Background (LSC Crashes when trying to get it via editor)
			 1 :  Total Splits
			 2 :  Upcoming Splits
			 3 :  Show Thin Separators
			 4 :  Show Separator Before Last Split
			 5 :  Always Show Last Split
			 6 :  Fill with Blank Space if Not Enough Splits
			 7 :  Display 2 Rows
			 8 :  Current Split Gradient
			 9 :  Split Time Accuracy
			 10:  Segment Time Accuracy
			 11:  Delta Time Accuracy
			 12:  Drop Delta Decimals When Showing Minutes
			 13:  Show Column Labels
			 14:  Columns
			- Indices from 15 onwards are each column's settings.
				- The next column's settings are right after the previous one - i.e. column 2 starts at 21.
			 
			 Column Settings
			 15:  Column Name
			 16:  Start With
			 17:  Update With
			 18:  Update Trigger
			 19:  Comparison
			 20:  Timing Method
			 
			 - NOTE: Must have column labels on to set column names
			**/
			
			
			editor.select(1)
			
			//Include all splits in layout
			editor.setComponentSettingsValue(1, .fromUint(0))
			editor.setComponentSettingsValue(0, .fromAlternatingNSColor(.splitterTableViewColor, .splitterTableViewColor))
			editor.setComponentSettingsValue(13, .fromBool(true))
			func oldColumnSetup() {
				editor.setComponentSettingsValue(14, .fromUint(4))
				
				/*
				 IDEA: Handling column order with LiveSplitCore
				 - if no icon/title columns exist(i.e. older splitter or livesplit), add title and icon columns at left, and hide them
				 */
				
				//Setup Diffs Column
				editor.setColumn(1, updateWith: ColumnUpdateWith.segmentDelta)
				editor.setColumn(1, updateTrigger: ColumnUpdateTrigger.onStartingSegment)
				editor.setColumn(1, comparison: "Best Segments")
				//todo: if before fix and diff column comparison is empty, replace diff column compariosn with run comparison, and set run comparison to default
				//Setup PB column
				editor.setColumn(2, name: "PB")
				editor.setColumn(2, comparison: "Best Segments")
				editor.setColumn(2, startWith: .comparsionSegmentTime)
				editor.setColumn(2, updateWith: ColumnUpdateWith.dontUpdate)
				editor.setColumn(2, updateTrigger: ColumnUpdateTrigger.onEndingSegment)
				
				//Setup Previous column
				editor.setColumn(3, name: "Previous")
				editor.setColumn(3, comparison: "Latest Run")
				editor.setColumn(3, startWith: ColumnStartWith.comparsionSegmentTime)
				editor.setColumn(3, updateWith: ColumnUpdateWith.dontUpdate)
				editor.setColumn(3, updateTrigger: ColumnUpdateTrigger.onStartingSegment)
			}
			
			//TODO: Set rounding
			#if DEBUG
			let len = editor.state().fieldLen(true)
			for i in 1..<len {
				print("\(i): \(editor.state().fieldText(true, i))")
			}
			#endif
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
		self.textFont = nil
		setObservers()
		
		//If there's a "currentComparison" variable here, it's a pre-4.3 Splitter file, and thus we need to update it using `fixRunAndDiffsComparison`
		if let comp = getCustomVariable(name: "currentComparison") {
			fixRunAndDiffsComparison(comp)
		}
		setRunComparison(to: .personalBest, disableUndo: true)
	}
	
	func addComponent(component: SplitterComponentType) -> Int? {
		var index: Int? = nil
		var compToAdd: Component
		var stringToCheck: String
		switch component {
		case .sumOfBest:
			compToAdd = LSSumOfBestComponent().intoGeneric()
			stringToCheck = KeyValueComponentType.sumOfBest.rawValue
		case .previousSegment:
			compToAdd = PreviousSegmentComponent().intoGeneric()
			stringToCheck = KeyValueComponentType.previousSegment.rawValue
		case .totalPlaytime:
			compToAdd = TotalPlaytimeComponent().intoGeneric()
			stringToCheck = KeyValueComponentType.totalPlaytime.rawValue
		case .segment:
			compToAdd = SegmentTimeComponent().intoGeneric()
			stringToCheck = KeyValueComponentType.currentSegment.rawValue
		case .possibleTimeSave:
			compToAdd = PossibleTimeSaveComponent().intoGeneric()
			stringToCheck = KeyValueComponentType.possibleTimeSave.rawValue
		default:
			return nil
		}
		
		editLayout({ editor in
			var i = 0
			while i < editor.state().componentLen() {
				if editor.state().componentText(i).contains(stringToCheck) {
					index = i
					i = editor.state().componentLen()
				}
				i+=1
			}
			if index == nil {
				index = editor.state().componentLen()
				editor.addComponent(compToAdd)
				if component == .possibleTimeSave {
					editor.select(index!)
					let val = SettingValue.fromBool(true)
//					editor.setComponentSettingsValue(3, val)
				}
			}
		})
		return index
	}
	func removeComponent(component: SplitterComponentType) {
		editLayout{ editor in
			var i = 0
			while i < editor.state().componentLen() {
				if editor.state().componentText(i).contains("Sum of Best Segments") {
					editor.select(i)
					editor.removeComponent()
					i = editor.state().componentLen()
				}
				i+=1
			}
		}
	}
	
	private func setObservers() {
		NotificationCenter.default.addObserver(forName: .phaseChanged, object: self.timer, queue: nil, using: { [weak self] notification in
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

	///Interval that determines the frequency that the UI updates at
	let fpsInterval: Double = 1 / 30
	var previousTime: Double = 0
	private func startTimer() {
		previousTime = Date().timeIntervalSinceReferenceDate
		
		refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { timer in
			
			//All this code is used to limit the speed that the UI updates at
			let currentTime = Date().timeIntervalSinceReferenceDate
			let elapsed: Double = currentTime - self.previousTime
			if elapsed > self.fpsInterval {
				self.previousTime = currentTime - (elapsed.truncatingRemainder(dividingBy: self.fpsInterval))
				self.updateLayoutState()
				for i in self.updateFunctions {
					i()
				}
			}
		})
	}
	///Stores functions to be called when updating the UI when running
	var updateFunctions: [() -> ()] = []
	
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
			NotificationCenter.default.post(.init(name: .runEdited, object: self))
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
	/** Returns the state of the layout, using the current timer
	
	> Warning: LiveSplitCore may crash if you don't set the layout to a variable first. For example, the following line may crash:
	 ```swift
	 let name = getLayoutState().componentAsSplits(1).columnName(0)
	 ```
	 To work around it, make a separate variable for the LayoutState first:
	 ```swift
	 let ls = getLayoutState()
	 let name = ls.componentAsSplits(1).columnName(0)
	 ```
	*/
	func getLayoutState() -> LayoutState {
		layout.state(timer.lsTimer)
	}
	func getSplitsLayout() -> SplitsComponentStateRef {
		getLayoutState().componentAsSplits(1)
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
		let image = NSImage.parseImageFromLiveSplit(ptr: seg.iconPtr(), len: seg.iconLen())
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
			return NSImage.parseImageFromLiveSplit(ptr: ptr, len: len)
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
	var backgroundImage: NSImage? {
		willSet {
			if NSImage.isDiff(newValue, backgroundImage) {
				let oldValue = backgroundImage?.copy() as? NSImage
				undoManager?.registerUndo(withTarget: self, handler: { r in
					r.backgroundImage = oldValue
				})
				undoManager?.setActionName("Set Background Image")
				NotificationCenter.default.post(.init(name: .backgroundImageEdited, object: self, userInfo: ["image": newValue as Any? as Any]))
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
//		let state = layout.state(timer.lsTimer)
//		let refMutState = LayoutStateRefMut(ptr: state.ptr)
//		let json = layout.updateStateAsJson(refMutState, timer.lsTimer)
		let json = LiveSplitKit.updateLayoutState(layout, timer: timer.lsTimer)
		let jData = json.data(using: .utf8)
		do {
			codableLayout = try ZippyJSONDecoder().decode(CLayout.self, from: jData!)
		} catch {
			print("Decode Error:\n \(error)")
		}
	}
	
	private func setComparison(_ comparison: String) {
		if !comparisons.contains(comparison) {
			editRun { editor in
				_ = editor.addComparison(comparison)
                editor.addCustomVariable("currentComparison")
                editor.setCustomVariable("currentComparison", comparison)
			}
		}
		while timer.lsTimer.currentComparison() != comparison {
			timer.lsTimer.switchToNextComparison()
		}
	}
	
	//I forget why I had to use `disableUndo` here instead of disabling undo registration.
	private func setRunComparison(to comparison: TimeComparison, disableUndo: Bool = false) {
		let oldValue = self.getRunComparision()
		if !disableUndo {
			undoManager?.registerUndo(withTarget: self, handler: { r in
				r.setRunComparison(to: oldValue)
			})
			undoManager?.setActionName("Set Comparison")
		}
		setComparison(comparison.rawValue)
	}
	///Sets the comparison for the run
	///
	///If you need to set the comparison for a single column, use `setColumnComparison(_:for:)` instead
	func setRunComparison(to comparison: TimeComparison) {
		self.setRunComparison(to: comparison, disableUndo: false)
		NotificationCenter.default.post(name: .runEdited, object: self)
	}
	
	func getRunComparision() -> TimeComparison {
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
	
	func splitToSegmentTime(editor: RunEditor, time: Double, index: Int) -> Double {
		var newTime: Double = time
		if index > 0 {
			let editorStateData = editor.stateAsJson().data(using: .utf8)!
			let editorState = try! editorStateData.decoded() as RunEditorState
			let previousSegTime = editorState.segments?[index - 1].splitTime
			let previousTS = TimeSplit(timeString: previousSegTime)!.totalSec
			if previousTS > time {
				newTime = previousTS - time
			} else if time > previousTS {
				newTime = time - previousTS
			}
//			let d = previousTS.totalSec - time
//			newTime = abs(previousTS.totalSec - time)
		}
		return newTime
	}
	
	enum TimeColumn {
		case time
        case diff
		case pb
		case previous
		
		var lsColumn: Int {
			switch self {
			case .time:
				return 0
            case .diff:
                return 1
			case .pb:
				return 2
			case .previous:
				return 3
			}
		}
	}
	
	
	func getStartWith(for column: TimeColumn) -> ColumnStartWith {
		getStartWith(for: column.lsColumn)
	}
	
	func getStartWith(for index: Int) -> ColumnStartWith {
		let editor = LayoutEditor(layout)!
		editor.select(1)
		let update = editor.getStartWith(for: index)
		layout = editor.close()
		return update
	}
	
	
	func getUpdateWith(for column: TimeColumn) -> ColumnUpdateWith {
		getUpdateWith(for: column.lsColumn)
	}
	
	func getUpdateWith(for index: Int) -> ColumnUpdateWith {
		let editor = LayoutEditor(layout)!
		editor.select(1)
		let update = editor.getUpdateWith(for: index)
		layout = editor.close()
		return update
	}
	
	func getUpdateTrigger(for index: Int) -> ColumnUpdateTrigger {
		let editor = LayoutEditor(layout)!
		editor.select(1)
		let update = editor.getUpdateTrigger(for: index)
		layout = editor.close()
		return update
	}
	
	func getColumnComparison(for column: TimeColumn) -> TimeComparison? {
		getColumnComparison(for: column.lsColumn)
	}
	
	func getColumnComparison(for index: Int) -> TimeComparison? {
		let editor = LayoutEditor(layout)!
		editor.select(1)
		let comparison = editor.getColumnComparison(for: index)
		layout = editor.close()
		return comparison
	}
	
	func setColumnComparison(_ comparison: TimeComparison?, for column: TimeColumn) {
		setColumnComparison(comparison, for: column.lsColumn)
	}
	
	func setColumnComparison(_ comparison: TimeComparison?, for index: Int) {
		let oldValue = getColumnComparison(for: index)
		undoManager?.registerUndo(withTarget: self, handler: { r in
			r.setColumnComparison(oldValue, for: index)
		})
		editLayout { editor in
			editor.select(1)
			editor.setColumn(index, comparison: comparison?.rawValue ?? nil)
		}
		undoManager?.setActionName("Set Column Comparison")
		NotificationCenter.default.post(name: .splitsEdited, object: self)
	}
	
	func setStartWith(_ startWith: ColumnStartWith, for column: TimeColumn) {
		setStartWith(startWith, for: column.lsColumn)
	}
	
	func setStartWith(_ startWith: ColumnStartWith, for index: Int) {
		let oldValue = getStartWith(for: index)
		undoManager?.registerUndo(withTarget: self, handler: { r in
			r.setStartWith(oldValue, for: index)
		})
		editLayout { editor in
			editor.select(1)
			editor.setColumn(index, startWith: startWith)
		}
		undoManager?.setActionName("Set Column Value")
		NotificationCenter.default.post(.init(name: .splitsEdited, object: self))
	}
	
	func setUpdateWith(_ updateWith: ColumnUpdateWith, for column: TimeColumn) {
		setUpdateWith(updateWith, for: column.lsColumn)
	}
	func setUpdateWith(_ updateWith: ColumnUpdateWith, for index: Int) {
		let oldValue = getUpdateWith(for: index)
		undoManager?.registerUndo(withTarget: self, handler: { r in
			r.setUpdateWith(oldValue, for: index)
		})
		editLayout{ editor in
			editor.select(1)
			editor.setColumn(index, updateWith: updateWith)
		}
		undoManager?.setActionName("Set Column Value")
		NotificationCenter.default.post(.init(name: .splitsEdited, object: self))
	}
	
	func setUpdateTrigger(_ updateTrigger: ColumnUpdateTrigger, for index: Int) {
		let oldValue = getUpdateTrigger(for: index)
		undoManager?.registerUndo(withTarget: self, handler: { r in
			r.setUpdateTrigger(oldValue, for: index)
		})
		editLayout{ editor in
			editor.select(1)
			editor.setColumn(index, updateTrigger: updateTrigger)
		}
		undoManager?.setActionName("Set Column Value")
		NotificationCenter.default.post(.init(name: .splitsEdited, object: self))
	}
	
	var layoutSplits: CSplits {
		codableLayout.components[1] as! CSplits
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
	
	//NOTE: Because `backgroundColor` gets called every time the colors change, the action name for setting colors is always the same as the action name used for `backgroundColor`
	
	var backgroundColor: NSColor {
		get {
			if let doubles = codableLayout.background.asPlainColor() {
				return NSColor(doubles)
			}
			return NSColor.splitterDefaultColor
		}
		set {
			let setting = SettingValue.fromNSColor(newValue)
			let oldSetting = self.backgroundColor
			undoManager?.registerUndo(withTarget: self, handler: { r in
				r.backgroundColor = oldSetting
			})
			undoManager?.setActionName("Set Background Color")
			editLayout { editor in
				editor.setGeneralSettingsValue(4, setting)
			}
			NotificationCenter.default.post(name: .runColorChanged, object: self)
		}
	}
	var tableColor: NSColor {
		get {
			if let doubles = self.layoutSplits.background.asPlainColor() {
				if doubles.count > 0 {
				}
				return NSColor(doubles)
			}
			return .splitterTableViewColor
		}
		set {
			let setting = SettingValue.fromAlternatingNSColor(newValue, newValue)
			let oldSetting = self.tableColor
			undoManager?.registerUndo(withTarget: self, handler: { r in
				r.tableColor = oldSetting
			})
			undoManager?.setActionName("Set Splits Background Color")
			editLayout { editor in
				editor.select(1)
				editor.setComponentSettingsValue(0, setting)
			}
			NotificationCenter.default.post(name: .runColorChanged, object: self)
		}
	}
	
	var textColor: NSColor {
		get {
			let doubles = codableLayout.textColor
			return NSColor(doubles)
		}
		set {
			let setting = SettingValue.fromNSColor(newValue)
			let oldSetting = self.textColor
			undoManager?.registerUndo(withTarget: self, handler: { r in
				r.textColor = oldSetting
			})
			undoManager?.setActionName("Set Text Color")
			editLayout{ editor in
				editor.setGeneralSettingsValue(15, setting)
			}
			NotificationCenter.default.post(name: .runColorChanged, object: self)
		}
	}
	
	var selectedColor: NSColor = .splitterRowSelected {
		willSet {
			let oldColor = self.selectedColor
			undoManager?.registerUndo(withTarget: self, handler: { r in
				r.selectedColor = oldColor
			})
			undoManager?.setActionName("Set Selected Color")
		}
		didSet {
			NotificationCenter.default.post(.init(name: .runColorChanged, object: self))
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
			let oldSetting = longerColor
			undoManager?.registerUndo(withTarget: self, handler: { r in
				r.longerColor = oldSetting
			})
			let color = [Float(newValue.redComponent), Float(newValue.greenComponent), Float(newValue.blueComponent), Float(newValue.alphaComponent)]
			if let editor = LayoutEditor(layout) {
				editor.setGeneralSettingsValue(8, SettingValue.fromColor(color[0], color[1], color[2], color[3]))
				editor.setGeneralSettingsValue(9, SettingValue.fromColor(color[0], color[1], color[2], color[3]))
				self.layout = editor.close()
			}
			undoManager?.setActionName("Set Longer Color")
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
			let oldSetting = shorterColor
			undoManager?.registerUndo(withTarget: self, handler: { r in
				r.shorterColor = oldSetting
			})
			let color = [Float(newValue.redComponent), Float(newValue.greenComponent), Float(newValue.blueComponent), Float(newValue.alphaComponent)]
			if let editor = LayoutEditor(layout) {
				editor.setGeneralSettingsValue(6, SettingValue.fromColor(color[0], color[1], color[2], color[3]))
				editor.setGeneralSettingsValue(7, SettingValue.fromColor(color[0], color[1], color[2], color[3]))
				self.layout = editor.close()
			}
			undoManager?.setActionName("Set Shorter Color")
		}
		
	}
	
	var bestColor: NSColor {
		get {
			let editor = LayoutEditor(layout)
			let color = editor!.state().fieldValue(false, 5).toColor()!
			layout = editor!.close()
			return color
		}
		set {
			let oldSetting = bestColor
			undoManager?.registerUndo(withTarget: self, handler: { r  in
				r.bestColor = oldSetting
			})
			let newColor = SettingValue.fromNSColor(newValue)
			if let editor = LayoutEditor(layout) {
				editor.setGeneralSettingsValue(5, newColor)
				self.layout = editor.close()
			}
			undoManager?.setActionName("Set Best Color")
		}
	}
	
	func saveToLSS() -> String {
		let comparison = self.getRunComparision()
		
		//Need to put it in a DispatchQueue, or it won't save the times properly for some reason
		DispatchQueue.main.async {
			self.editRun({ editor in
				editor.addCustomVariable("currentComparison")
				editor.setCustomVariable("currentComparison", comparison.rawValue)
			})
		}
		return timer.lsTimer.saveAsLss()
	}
	func layoutToJSON() -> String {
		layout.settingsAsJson()
	}
	func setRun(_ run: Run) {
		_ = timer.lsTimer.setRun(run)
	}
	
	///Adds a column to the run
	///
	///- WARNING: If you want to add a column, you usually want to use ``SplitsComponent/addColumn()`` instead. Using this won't update the table view to have the new column
	func addColumn(component: Int) {
		
		undoManager?.registerUndo(withTarget: self, handler: {r in
			r.removeColumn(component: component)
		})
		
		editLayout { le in
			le.select(component)
			let cols = le.getNumberOfColumns()
			le.setNumberOfColumns(count: cols + 1)
		}
		NotificationCenter.default.post(name: .runEdited, object: self)
		
	}
	
	///Removes the last column from the table
	///
	///If there's no columns left, this method won't do aything
	func removeColumn(component: Int) {
		let ls = getLayoutState()
		let splits = ls.componentAsSplits(component)
		let cols = splits.columnsLen(0)
		if cols < 1 {
			return
		}
		
		var columnName: String!
		var startWith: ColumnStartWith!
		var updateWith: ColumnUpdateWith!
		var updateTrigger: ColumnUpdateTrigger!
		var comparison: TimeComparison?
		var timingMethod: TimingMethod?
		let lastIndex = cols - 1
		editLayout { le in
			le.select(component)
			columnName =  le.getColumnName(lastIndex)
			startWith = le.getStartWith(for: lastIndex)
			updateWith = le.getUpdateWith(for: lastIndex)
			updateTrigger = le.getUpdateTrigger(for: lastIndex)
			comparison = le.getColumnComparison(for: lastIndex)
			timingMethod = le.getTimingMethod(for: lastIndex)
		}
		
		undoManager?.registerUndo(withTarget: self, handler: { r in
			r.addColumn(component: component)
			r.editLayout { le in
				le.select(component)
				let nli = le.getNumberOfColumns() - 1
				le.setColumn(nli, name: columnName)
				le.setColumn(nli, startWith: startWith)
				le.setColumn(nli, updateWith: updateWith)
				le.setColumn(nli, updateTrigger: updateTrigger)
				le.setColumn(nli, comparison: comparison?.rawValue)
				le.setColumn(nli, timingMethod: timingMethod)
			}
			NotificationCenter.default.post(name: .runEdited, object: self)
		})
		
		editLayout { le in
			le.select(component)
			le.setNumberOfColumns(count: cols - 1)
		}
		undoManager?.setActionName("Remove Column")
		
		NotificationCenter.default.post(name: .runEdited, object: self)
	}
	
	
	func setColumnName(name: String, lsColumn: Int, component: Int) {
		let ls = getLayoutState()
		let sc = ls.componentAsSplits(component)
		let oldName = sc.columnLabel(lsColumn)
		if name != oldName {
			undoManager?.registerUndo(withTarget: self, handler: { r in
				r.setColumnName(name: oldName, lsColumn: lsColumn, component: component)
			})
			
			editLayout { le in
				le.select(component)
				le.setColumn(lsColumn, name: name)
			}
			undoManager?.setActionName("Set Column Name")
			NotificationCenter.default.post(name: .runEdited, object: self)
		}
	}
	
	//The reason why so much of the editing logic is here is because it makes it easier to deal with undoing, since the run object is pretty much always going to be in memory
	
	//MARK: -
	
	//MARK: Backwards Compatibility
	///Replaces the diffs comparison with the run's comparison
	///
	///Before Splitter 4.3, the diffs column didn't have a comparison, and so when the user would change its comparison in the Layout Editor, it would change the run's comparison instead. This creates a bunch of weirdness, so in 4.3, I switched to giving the diffs column a comparison override instead. This method takes the existing run comparison, and sets the diffs comparison to it.
	private func fixRunAndDiffsComparison(_ runComparison: String) {
		editLayout { editor in
			editor.select(1)
			editor.setColumn(1, comparison: runComparison)
		}
	}
}
