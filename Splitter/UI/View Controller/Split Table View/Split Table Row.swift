//
//  Split Table Row.swift
//  Splitter
//
//  Created by Michael Berk on 2/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

///Row for holding data in the split table view
struct splitTableRow {
	var splitName: String
	var bestSplit: TimeSplit
	var currentSplit: TimeSplit
	var previousSplit: TimeSplit
	var previousBest: TimeSplit
	var splitIcon: NSImage?
	var compareTo: SplitComparison = .previousSplit
	
	///Difference between the (previous) best split and the current best
	var splitDiff: String{
		
		var og: TimeSplit = bestSplit
		
		switch compareTo {
		case .personalBest:
			//TODO: Change to previous best
			og = bestSplit
		case .previousSplit:
			og = previousSplit 
		}
		
		let diff = og - currentSplit
		
		if currentSplit.longTimeString == "00:00:00.00" {
			return "00:00.00"
		} else if currentSplit > bestSplit {
			return "+\(diff.veryShortTimeString)"
		} else if currentSplit < bestSplit {
			return "-\(diff.veryShortTimeString)"
		} else {
			return "00:00.00"
		}
	}
	
	func copy(with zone: NSZone? = nil) -> Any {
		return splitTableRow(splitName: splitName.copy() as! String, bestSplit: bestSplit.copy() as! TimeSplit, currentSplit: currentSplit.copy() as! TimeSplit, previousSplit: previousSplit.tsCopy(), previousBest: previousBest.tsCopy())
	}
}

final class Box<T> {
    let value: T

    init(_ value: T) {
        self.value = value
    }
}

enum SplitComparison {
	case previousSplit
	case personalBest
}
