//
//  Composite.swift
//  Splitter
//
//  Created by Michael Berk on 2/10/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation

import Cocoa
import Files


class CompositeImport: NSObject, XMLParserDelegate {
	
	var data: Data!
	var path: String!
	
	func cImport() {
		path = "/Users/michaelberk/Documents/mario.timesplittracker"
		
//		let url = URL(fileURLWithPath: path)
//		let iFile = try? File(path: path)
//		var iData = try? iFile?.read()
//
//		data = iData
//		//Don't know why I need to do this twice, but I do.
//
//		let hand = FileHandle(forReadingAtPath: path)
////			let hand = FileHandle(forReadingAtPath: path)
//		 let handle64 = Int64(hand!.fileDescriptor)
			
//		let lssFile = try? File(path: path)
//		do {
//		var lssData = try lssFile?.read()
//		} catch {
//			print("error: ", error)
//		}
//		do {
//			let url = URL(fileURLWithPath: path)
//			let d = try Data(contentsOf: url)
//		} catch {
//			print("Error: ",error)
//		}
//
		
//		data = lssData!
		
//		let hey = LiveSplitCore.Run.parseFileHandle(<#T##handle: Int64##Int64#>, <#T##path: String##String#>, <#T##loadFiles: Bool##Bool#>)
		
		
		
		
		let hand = FileHandle(forReadingAtPath: path)
		let handle64 = Int64(hand!.fileDescriptor)
		let cRun = LiveSplitCore.Run.parseFileHandle(handle64, path, false)
		
		
//		let cRun = LiveSplitCore.Run.parseFileHandle(handle64, path, true)
		if cRun.parsedSuccessfully() {
			let run = cRun.unwrap()
			
			print("good")
		}
	}
}
