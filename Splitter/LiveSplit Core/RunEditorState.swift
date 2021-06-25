//
//  RunEditorState.swift
//  Splitter
//
//  Created by Michael Berk on 6/16/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation
import Codextended
struct RunEditorState: Codable {
	///The game's icon encoded as a Data URL. This value is only specified whenever the icon changes. The String itself may be empty. This indicates that there is no icon.
	var iconChange: String?
	///The number of times this Run has been attempted by the runner. This is mostly just a visual number and has no effect on any history.
	var attempts: Int?
	///The name of the game the Run is for.
	var game: String?
	///The timer offset specifies the time that the timer starts at when starting a new attempt.
	var offset: String?
	///The name of the category the Run is for.
	var category: String?
	///The timing method that is currently selected to be visualized and edited.
	var timingMethod: String?
	///The state of all the segments.
	var segments: [RunEditorSegmentState]?
	///The names of all the custom comparisons that exist for this Run.
	var comparisonNames: [String]?
	///Additional metadata of this Run, like the platform and region of the game.
	var metadata: RunEditorMetadataState?
	
	enum CodingKeys: String, CodingKey {
		case iconChange = "icon_change"
		case game, offset, category
		case attempts
		case segments
		case timingMethod = "timing_method"
		case comparisonNames = "comparison_names"
		
	}
}
///Describes the current state of a segment.
struct RunEditorSegmentState: Codable, Equatable {
//	var id = UUID()
	
	///The segment's icon encoded as a Data URL. This value is only specified whenever the icon changes. The String itself may be empty. This indicates that there is no icon.
	var iconChange: String?
	///The name of the segment.
	var name: String
	///The segment's split time for the active timing method.
	var splitTime: String
	///The segment time for the active timing method.
	var segmentTime: String
	///The best segment time for the active timing method.
	var bestSegmentTime: String
	///All of the times of the custom comparison for the active timing method. The order of these matches up with the order of the custom comparisons provided by the Run Editor's State object.
	var comparisonTimes: [String]
	///Describes the segment's selection state.
	var selected: RunEditorSelectionState
	
	enum CodingKeys: String, CodingKey {
		case iconChange = "icon_change"
		case splitTime = "split_time"
		case segmentTime = "segment_time"
		case bestSegmentTime = "best_segment_time"
		case comparisonTimes = "comparison_times"
		case selected, name
	}
}
///Describes the segment's selection state.
enum RunEditorSelectionState: String, Codable {
	case active = "Active"
	case notSelected = "NotSelected"
	
	init(_ bool: Bool) {
		if bool {
			self = .active
		} else {
			self = .notSelected
		}
	}
	
	func bool() -> Bool {
		switch self {
		case .active:
			return true
		case .notSelected:
			return false
		}
	}
}
/// An arbitrary key value pair storing additional information about the category. An example of this may be whether Amiibos are used in this category.
struct RunEditorCustomVariableState: Codable, Hashable {
	var value: String
	var isPermanent: Bool
	
	enum CodingKeys: String, CodingKey {
		case value
		case isPermanent = "is_permanent"
	}
}
///The Run Metadata stores additional information about a run, like the platform and region of the game. All of this information is optional.
struct RunEditorMetadataState: Codable {
	///The speedrun.com Run ID of the run. You need to ensure that the record on speedrun.com matches up with the Personal Best of this run. This may be empty if there's no association
	var runId: String
	///The name of the platform this game is run on. This may be empty if it's not specified.
	var platformName: String
	///The name of the region this game is from. This may be empty if it's not specified.
	var regionName: String
	///Stores all the variables. A variable is an arbitrary key value pair storing additional information about the category. An example of this may be whether Amiibos are used in this category.
	var variables: [String: RunEditorCustomVariableState]
	///Specifies whether this speedrun is done on an emulator. Keep in mind that false may also mean that this information is simply not known.
	var usesEmulator: Bool
	
	enum CodingKeys: String, CodingKey {
		case variables
		case usesEmulator = "uses_emulator"
		case runId = "run_id"
		case platformName = "platform_name"
		case regionName = "region_name"
	}
}
extension RunEditor {
	
	func getState() -> RunEditorState {
		let jsonData = self.stateAsJson().data(using: .utf8)!
		do {
			let state = try jsonData.decoded() as RunEditorState
			return state
		} catch {
			print(self.stateAsJson())
			print(error)
			fatalError(error.localizedDescription)
		}
	}
	
}
