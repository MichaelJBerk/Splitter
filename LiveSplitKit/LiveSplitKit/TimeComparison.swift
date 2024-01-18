//
//  TimeComparison.swift
//  Splitter
//
//  Created by Michael Berk on 5/3/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation
public enum TimeComparison {
	///Defines the Comparison Generator for calculating the Average Segments of a Run. The Average Segments are calculated through a weighted arithmetic mean that gives more recent segments a larger weight so that the Average Segments are more suited to represent the current performance of a runner.
	case averageSegments
	///Defines the Comparison Generator for calculating the Latest Run. Using the Segment History, this comparison reconstructs the splits of the furthest, most recent attempt. If at least one attempt has been finished, this comparison will show the most recent finished attempt. If no attempts have been finished yet, this comparison will show the attempt that got the furthest.
	case latest
	///Defines the Personal Best comparison. This doesn't actually generate times for comparisons. If you want that, use "Best Segments"
	case personalBest
	///Defines the Comparison Generator for calculating a comparison which has the same final time as the runner's Personal Best. Unlike the Personal Best however, all the other split times are automatically balanced by the runner's history in order to balance out the mistakes present in the Personal Best throughout the comparison. Running against an unbalanced Personal Best can cause frustrations. A Personal Best with a mediocre early game and a really good end game has a high chance of the runner losing a lot of time compared to the Personal Best towards the end of a run. This may discourage the runner, which may lead them to reset the attempt. That's the perfect situation to compare against the Balanced Personal Best comparison instead, as all of the mistakes of the early game in such a situation would be smoothed out throughout the whole comparison.
	case balancedPB
	///Defines the Comparison Generator for calculating the Best Segments of a Run.
	case bestSegments
	///Defines the Comparison Generator for the Best Split Times. The Best Split Times represent the best pace that the runner was ever on up to each split in the run. The Best Split Times are calculated by taking the best split time for each individual split from all of the runner's attempts.
	case bestSplitTimes
	///Defines the Comparison Generator for calculating the Median Segments of a Run. The Median Segments are calculated through a weighted median that gives more recent segments a larger weight so that the Median Segments are more suited to represent the current performance of a runner.
	case medianSegments
	///	Defines the Comparison Generator for calculating the Worst Segments of a Run.
	case worstSegments
	
	case custom(String)
	
	public var displayTitle: String {
		switch self {
		case .averageSegments:
			return "Average Segments"
		case .latest:
			return "Latest"
		case .personalBest:
			return "Personal Best"
		case .balancedPB:
			return "Balanced PB"
		case .bestSegments:
			return "Best Segments"
		case .bestSplitTimes:
			return "Best Split Times"
		case .medianSegments:
			return "Median Segments"
		case .worstSegments:
			return "Worst Segments"
		case .custom(let string):
			return string
		}
	}
	
	
	///The name used by LiveSplit
	///
	///Currently, it's the same as the display title, but this allows us to change this later
	public var liveSplitID: String {
		switch self {
		case .averageSegments:
			return "Average Segments"
		case .latest:
			return "Latest Run"
		case .personalBest:
			return "Personal Best"
		case .balancedPB:
			return "Balanced PB"
		case .bestSegments:
			return "Best Segments"
		case .bestSplitTimes:
			return "Best Split Times"
		case .medianSegments:
			return "Median Segments"
		case .worstSegments:
			return "Worst Segments"
		case .custom(let string):
			return string
		}
	}
	
	public static let defaultComparisons: [TimeComparison] = [
		averageSegments,
		latest,
		personalBest,
		balancedPB,
		bestSegments,
		bestSplitTimes,
		medianSegments,
		worstSegments,
	]
	
	public static func fromLSComparison(_ lsComparison: String) -> TimeComparison {
		for comparison in Self.defaultComparisons {
			if lsComparison == comparison.liveSplitID {
				return comparison
			}
		}
		return .custom(lsComparison)
	}
	
	///Determines if a given comparison is a custom comparison
	public var isCustom: Bool {
		switch self {
		case .custom(_):
			return true
		default:
			return false
		}
	}
}
