//
//  splitInfo.swift
//  
//
//  Created by Michael Berk on 1/1/20.
//

import Foundation
import Cocoa
import SwiftyJSON
import LiveSplitKit

//You may wonder why I don't just save Split Table rows directly to the file (since they're structs already anyway). I'm not doing that because I don't want to save the images to runInfo.json


///Structure containing metadata for a .split file
///
///Most of the properties in this struct aren't used in Splitter ≥ 4.0, since the `lss` file contains them instead. Since Splitter 4.0, only `version`, `build` and `id` are used, except when importing from older versions.
struct runInfo: Codable {
	var title: String?
	var category: String?
	var segments: [splitSegment]?
	var attempts: Int?
	var gameVersion: String?
	var compareTo: Int?
	
	var platform: String?
	var gameRegion: String?
	
	var startTime: String?
	var endTime: String?
	
	var version: String?
	var build: String?
	var id: String?
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
	
	///Loads runInfo from JSON
	///
	///This method used for all runInfo files, even from Splitter ≥ 4.0
	func runInfoFromJSON(json: JSON) -> runInfo {
		var splitsegs: [splitSegment] = []
		if let segs = json.dictionary?["segments"]?.array {
			for i in segs {
				let seg = splitSegment(name: i.dictionary!["name"]!.stringValue, currentTime: i.dictionary!["currentTime"]!.stringValue, personalBestTime: i.dictionary!["personalBestTime"]!.stringValue, previousTime: i.dictionary!["previousTime"]!.stringValue, previousPersonalBestTime: i.dictionary!["previousPersonalBestTime"]!.stringValue)
				splitsegs.append(seg)
			}
		}
		let ri = runInfo(title: json.dictionary?["title"]?.string,
						 category: json.dictionary?["category"]?.stringValue,
						 segments: splitsegs,
						 attempts: json.dictionary?["attempts"]?.intValue,
						 gameVersion: json.dictionary?["gameVersion"]?.string,
						 compareTo: json.dictionary?["compareTo"]?.intValue,
						 platform: json.dictionary?["platform"]?.stringValue ?? "",
						 gameRegion: json.dictionary?["gameRegion"]?.string ?? "",
						 startTime: json.dictionary?["startTime"]?.stringValue,
						 endTime: json.dictionary?["endTime"]?.stringValue,
						 version: json.dictionary?["version"]?.stringValue,
						 build: json.dictionary?["build"]?.stringValue,
						 id: json.dictionary?["id"]?.stringValue)
		return ri
		
	}
}
//MARK: - Loading older runInfo files

extension ViewController {
	
	///Load data from a Splitter ≤ 3.x file
	func loadFromV3RunInfo(icons: [NSImage?]) {
		if let ri = runInfoData {
			runTitleField.stringValue = ri.title ?? ""
			categoryField.stringValue = ri.category ?? ""
			platform = ri.platform ?? ""
			run.gameVersion = ri.gameVersion ?? ""
			run.attempts = ri.attempts ?? 0
			gameRegion = ri.gameRegion ?? ""
			fileID = ri.id
			if let segments = ri.segments {
				let compare = ri.compareTo
				switch compare {
				case 0:
					run.setColumnComparison(TimeComparison.bestSegments, for: .diff)
				default:
					run.setColumnComparison(TimeComparison.latest, for: .diff)
				}
				run.editRun { editor in
					for s in 0..<segments.count {
						let segment = segments[s]
						var bestTS = TimeSplit(timeString: segment.personalBestTime)!
						if s > 0 {
							editor.insertSegmentBelow()
							editor.selectOnly(s)
							let prevSegTS = TimeSplit(timeString: segments[s - 1].personalBestTime)!
							bestTS = bestTS - prevSegTS
						} else {
							editor.selectOnly(0)
						}
						_ = editor.activeParseAndSetBestSegmentTime(bestTS.timeString)
						
						
						editor.activeSetName(segment.name)
						_ = editor.activeParseAndSetSplitTime(segment.currentTime)
						
						if let previousTime = segment.previousTime {
							_ = editor.activeParseAndSetComparisonTime(TimeComparison.latest.liveSplitID, previousTime)
						}
						
						if s < icons.count, let image = icons[s] {
							image.toLSImage{ ptr, len in
								editor.activeSetIcon(ptr, len)
							}
						}
					}
					
					splitsTableView.reloadData()
					
				}
				run.updateLayoutState()
			}
		}
	}
}

//MARK: - Saving runInfo

extension ViewController {
	func saveToRunInfo() -> runInfo {
		let ri = runInfo(version: otherConstants.version,
						 build: otherConstants.build,
						 id: fileID)
		return ri
	}
}
