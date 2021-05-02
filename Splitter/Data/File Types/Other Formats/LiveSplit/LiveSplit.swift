//
//  LiveSplit.swift
//  Splitter
//
//  Created by Michael Berk on 2/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa
import Files

class LiveSplit: NSObject {
	
	var path: String!
	var data: Data!
	var splits: [SplitTableRow] = []
	var icons: [NSImage?] = []
	var gameIcon: NSImage?
	var runTitle: String?
	var category: String?
	var attempts: Int?
	var platform: String?
	var region: String?
	var gameVersion: String?
	
	public var iconArray: [NSImage?] = []
	
	var startDate: String?
	var endDate: String?
	
	var lsPointer: UnsafeMutableRawPointer?
	
	///Parses a `.lss` file
	func parseLivesplit(template: Bool = false) {
		let lssFile = try? File(path: path)
		let lssData = try? lssFile?.read()
		data = lssData!
		
		let hand = FileHandle(forReadingAtPath: path)
		let handle64 = Int64(hand!.fileDescriptor)
		let cRun = Run.parseFileHandle(handle64, path, true)
		
		if cRun.parsedSuccessfully() {
			let run = cRun.unwrap()
			parseBestSplits(run: run, template: template)
			attempts = !template ? Int(run.attemptCount()) : 0
			
			runTitle = run.gameName()
			category = run.categoryName()
			let iconPtr = run.gameIconPtr()
			let iconlen = run.gameIconLen()
			if let img = Self.parseImageFromLiveSplit(ptr: iconPtr, len: iconlen) {
				gameIcon = img
			}
			
			platform = run.metadata().platformName()
			region = run.metadata().regionName()
			
			
			
			lsPointer = run.ptr
		}
		
	}
	
	
	private func parseBestSplits(run: Run, template: Bool) {
		let segCount = run.len()
		var i = 0
		var tsArray: [SplitTableRow] = []
		while i < segCount {
			
			let segName = run.segment(i).name()
			
			var newTS = TimeSplit(mil: 0)
			var newBest = TimeSplit(mil: 0)
			
			if !template {
				
				if let cTimeDouble = run.segment(i).personalBestSplitTime().realTime()?.totalSeconds() {
					newTS = TimeSplit(seconds: cTimeDouble)
				}
				
				let bestTS = run.segment(i).bestSegmentTime().realTime()?.totalSeconds()
				
				
				//Parse LiveSplit history
				let iter = run.segment(i).segmentHistory().iter()
				var last: Double? = nil
				var secondToLast: Double? = nil
				while (iter.next() != nil) {
					secondToLast = iter.next()?.time().realTime()?.totalSeconds()
					last = iter.next()?.time().realTime()?.totalSeconds()
				}
				newBest = TimeSplit(seconds: bestTS ?? 0)
				if i > 0 {
					newBest = newBest + tsArray[i - 1].bestSplit
				}
			}
			let iconPtr = run.segment(i).iconPtr()
			let iconLen = run.segment(i).iconLen()
			let img = Self.parseImageFromLiveSplit(ptr: iconPtr, len: iconLen)
			iconArray.append(img)
			
			let newRow = SplitTableRow(splitName: segName, bestSplit: newTS, currentSplit: TimeSplit(), previousSplit: TimeSplit(), previousBest: newBest, splitIcon: nil)
			tsArray.append(newRow)
			i = i + 1
		}
		if tsArray.count > 0 {
			self.splits = tsArray
		}
	}
	static func parseImageFromLiveSplit(ptr: UnsafeMutableRawPointer?, len: size_t) -> NSImage? {
		if let p = ptr {
			let data = Data(bytes: p, count: Int(len))
			if let img = NSImage(data: data) {
				return img
			}
		}
		return nil
	}
	///Creates a string that to be saved to a `.lss` file
	func liveSplitString() -> String {
		let run = Run()
		let segDel = "If you name a segment this it will be deleted"
		let blankSeg = Segment(segDel)
		var i = 0
		run.pushSegment(blankSeg)
		let lss = RunEditor(run)
		lss?.setGameName(runTitle ?? "")
		lss?.setCategoryName(category ?? " ")
		lss?.setPlatformName(platform ?? "")
		lss?.setRegionName(region ?? "")
		let _ = lss?.parseAndSetAttemptCount("\(attempts ?? 0)")
		
		if var giData = gameIcon?.tiffRepresentation {
			let giLen = giData.count
			let giPtr = giData.withUnsafeMutableBytes( { bytes in
				let UMBP = bytes.baseAddress
				lss?.setGameIcon(UMBP, giLen)
			})
		}
		i = 0
		while i < splits.count {
			lss?.insertSegmentBelow()
			let icon = icons[i]
			
			if var id = icon?.tiffRepresentation {
				let iconlen = id.count
				let iPtr = id.withUnsafeMutableBytes( { bytes in
					let UMBP = bytes.baseAddress
					lss?.activeSetIcon(UMBP, iconlen)
				})
			}
			
			lss?.activeSetName(splits[i].splitName)
			let ts = splits[i].bestSplit.shortTimeString
			lss?.activeParseAndSetSplitTime(ts)
			i = i + 1
		}
		lss?.selectOnly(0)
		lss?.removeSegments()
		run.ptr = lss?.ptr
		
		///For whatever reason, the expected way to save attempts to lss doesn't work, so I have to brute force it here.
		var returnString = run.saveAsLss()
		returnString = returnString.replacingOccurrences(of: "<AttemptCount>0</AttemptCount>", with: "<AttemptCount>\(attempts ?? 0)</AttemptCount>")
		return returnString
	}
	
	var cdata: Data?

}

extension ViewController {
	func loadLS(url: URL, asTemplate: Bool = false) {
		if let run = Run.parseFile(path: url.path, loadFiles: true) {
			self.run.setRun(run)
			if asTemplate {
				self.run.timer.resetHistories()
			}
			self.run.updateLayoutState()
		}
	}
}


extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}


//yourString.toImage() // it will convert String  to UIImage

extension String {
    func toImage() -> NSImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return NSImage(data: data)
        }
        return nil
    }
}
extension NSImage {
	//TODO: Us this when saving to LiveSplit
	func toLSImage(_ withImage: (UnsafeMutableRawPointer?, Int) -> ()) {
		if var giData = tiffRepresentation {
			let giLen = giData.count
			giData.withUnsafeMutableBytes( { bytes in
				let umbp = bytes.baseAddress
				withImage(umbp, giLen)
			})
		}
	}
}
