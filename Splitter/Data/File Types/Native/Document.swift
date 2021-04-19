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
import SwiftyJSON

class Document: SplitterDocBundle {

	var infoFileName = "runInfo.json"
	var otherFileName = "otherthing.json"
	var gameIconFileName = "gameIcon.png"
	
	var runInfoData: runInfo?
	var appearance: splitterAppearance?
	var data: Data?
	
	var gameIcon: NSImage?
	var iconArray: [NSImage?] = []
	var id: String? = nil
	var versionUsed: Double?
	var run: SplitterRun?
	
	override init() {
	    super.init()
		wrapper = try? fileWrapper(ofType: ".split")
		// Add your subclass-specific initialization here.
	}
	
	
	override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
		windowController.windowFrameAutosaveName = NSWindow.FrameAutosaveName(id!)
	}
	
	/**
	# How loading a file works
	- Read the file in `read`
	- Save this data to a property
	- Hand it to the VC in `makeWindowControllers`
	
	*/
	
	override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
		let appearanceFile = try? bundleFolder?.file(named: "appearance.json")
		if appearanceFile != nil {
			if let data = try? appearanceFile?.read(), let json = try? JSON(data: data) {
				let newAppearance = splitterAppearance(json: json)
				self.appearance = newAppearance
			}
		}
		
		var beforeSplitter4 = false
		if let runInfoFile = try? bundleFolder?.file(named: "runInfo.json") {
			if let data = try? runInfoFile.read(), let json = try? JSON(data: data) {
				//Check which version of Splitter saved the file
				versionUsed = json["version"].doubleValue
				self.runInfoData = splitToJSON().runInfoFromJSON(json: json)
				if versionUsed! < 4 {
					beforeSplitter4 = true
				}
			}
		}
		
		if beforeSplitter4 {
			readOlderThanSplitter4(from: fileWrapper)
		} else {
			if let splitsFile = try? bundleFolder?.file(named: "splits.lss") {
				run = SplitterRun(run: Run())
				_ = run?.timer.lsTimer.setRun(Run.parseFile(path: splitsFile.path, loadFiles: true)!)
			}
			if let layoutFile = try? bundleFolder?.file(named: "layout.lsl"),
			   let json = try? layoutFile.readAsString() {
				run?.layout = Layout.parseJson(json)!
			}
		}
	}
	
	func readOlderThanSplitter4(from fileWrapper: FileWrapper) {
		let iconFile = try? bundleFolder?.file(named: "gameIcon.png")
		let segIconFolder = try? bundleFolder?.subfolder(named: "segIcons")
		
		if iconFile != nil {
			self.gameIcon = try? NSImage(data: iconFile!.read())
		}
		if segIconFolder != nil {
			var i = 0
			iconArray = []
			var currentImage: NSImage?
			if let segs = runInfoData?.segments?.count {
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
	
	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)
		let vc = windowController.contentViewController as! ViewController
		if let ri = self.runInfoData {
			vc.runInfoData = ri
			if let v = versionUsed, v < 4 {
				vc.loadFromOldRunInfo(icons: iconArray)
			} else {
				vc.loadFromRunInfo()
//				if let url = self.fileURL {
//					vc.loadLS(url: url)
//				}
				if let run = self.run {
					vc.run = run
					vc.run.updateLayoutState()
				}
			}
			vc.appearance = appearance
			if let gi = self.gameIcon {
				vc.run.gameIcon = gi
			}
		}
	}
	
	override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		if let version = versionUsed, version < 4 {
			if !Settings.warningSuppresed(.overwritingSplitsFromOlderVersion) {
				if !saveOlderVersionAlert() {
					return
				}
				//TODO: Migrate
			}
		}
		determineSave(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
		
	}

	override func read(from data: Data, ofType typeName: String) throws {
		// Insert code here to read your document from the given data ofr the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override read(from:ofType:) instead.
		// If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}


}
