//
//  TimeComparison.swift
//  Splitter
//
//  Created by Michael Berk on 5/3/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation
enum TimeComparison: String, CaseIterable {
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
