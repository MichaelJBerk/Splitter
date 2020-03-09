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




class LiveSplit: NSObject, XMLParserDelegate {
	
	var path: String!
	var data: Data!
	var splits: [splitTableRow] = []
	var runTitle: String?
	var category: String?
	var attempts: Int?
	var platform: String?
	var region: String?
	var gameVersion: String?
	
	var startDate: String?
	var endDate: String?
	
	var lsPointer: UnsafeMutableRawPointer?
	
	func displayImportDialog() {
		
		let dialog = NSOpenPanel();
		dialog.title                   = "Choose a .lss file";
		dialog.showsResizeIndicator    = true;
		dialog.showsHiddenFiles        = false;
		dialog.canChooseDirectories    = true;
		dialog.canCreateDirectories    = true;
		dialog.allowsMultipleSelection = false;
		dialog.allowedFileTypes        = ["lss"];

		if (dialog.runModal() == NSApplication.ModalResponse.OK) {
			let result = dialog.url // Pathname of the file
			path = result?.path
		}
		
		
	}
	func parseLivesplit() {
		
		let lssFile = try? File(path: path)
		var lssData = try? lssFile?.read()
		data = lssData!
		
		let hand = FileHandle(forReadingAtPath: path)
		let handle64 = Int64(hand!.fileDescriptor)
		let cRun = LiveSplitCore.Run.parseFileHandle(handle64, path, true)
		
		if cRun.parsedSuccessfully() {
			let run = cRun.unwrap()
			parseBestSplits(run: run)
			
			runTitle = run.gameName()
			category = run.categoryName()
			attempts = Int(run.attemptCount())
			platform = run.metadata().platformName()
			region = run.metadata().regionName()
			
			lsPointer = run.ptr
		}
		
		let par = XMLParser(data: lssData!)
		par.delegate = self
		par.parse()
		
		
	}
	
	
	func parseBestSplits(run: LiveSplitCore.Run) {
		
		let segCount = run.len()
		var i = 0
		var tsArray: [splitTableRow] = []
		while i < segCount {
			
			let segName = run.segment(i).name()
			
			var newTS = TimeSplit(mil: 0)
			let hey = run.segment(i).bestSegmentTime()
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
			
			
			var newBest = TimeSplit(seconds: bestTS ?? 0)
			if i > 0 {
				newBest = newBest + tsArray[i - 1].bestSplit
			}
			
//			let newRow = splitTableRow(splitName: segName, bestSplit: TimeSplit(), currentSplit: TimeSplit(), previousSplit: TimeSplit(), previousBest: TimeSplit())
			let newRow = splitTableRow(splitName: segName, bestSplit: newTS, currentSplit: TimeSplit(), previousSplit: TimeSplit(), previousBest: newBest, splitIcon: nil)
			tsArray.append(newRow)
			i = i + 1
		}
		if tsArray.count > 0 {
			self.splits = tsArray
		}
	}
	
	func liveSplitString() -> String {
//		var run = LiveSplitCore.Run(ptr: lsPointer)
		var run = LiveSplitCore.Run()
		
		
		var segDel = "If you name a segment this it will be deleted"
//		var t = LiveSplitCore.Timer(c)
//		print(c.ptr)
//		run.ptr = lsPointer
		var blankSeg = LiveSplitCore.Segment(segDel)
		
//		run.pushSegment(blankSeg)
		var i = 0
		while i < splits.count {
			
			var seg = LiveSplitCore.Segment(splits[i].splitName)
			run.pushSegment(seg)
//			lss?.insertSegmentBelow()
			i = i + 1
		}
		
		
		var lss = LiveSplitCore.RunEditor(run)
		lss?.setGameName(runTitle ?? "")
		lss?.setCategoryName(category ?? "")
		lss?.setPlatformName(platform ?? "")
		lss?.setRegionName(region ?? "")
		lss?.parseAndSetAttemptCount("\(attempts)")
		
		i = 0
		while i < splits.count {
			lss?.selectOnly(i)
			lss?.activeParseAndSetBestSegmentTime(splits[i].bestSplit.timeString)
			i = i + 1
		}
//		hey.
		
		
		
		
//		var hey = LiveSplitCoreNative.new
		
		
//		let thing = LiveSplitCore.Run.Sav
		
//		print(lss?.ptr)
//		print(c.ptr)
//		print(p)
//		lss?.close()
		
		
//		var newPtr = withUnsafeMutablePointer(to: &c) {$0}
//		var p2 = UnsafeMutableRawPointer(newPtr)
		
//		unsafeDowncast(c as AnyObject, to: UnsafeMutableRawPointer)
//		var ptr2 = newPtr as! UnsafeMutableRawPointer
		
//		run.ptr = self.lsPointer
		run.ptr = lss?.ptr
		return run.saveAsLss()
		
		
	}
	

	
	public var img: NSImage? //{

	
	var segment: Int = -1
	var element: String?
	public var iconArray: [NSImage?] = []
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		self.element = elementName
		print(elementName)
		if elementName == "Segment" {
			segment = segment + 1
		}
	}

	func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
		self.cdata = CDATABlock
		print(CDATABlock)

//		print(element)
		let hand = FileHandle(forReadingAtPath: path)
		let handle64 = Int64(hand!.fileDescriptor)
		let cRun = LiveSplitCore.Run.parseFileHandle(handle64, path, true)

		if cRun.parsedSuccessfully() {
			let run = cRun.unwrap()
			if element == "GameIcon" {
				let imgPtr = run.gameIconPtr()!
				let imgLen = run.gameIconLen()
				let imgD = Data(bytes: imgPtr, count: imgLen)
				let i = NSImage(data: imgD)

				self.img = i
			}
			if element == "Icon" {
				let seg = run.segment(self.segment)
				let imgPtr = seg.iconPtr()!
				let imglen = seg.iconLen()


				let imgD = Data(bytes: imgPtr, count: imglen)
				let i = NSImage(data: imgD)
				iconArray.append(i)



			}
		}

//		print(parser.lineNumber)




	}
	
	var cdata: Data?

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

