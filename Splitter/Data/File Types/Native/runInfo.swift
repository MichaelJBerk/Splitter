//
//  splitInfo.swift
//  
//
//  Created by Michael Berk on 1/1/20.
//

import Foundation
import Cocoa


struct runInfo: Codable {
	var title: String
	var category: String
	var segments: [splitSegment]
	
	
}

struct splitSegment: Codable {
	var name: String
	var currentTime: String
	var bestTime: String
}

extension ViewController {
	
	func loadFromRunInfo(icons: [NSImage?]) {
		if let ri = runInfoData {
			GameTitleLabel.stringValue = ri.title
			SubtitleLabel.stringValue = ri.category
			currentSplits = []
			for s in ri.segments {
				let bestTimeSplit = TimeSplit(timeString: s.bestTime)
				let currentTimeSplit = TimeSplit(timeString: s.currentTime)
				let newRow = splitTableRow(splitName: s.name, bestSplit: bestTimeSplit, currentSplit: currentTimeSplit)
				currentSplits.append(newRow)
				splitsTableView.reloadData()
			}
			iconArray = icons
		}
	}
	
	func saveToRunInfo() -> runInfo {
		updateAllBestSplits()
		var segments: [splitSegment] = []
		for s in currentSplits {
			let newSeg = splitSegment(name: s.splitName,
									  currentTime: s.currentSplit.timeString,
									  bestTime: s.bestSplit.timeString)
			segments.append(newSeg)
		}
		let ri = runInfo(title: GameTitleLabel.stringValue,
						 category: SubtitleLabel.stringValue,
						 segments: segments)
		return ri
	}
	
}
