//
//  splitInfo.swift
//  
//
//  Created by Michael Berk on 1/1/20.
//

import Foundation
import Cocoa
import SwiftyJSON


//You may wonder why I don't just save Split Table rows directly to the file (since they're structs already anyway). I'm not doing that because I don't want to save the images to runInfo.json

struct runInfo: Codable {
	var title: String
	var category: String
	var segments: [splitSegment]
	var attempts: Int?
	var platform: String?
	var gameVersion: String?
	var gameRegion: String?
	var compareTo: Int?
	
	var startTime: String?
	var endTime: String?
	
	var version: String?
	var build: String?
	
}



struct splitSegment: Codable {
	var name: String
	var currentTime: String
	var personalBestTime: String
	//Used mostly for comparison:
	var previousTime: String?
	var previousPersonalBestTime:String?
	

}
class splitToJSON {
	//Can't have this as an initalizer of the runInfo struct becuase then i'd have to re-implement the default initalizer
	func runInfoFromJSON(json: JSON) -> runInfo {
			let segs = json.dictionary!["segments"]?.array!
			var splitsegs: [splitSegment] = []
			for i in segs! {
				let n = i.dictionary!["name"]?.stringValue
				
				let seg = splitSegment(name: i.dictionary!["name"]!.stringValue, currentTime: i.dictionary!["currentTime"]!.stringValue, personalBestTime: i.dictionary!["personalBestTime"]!.stringValue, previousTime: i.dictionary!["previousTime"]!.stringValue, previousPersonalBestTime: i.dictionary!["previousPersonalBestTime"]!.stringValue)
				splitsegs.append(seg)
			}
			var ri = runInfo(title: json.dictionary!["title"]!.string!,
							 category: json.dictionary!["category"]!.stringValue,
							 segments: splitsegs,
							 attempts: json.dictionary?["attempts"]?.intValue,
							 platform: json.dictionary?["platform"]?.stringValue,
							 gameVersion: json.dictionary?["gameVersion"]?.string,
							 gameRegion: json.dictionary?["gameRegion"]?.string,
							 compareTo: json.dictionary?["compareTo"]?.intValue,
							 startTime: json.dictionary?["startTime"]?.stringValue,
							 endTime: json.dictionary?["endTime"]?.stringValue,
							 version: json.dictionary?["version"]?.stringValue,
							 build: json.dictionary?["build"]?.stringValue)
			return ri
			
		}
}



extension ViewController {
	
	
	func loadFromRunInfo(icons: [NSImage?]) {
		if let ri = runInfoData {
			runTitleField.stringValue = ri.title
			categoryField.stringValue = ri.category
			platform = ri.platform
			gameVersion = ri.version
			attempts = ri.attempts ?? 0
			gameRegion = ri.gameRegion
			if let st = ri.startTime {
				self.startTime = dateForRFC3339DateTimeString(rfc3339DateTimeString: st)
			}
			if let et = ri.endTime {
				self.endTime = dateForRFC3339DateTimeString(rfc3339DateTimeString: et)
			}
			currentSplits = []
			for s in ri.segments {
				let compare = SplitComparison(rawValue: ri.compareTo ?? 0)!
				let bestTimeSplit = TimeSplit(timeString: s.personalBestTime)
				let currentTimeSplit = TimeSplit(timeString: s.currentTime)
				let newRow = splitTableRow(splitName: s.name, bestSplit: bestTimeSplit, currentSplit: currentTimeSplit, previousSplit: TimeSplit(timeString: s.previousTime ?? "00") , previousBest: TimeSplit(timeString: s.previousPersonalBestTime ??
					"00"),compareTo: compare )
				currentSplits.append(newRow)
				splitsTableView.reloadData()
			}
			iconArray = icons
		}
	}
	
	func saveToRunInfo() -> runInfo {
		
		var segments: [splitSegment] = []
		for s in currentSplits {
			let newSeg = splitSegment(name: s.splitName,
									  currentTime: s.currentSplit.timeString,
									  personalBestTime: s.bestSplit.timeString,
									  previousTime: s.previousSplit.timeString,
									  previousPersonalBestTime: s.previousBest.timeString)
			segments.append(newSeg)
		}
		
//		var startFormat = DateFormatter().
		let startDate: String?
		if startTime != nil {
		
			startDate = rfc3339DateTimeStringForDate(date: startTime!)
		
		} else {
			startDate = nil
		}
		let endDate: String?
		if endTime != nil {
			
			endDate = rfc3339DateTimeStringForDate(date: endTime!)
			
		} else {
			endDate = nil
		}
		let ri = runInfo(title: runTitleField.stringValue,
						 category: categoryField.stringValue,
						 segments: segments,
						 attempts: attempts,
						 platform: platform,
						 gameVersion: gameVersion,
						 gameRegion: gameRegion,
						 compareTo: compareTo.rawValue,
						 startTime: startDate,
						 endTime: endDate,
						 version: otherConstants.version,
						 build: otherConstants.build)
		return ri
	}
	
}

