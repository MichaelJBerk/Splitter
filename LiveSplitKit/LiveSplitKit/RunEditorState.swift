//
//  RunEditorState.swift
//  Splitter
//
//  Created by Michael Berk on 6/16/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation
import Codextended

public struct RunEditorState: Codable {
	///The game's icon. This value is only specified whenever the icon has been changed. If it's `nil`, it indicates that no change has been made to the icon.
	///
	///The raw data for the icon is acessible via the `rawValue` property
	public var iconChange: IconChangeState?
	///The number of times this Run has been attempted by the runner. This is mostly just a visual number and has no effect on any history.
	public var attempts: Int?
	///The name of the game the Run is for.
	public var game: String?
	///The timer offset specifies the time that the timer starts at when starting a new attempt.
	public var offset: String?
	///The name of the category the Run is for.
	public var category: String?
	///The timing method that is currently selected to be visualized and edited.
	public var timingMethod: String?
	///The state of all the segments.
	public var segments: [RunEditorSegmentState]?
	///The names of all the custom comparisons that exist for this Run.
	public var comparisonNames: [String]?
	///Additional metadata of this Run, like the platform and region of the game.
	public var metadata: RunEditorMetadataState?
	
	enum CodingKeys: String, CodingKey {
		case iconChange = "icon_change"
		case game, offset, category
		case attempts
		case segments
		case timingMethod = "timing_method"
		case comparisonNames = "comparison_names"
		case metadata
	}
	
	public init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
		
//		if let ic: IconChangeState = try decoder.decode("icon_change"), ic.rawValue.count > 0 {
		iconChange = try decoder.decode("icon_change")
//		}

		attempts = try decoder.decode("attempts")
		game = try decoder.decode("game")
		offset = try decoder.decode("offset")
		category = try decoder.decode("category")
		timingMethod = try decoder.decode("timing_method")
		segments = try decoder.decode("segments")
		comparisonNames = try decoder.decode("comparison_names")
		metadata = try decoder.decode("metadata")
	}
	
}
///Describes the current state of a segment.
public struct RunEditorSegmentState: Codable, Equatable {
	
	///The game's icon. This value is only specified whenever the icon has been changed. If it's `nil`, it indicates that no change has been made to the icon.
	///
	///The raw data for the icon is acessible via the `rawValue` property
	public var iconChange: IconChangeState?
	///The name of the segment.
	public var name: String
	///The segment's split time for the active timing method.
	public var splitTime: String
	///The segment time for the active timing method.
	public var segmentTime: String
	///The best segment time for the active timing method.
	public var bestSegmentTime: String
	///All of the times of the custom comparison for the active timing method. The order of these matches up with the order of the custom comparisons provided by the Run Editor's State object.
	public var comparisonTimes: [String]
	///Describes the segment's selection state.
	public var selected: RunEditorSelectionState
	
	enum CodingKeys: String, CodingKey {
		case iconChange = "icon_change"
		case splitTime = "split_time"
		case segmentTime = "segment_time"
		case bestSegmentTime = "best_segment_time"
		case comparisonTimes = "comparison_times"
		case selected, name
	}
	
	public init(from decoder: Decoder) throws {
		
		iconChange = try decoder.decode("icon_change")
		splitTime = try decoder.decode("split_time")
		segmentTime = try decoder.decode("segment_time")
		bestSegmentTime = try decoder.decode("best_segment_time")
		comparisonTimes = try decoder.decode("comparison_times")
		name = try decoder.decode("name")
		selected = try decoder.decode("selected")
	}
}
///Describes the segment's selection state.
public enum RunEditorSelectionState: String, Codable {
	case active = "Active"
	case notSelected = "NotSelected"
	
	init(_ bool: Bool) {
		if bool {
			self = .active
		} else {
			self = .notSelected
		}
	}
	
	public func bool() -> Bool {
		switch self {
		case .active:
			return true
		case .notSelected:
			return false
		}
	}
}
/// An arbitrary key value pair storing additional information about the category. An example of this may be whether Amiibos are used in this category.
public struct RunEditorCustomVariableState: Codable, Hashable {
	public var value: String
	public var isPermanent: Bool
	
	enum CodingKeys: String, CodingKey {
		case value
		case isPermanent = "is_permanent"
	}
}
///The Run Metadata stores additional information about a run, like the platform and region of the game. All of this information is optional.
public struct RunEditorMetadataState: Codable {
	///The speedrun.com Run ID of the run. You need to ensure that the record on speedrun.com matches up with the Personal Best of this run. This may be empty if there's no association
	public var runId: String
	///The name of the platform this game is run on. This may be empty if it's not specified.
	public var platformName: String
	///The name of the region this game is from. This may be empty if it's not specified.
	public var regionName: String
	///Stores all the variables. A variable is an arbitrary key value pair storing additional information about the category. An example of this may be whether Amiibos are used in this category.
	public var variables: [String: RunEditorCustomVariableState]
	///Specifies whether this speedrun is done on an emulator. Keep in mind that false may also mean that this information is simply not known.
	public var usesEmulator: Bool
	
	enum CodingKeys: String, CodingKey {
		case variables = "custom_variables"
		case usesEmulator = "uses_emulator"
		case runId = "run_id"
		case platformName = "platform_name"
		case regionName = "region_name"
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		usesEmulator = try container.decode(Bool.self, forKey: .usesEmulator)
		runId = try container.decode(String.self, forKey: .runId)
		platformName = try container.decode(String.self, forKey: .platformName)
		regionName = try container.decode(String.self, forKey: .regionName)
		variables = try container.decode([String: RunEditorCustomVariableState].self, forKey: .variables)
	}
}

///Type containing the data for a new icon in a RunEditor
public struct IconChangeState: Codable, Equatable, RawRepresentable {
	public init?(rawValue: Data) {
		self.rawValue = rawValue
	}
	
	public let rawValue: Data
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let decodeError = DecodingError.valueNotFound(Data.self, .init(codingPath: decoder.codingPath, debugDescription: "Icon Change State not found"))
		if var icString = try container.decode(String?.self) {
			icString = icString.replacingOccurrences(of: "data:;base64,", with: "")
			let d = Data(base64Encoded: icString)!
			rawValue = d
		} else {
			throw decodeError
		}
	}
	public func encode(to encoder: Encoder) throws {
		let b64 = "data:;base64," + rawValue.base64EncodedString()
		try encoder.encodeSingleValue(b64)
	}
}


public extension RunEditor {
	
	func getState() -> RunEditorState {
		let jStr = self.stateAsJson()
		let jsonData = jStr.data(using: .utf8)!
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

