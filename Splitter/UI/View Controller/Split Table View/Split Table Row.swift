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
	var roundTo: SplitRounding = .tenths
	//TODO: Update Diff when loaded from files
	///Difference between the (previous) best split and the current best
	var splitDiff: String{
		
		var og: TimeSplit = bestSplit
		
		switch compareTo {
		case .personalBest:
			og = previousBest
		case .previousSplit:
			og = previousSplit 
		}
		
		let diff = og - currentSplit
		let diffTimeString: String
		
		switch roundTo {
		case .hundredths:
			diffTimeString = diff.shortTimeString
		default:
			diffTimeString = diff.shortTimeStringTenths
		}
		
		if currentSplit.timeString == "00:00:00.00" {
			return ""
		} else if currentSplit > og {
			return "+\(diffTimeString)"
		} else if currentSplit < og {
			return "-\(diffTimeString)"
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

enum SplitComparison: Int {
	case previousSplit
	case personalBest
}

enum SplitRounding: Int {
	case tenths
	case hundredths
}
