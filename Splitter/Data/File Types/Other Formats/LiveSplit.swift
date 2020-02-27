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
	var loadedSplits: [splitTableRow] = []
	var gameName: String?
	var subtitle: String?
	
	func displayImportDialog() {
		
		let dialog = NSOpenPanel();
		dialog.title                   = "Choose a .lss file";
		dialog.showsResizeIndicator    = true;
		dialog.showsHiddenFiles        = false;
		dialog.canChooseDirectories    = true;
		dialog.canCreateDirectories    = true;
		dialog.allowsMultipleSelection = false;
		dialog.allowedFileTypes        = ["lss"];

//
		if (dialog.runModal() == NSApplication.ModalResponse.OK) {
			let result = dialog.url // Pathname of the file
			path = result?.path
		}
		
		
	}
	func parseLivesplit() {
//		path = "/Users/michaelberk/Documents/Super Mario Odyssey.lss"  //result!.path
//		path = "/Users/michaelberk/Documents/KIU.lss"
		

		let lssFile = try? File(path: path)
		var lssData = try? lssFile?.read()
		data = lssData!
		
		let hand = FileHandle(forReadingAtPath: path)
		let handle64 = Int64(hand!.fileDescriptor)
		let cRun = LiveSplitCore.Run.parseFileHandle(handle64, path, true)
		
		if cRun.parsedSuccessfully() {
			let run = cRun.unwrap()
			let segCount = run.len()
			var i = 0
			var tsArray: [splitTableRow] = []
			while i < segCount {
				let segName = run.segment(i).name()
				print(run.segment(i).personalBestSplitTime().realTime()?.totalSeconds())
				var newTS = TimeSplit(mil: 0)
				if let bestTimeDouble = run.segment(i).personalBestSplitTime().realTime()?.totalSeconds() {
					newTS = TimeSplit(seconds: bestTimeDouble)
				}
				let newRow = splitTableRow(splitName: segName, bestSplit: newTS, currentSplit: TimeSplit(mil: 0), previousBest: newTS, splitIcon: nil)
				tsArray.append(newRow)
//				tsArray.append(newTS)
				i = i + 1
			}
			gameName = run.gameName()
			subtitle = run.categoryName()
			if tsArray.count > 0 {
				self.loadedSplits = tsArray
			}
			
			
			
			
		}
		
		let par = XMLParser(data: lssData!)
		par.delegate = self
		par.parse()
		
	
		
		
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
		
		print(parser.lineNumber)
		
		
		
		
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

