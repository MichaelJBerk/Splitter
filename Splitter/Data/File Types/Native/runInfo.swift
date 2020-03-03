//
//  splitInfo.swift
//  
//
//  Created by Michael Berk on 1/1/20.
//

import Foundation
import Cocoa


//You may wonder why I don't just save Split Table rows directly to the file (since they're structs already anyway). I'm not doing that because I don't want to save the images to runInfo.json

struct runInfo: Codable {
	var title: String
	var category: String
	var segments: [splitSegment]
}

struct splitSegment: Codable {
	var name: String
	var currentTime: String
	var personalBestTime: String
	//Used mostly for comparison:
	var previousTime: String?
	var previousPersonalBestTime:String?
}

extension ViewController {
	
	func loadFromRunInfo(icons: [NSImage?]) {
		if let ri = runInfoData {
			GameTitleLabel.stringValue = ri.title
			SubtitleLabel.stringValue = ri.category
			currentSplits = []
			for s in ri.segments {
				let bestTimeSplit = TimeSplit(timeString: s.personalBestTime)
				let currentTimeSplit = TimeSplit(timeString: s.currentTime)
				let newRow = splitTableRow(splitName: s.name, bestSplit: bestTimeSplit, currentSplit: currentTimeSplit, previousSplit: TimeSplit(timeString: s.previousTime ?? "00") , previousBest: TimeSplit(timeString: s.previousPersonalBestTime ??
					"00") )
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
									  personalBestTime: s.bestSplit.timeString,
									  previousTime: s.previousSplit.timeString,
									  previousPersonalBestTime: s.previousBest.timeString)
			segments.append(newSeg)
		}
		let ri = runInfo(title: GameTitleLabel.stringValue,
						 category: SubtitleLabel.stringValue,
						 segments: segments)
		return ri
	}
	
}
