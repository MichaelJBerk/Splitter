//
//  SplitterComponentType.swift
//  Splitter
//
//  Created by Michael Berk on 7/5/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation
enum SplitterComponentType: Int, Codable, CaseIterable {
	case title
	case splits
	case tableOptions
	case time
	case start
	case prevNext
	case sumOfBest
	case previousSegment
	case totalPlaytime
	case segment
	case possibleTimeSave
	
	var displayTitle: String {
		switch self {
		case .title:
			return "Title"
		case .splits:
			return "Splits"
		case .tableOptions:
			return "Options Row"
		case .time:
			return "Time"
		case .start:
			return "Start/Delete Buttons"
		case .prevNext:
			return "Prev/Next Buttons"
		case .sumOfBest:
			return "Sum of Best"
		case .previousSegment:
			return "Previous Segment"
		case .totalPlaytime:
			return "Total Playtime"
		case .segment:
			return "Current Segment"
		case .possibleTimeSave:
			return "Possible Time Save"
		}
		
	}
	
	var componentType: SplitterComponent.Type {
		switch self {
		case .title:
			return TitleComponent.self
		case .splits:
			return SplitsComponent.self
		case .tableOptions:
			return OptionsRow.self
		case .time:
			return TimeRow.self
		case .start:
			return StartRow.self
		case .prevNext:
			return PrevNextRow.self
		case .sumOfBest:
			return KeyValueComponent.self
		case .previousSegment:
			return KeyValueComponent.self
		case .totalPlaytime:
			return KeyValueComponent.self
		case .segment:
			return KeyValueComponent.self
		case .possibleTimeSave:
			return KeyValueComponent.self
		}
	}
	static func FromType(_ type: SplitterComponent) -> SplitterComponentType? {
		//Switch won't work here, and I have no idea why
		if type is TitleComponent {
			return .title
		} else if type is SplitsComponent {
			return .splits
			
		} else if type is OptionsRow {
			return .tableOptions
		} else if type is TimeRow {
			return .time
		} else if type is StartRow {
			return .start
		} else if type is PrevNextRow {
			return .prevNext
		} else if let kvc = type as? KeyValueComponent {
			switch kvc.key {
			case .sumOfBest:
				return .sumOfBest
			case .previousSegment:
				return .previousSegment
			case .totalPlaytime:
				return .totalPlaytime
			case .currentSegment:
				return .segment
			case .possibleTimeSave:
				return .possibleTimeSave
			default:
				return nil
			}
		}
		return nil
	}
}
