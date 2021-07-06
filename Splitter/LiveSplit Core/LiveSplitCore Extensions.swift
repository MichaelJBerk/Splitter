//
//  LiveSplitCore Extensions.swift
//  Splitter
//
//  Created by Michael Berk on 5/3/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation
import SwiftyJSON
extension SettingValueRef {
	func toColor() -> NSColor? {

		let json = JSON(self.asJson().data(using: .utf8)!)
		if let doubles = json["Color"].arrayObject?.compactMap({ $0 as? Double}) {
			return NSColor(doubles)
		}
		return nil
	}
}

typealias LSCColumn = (index: Int, name: String, updateWith: ColumnUpdateWith, startWith: ColumnStartWith, updateFrom: ColumnUpdateWith, comparison: String?, timingMethod: TimingMethod)

extension LayoutEditor {
	/// - NOTE: Must have splits as the currently selected segment
	
	func settingsStartIndex(for column: Int) -> Int {
		let value = 11 + (column * 6)
		return value
	}
	func setNumberOfColumns(_ index: Int, count: Int) {
		self.setComponentSettingsValue(10, .fromInt(Int32(count)))
	}
	
	func setColumn(_ index: Int, name: String) {
		let settingIndex = settingsStartIndex(for: index)
		self.setComponentSettingsValue(settingIndex, .fromString(name))
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
	
	func getUpdateWith(for index: Int) -> ColumnUpdateWith {
		let settingIndex = settingsStartIndex(for: index) + 2
		let jsonString = self.state().fieldValue(true, settingIndex).asJson()
		let jd = try? JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: .allowFragments) as? [String: String]
		let rawValue = jd?["ColumnUpdateWith"]
		return .init(rawValue: rawValue!)!
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
	func setColumn(_ index: Int, timingMethod: TimingMethod) {
		let settingIndex = settingsStartIndex(for: index) + 5
		if let timingMethod = SettingValue.fromOptionalTimingMethod(timingMethod.rawValue) {
			self.setComponentSettingsValue(settingIndex, timingMethod)
		}
	}
}


enum TimingMethod: String {
	case gameTime = "GameTime"
	case realTime = "RealTime"
}
///Specifies the value a segment starts out with before it gets replaced with the current attempt's information when splitting.
enum ColumnStartWith: String, CaseIterable {
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
enum ColumnUpdateWith: String, CaseIterable {
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
enum ColumnUpdateTrigger: String {
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
