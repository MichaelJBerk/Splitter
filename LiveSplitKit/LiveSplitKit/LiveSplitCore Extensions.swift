//
//  LiveSplitCore Extensions.swift
//  Splitter
//
//  Created by Michael Berk on 5/3/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation
import SwiftyJSON
import AppKit

public extension Run {
	///  Attempts to parse a splits file from a file by invoking the corresponding parser for the file format detected.
	/// - Parameters:
	///   - path: Path to the file to be parsed
	///   - loadFiles: Should external files - such as images - be loaded
	/// - Returns: The parsed run if successful, `nil` if not
	/// - NOTE: File does not get closed
	static func parseFile(path: String, loadFiles: Bool) -> Run? {
		if let handle = FileHandle(forReadingAtPath: path) {
			let fd = Int64(handle.fileDescriptor)
			return parseFileHandle(fd, path, loadFiles).unwrap()
		}
		return nil
		
	}
}
public extension SettingValueRef {
	func toColor() -> NSColor? {

		let json = JSON(self.asJson().data(using: .utf8)!)
		if let doubles = json["Color"].arrayObject?.compactMap({ $0 as? Double}) {
			return NSColor(doubles)
		}
		return nil
	}
	
	func toString() -> String? {
		guard let jsonString = self.asJson().data(using: .utf8) else {return nil}
		let json = JSON(jsonString)
		return json["String"].string
	}
	
	func toInt() -> Int {
		let jsonString = self.asJson().data(using: .utf8)!
		let json = JSON(jsonString)
		return json["UInt"].intValue
	}
}

typealias LSCColumn = (index: Int, name: String, updateWith: ColumnUpdateWith, startWith: ColumnStartWith, updateFrom: ColumnUpdateWith, comparison: String?, timingMethod: TimingMethod)

public extension LayoutEditor {
	/// - NOTE: Must have splits as the currently selected component
	
	func settingsStartIndex(for column: Int) -> Int {
		let value = 15 + (column * 6)
		return value
	}
	func setNumberOfColumns(count: Int) {
		let sv = SettingValue.fromUint(UInt32(count))
		self.setComponentSettingsValue(14, sv)
	}
	
	func getNumberOfColumns() -> Int {
		let state = state()
		let sv = state.fieldValue(true, 14)
		return sv.toInt()
	}
	
	func setColumn(_ index: Int, name: String) {
		let settingIndex = settingsStartIndex(for: index)
		self.setComponentSettingsValue(settingIndex, .fromString(name))
	}
	
	func moveColumn(_ sourceIndex: Int, to destIndex: Int) {
		var c = sourceIndex
		
		if sourceIndex > destIndex {
			while c > destIndex {
				swapColumn(c, to: c - 1)
				c -= 1
			}
		} else if sourceIndex < destIndex {
			while c < destIndex {
				swapColumn(c, to: c + 1)
				c += 1
			}
		}
	}
	
	func swapColumn(_ sourceIndex: Int, to destIndex: Int) {
		let sourceStartIndex = settingsStartIndex(for: sourceIndex)
		let destStartIndex = settingsStartIndex(for: destIndex)
		
		let sourceName = getColumnName(sourceIndex)
		let sourceSw = getStartWith(for: sourceIndex)
		let sourceUw = getUpdateWith(for: sourceIndex)
		let sourceUt = getUpdateTrigger(for: sourceIndex)
		let sourceComp = getColumnName(sourceIndex)
		var sourceTM: SettingValue
		let state = state()
		if let sourceTMString = state.fieldValue(true, destStartIndex + 5).toString() {
			sourceTM = SettingValue.fromOptionalTimingMethod(sourceTMString)!
		} else {
			sourceTM = SettingValue.fromOptionalEmptyTimingMethod()
		}
		let destName = getColumnName(destIndex)
		let destSw = getStartWith(for: destIndex)
		let destUw = getUpdateWith(for: destIndex)
		let destUt = getUpdateTrigger(for: destIndex)
		let destComp = getColumnName(destIndex)
		var destTM: SettingValue
		if let destTMString = state.fieldValue(true, destStartIndex + 5).toString() {
			destTM = SettingValue.fromOptionalTimingMethod(destTMString)!
		} else {
			destTM = SettingValue.fromOptionalEmptyTimingMethod()
		}
		setColumn(destIndex, name: sourceName)
		setColumn(destIndex, startWith: sourceSw)
		setColumn(destIndex, updateWith: sourceUw)
		setColumn(destIndex, updateTrigger: sourceUt)
		setColumn(destIndex, comparison: sourceComp)
		setComponentSettingsValue(destStartIndex + 5, sourceTM)
		
		setColumn(sourceIndex, name: destName)
		setColumn(sourceIndex, startWith: destSw)
		setColumn(sourceIndex, updateWith: destUw)
		setColumn(sourceIndex, updateTrigger: destUt)
		setColumn(sourceIndex, comparison: destComp)
		setComponentSettingsValue(sourceStartIndex + 5, destTM)
	}
	
	func getColumnName(_ index: Int) -> String {
		let settingIndex = settingsStartIndex(for: index)
		//We need to set state as a constant first; see the documentation on ``LayoutEditor.state()`` for more info
		let state = self.state()
		return state.fieldValue(true, settingIndex).toString()!
	}
	func setColumn(_ index: Int, startWith: ColumnStartWith) {
		let settingIndex = settingsStartIndex(for: index) + 1
		if let startWith = SettingValue.fromColumnStartWith(startWith.rawValue) {
			self.setComponentSettingsValue(settingIndex, startWith)
		}
	}
	func getStartWith(for index: Int) -> ColumnStartWith {
		let settingIndex = settingsStartIndex(for: index) + 1
		let jsonString = self.state().fieldValue(true, settingIndex).asJson()
		let jd = try? JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: .allowFragments) as? [String: String]
		let rawValue = jd?["ColumnStartWith"]
		return .init(rawValue: rawValue!)!
	}
	
	func setColumn(_ index: Int, updateWith: ColumnUpdateWith) {
		let settingIndex = settingsStartIndex(for: index) + 2
		if let setting = SettingValue.fromColumnUpdateWith(updateWith.rawValue) {
			self.setComponentSettingsValue(settingIndex, setting)
		}
	}
	func getColumnComparison(for index: Int) -> TimeComparison? {
		let settingIndex = settingsStartIndex(for: index) + 4
		let jsonState = self.stateAsJson()
		//For whatever reason, LiveSplitCore won't output the correct value if I get the field and to `asJSON` on it, like the other properties, so I have to do this instead.
		if let state = try? JSON(data: jsonState.data(using: .utf8)!) {
			let s = state["component_settings"]["fields"].arrayValue[settingIndex]
			if let v = s["value"]["OptionalString"].string {
				let comparison = TimeComparison.fromLSComparison(v)
				return comparison
			}
			
		}
		return nil
	}
	
	func getUpdateWith(for index: Int) -> ColumnUpdateWith {
		let settingIndex = settingsStartIndex(for: index) + 2
		let jsonString = self.state().fieldValue(true, settingIndex).asJson()
		let jd = try? JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: .allowFragments) as? [String: String]
		let rawValue = jd?["ColumnUpdateWith"]
		return .init(rawValue: rawValue!)!
	}
	
	func getUpdateTrigger(for index: Int) -> ColumnUpdateTrigger {
		let settingIndex = settingsStartIndex(for: index) + 3
		let jsonString = self.state().fieldValue(true, settingIndex).asJson()
		let jd = try? JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: .allowFragments) as? [String: String]
		let rawValue = jd?["ColumnUpdateTrigger"]
		return .init(rawValue: rawValue!)!
	}
	
	func getTimingMethod(for column: Int) -> TimingMethod? {
		let settingIndex = settingsStartIndex(for: column) + 5
		let jsonString = self.state().fieldValue(true, settingIndex).asJson()
		let jd = try? JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: .fragmentsAllowed) as? [String: String]
		if let rawValue = jd?["OptionalTimingMethod"] {
			return .init(rawValue: rawValue)
		}
		return nil
	}
	
	func setColumn(_ index: Int, updateTrigger: ColumnUpdateTrigger) {
		let settingIndex = settingsStartIndex(for: index) + 3
		if let updateTrigger = SettingValue.fromColumnUpdateTrigger(updateTrigger.rawValue) {
			self.setComponentSettingsValue(settingIndex, updateTrigger)
		}
	}
	func setColumn(_ index: Int, comparison: String?) {
		let settingIndex = settingsStartIndex(for: index) + 4
		if let comparison = comparison {
			self.setComponentSettingsValue(settingIndex, SettingValue.fromOptionalString(comparison))
		}
	}
	func setColumn(_ index: Int, timingMethod: TimingMethod?) {
		let settingIndex = settingsStartIndex(for: index) + 5
		var value: SettingValue
		if let timingMethod = timingMethod {
			value = SettingValue.fromOptionalTimingMethod(timingMethod.rawValue)!
		} else {
			value = SettingValue.fromOptionalEmptyTimingMethod()
		}
		self.setComponentSettingsValue(settingIndex, value)
	}
}

public extension SplitsComponentStateRef {
	
	func textColor(for index: Int, column: Int) -> NSColor {
		let hex = columnVisualColor(index, columnIndex: column)
		return NSColor.from(hex: hex)
	}
	
}


public enum TimingMethod: String {
	case gameTime = "GameTime"
	case realTime = "RealTime"
}
///Specifies the value a segment starts out with before it gets replaced with the current attempt's information when splitting.
public enum ColumnStartWith: String, CaseIterable {
	///The column starts out with an empty value.
	case empty = "Empty"
	///The column starts out with the times stored in the comparison that is being compared against.
	case comparisonTime = "ComparisonTime"
	///The column starts out with the segment times stored in the comparison that is being compared against.
	case comparsionSegmentTime = "ComparisonSegmentTime"
	///The column starts out with the time that can be saved on each individual segment stored in the comparison that is being compared against.
	case possibleTimeSave = "PossibleTimeSave"
	
	var displayText: String {
		switch self {
		case .empty:
			return "Empty"
		case .comparisonTime:
			return "Comparison"
		case .comparsionSegmentTime:
			return "Comparison Segment Time"
		case .possibleTimeSave:
			return "Possible Time Save"
		}
	}
}
///Once a certain condition is met, which is usually being on the split or already having completed the split, the time gets updated with the value specified here.
public enum ColumnUpdateWith: String, CaseIterable {
	///The value doesn't get updated and stays on the value it started out with
	case dontUpdate = "DontUpdate"
	
	///The value gets replaced by the current attempt's split time.
	case splitTime = "SplitTime"
	///Delta between the split time of the current attempt and the current comparison
	///
	///The value gets replaced by the delta of the current attempt's and the comparison's split time.
	case delta = "Delta"
	
	///Delta, but shows the current Split Time if there isn't a delta
	///
	///The value gets replaced by the delta of the current attempt's and the comparison's split time. If there is no delta, the value gets replaced by the current attempt's split time instead.
	case deltaWithFallback = "DeltaWithFallback"
	
	///The value gets replaced by the current attempt's segment time.
	case segmentTime = "SegmentTime"
	
	///The value gets replaced by the current attempt's time saved or lost, which is how much faster or slower the current attempt's segment time is compared to the comparison's segment time. This matches the Previous Segment component.
	case segmentDelta = "SegmentDelta"
	///The value gets replaced by the current attempt's time saved or lost, which is how much faster or slower the current attempt's segment time is compared to the comparison's segment time. This matches the Previous Segment component. If there is no time saved or lost, then value gets replaced by the current attempt's segment time instead.
	case segmentDeltaWithFallback = "SegmentDeltaWithFallback"

}
///Specifies when a column's value gets updated.
public enum ColumnUpdateTrigger: String, CaseIterable {
	//"When segment begins"
	///The value gets updated as soon as the segment is started. The value constantly updates until the segment ends.
	case onStartingSegment = "OnStartingSegment"
	
	//"After longer than comparison"?
	///The value doesn't immediately get updated when the segment is started. Instead the value constantly gets updated once the segment time is longer than the best segment time. The final update to the value happens when the segment ends.
	case contextual = "Contextual"
	
	//"When segment ends"
	///The value of a segment gets updated once the segment ends.
	case onEndingSegment = "OnEndingSegment"
}

private struct DecodedSettingsValue: Codable {
	
	var int: Int?
	
	enum CodingKeys: String, CodingKey {
		case int = "UInt"
	}
	
	init(from decoder: Decoder) throws {
		let c = try decoder.container(keyedBy: CodingKeys.self)
		int = try c.decodeIfPresent(Int.self, forKey: .int)
	}
}
