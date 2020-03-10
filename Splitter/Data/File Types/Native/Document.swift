//
//  Document.swift
//  Splitter
//
//  Created by Michael Berk on 12/22/19.
//  Copyright © 2019 Michael Berk. All rights reserved.
//

///This file handles the code for handling .split files

import Cocoa
import AppKit
import Files

class Document: SplitterDocBundle {

	var infoFileName = "runInfo.json"
	var otherFileName = "otherthing.json"
	var gameIconFileName = "gameIcon.png"
	
	var runInfoData: runInfo?
	var appearance: splitterAppearance?
	
	var gameIcon: NSImage?
	var iconArray: [NSImage?] = []
	
	override init() {
	    super.init()
		wrapper = try? fileWrapper(ofType: ".split")
		
		// Add your subclass-specific initialization here.
	}

	

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		
		
		
		self.addWindowController(windowController)
		let vc = windowController.contentViewController as! ViewController
		if let ri = self.runInfoData {
			vc.runInfoData = ri
			vc.loadFromRunInfo(icons: iconArray)
			vc.appearance = appearance
			if let gi = self.gameIcon{
				vc.gameIcon = gi
			}
			
		}
		
		
	}
	
	override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		if typeName == "Split File" {
			saveSplitFile(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: 	contextInfo)
		} else {
			saveLiveSplitFile(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: 	contextInfo)
		}
		
		
	}
	
	
	
	
	
	override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
		let newURL = cleanFileURL
		
//		let bundleFolder = try? Folder(path: newURL!)
		
		let runInfoFile = try? bundleFolder?.file(named: "runInfo.json")
		let appearanceFile = try? bundleFolder?.file(named: "appearance.json")
		let iconFile = try? bundleFolder?.file(named: "gameIcon.png")
		let segIconFolder = try? bundleFolder?.subfolder(named: "segIcons")
		
		let newJD = JSONDecoder()
		
		if runInfoFile != nil {
			
			let newRunInfo = try? newJD.decode(runInfo.self, from: runInfoFile!.read())
			self.runInfoData = newRunInfo
		}
		
		if appearanceFile != nil {
			let newAppearance = try? newJD.decode(splitterAppearance.self, from: appearanceFile!.read())
			self.appearance = newAppearance
			
		}
		
		
		if iconFile != nil {
			self.gameIcon = try? NSImage(data: iconFile!.read())
			
		}
		
		if segIconFolder != nil {
			var i = 0
			iconArray = []
			var currentImage: NSImage?
			if let segs = runInfoData?.segments.count {
				while i < segs {
					currentImage = nil
					if let iconFile = try? segIconFolder?.file(named: "\(i).png") {
						if let image = try? NSImage(data: iconFile.read()) {
							currentImage = image
						}
					}
					iconArray.append(currentImage)
					i = i + 1
				}
			}
		}
		
		
		wrapper =  fileWrapper
		
	}

	override func read(from data: Data, ofType typeName: String) throws {
		// Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
		// Alx5ternatively, you could remove this method and override read(from:ofType:) instead.
		// If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	
	override func close() {
		
		super.close()
	}


}
