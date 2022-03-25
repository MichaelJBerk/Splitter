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
import LiveSplitKit

class Document: SplitterDocBundle {

	let infoFileName = "runInfo.json"
	let splitsFileName = "splits.lss"
	let gameIconFileName = "gameIcon.png"
	let appearanceFileName = "appearance.json"
	let layoutFileName = "layout.lsl"
	let bgImageName = "bgImage.png"
	
	var runInfoData: runInfo?
	var appearance: SplitterAppearance?
	var data: Data?
	
	var gameIcon: NSImage?
	var iconArray: [NSImage?] = []
	var id: String? = nil
	var versionUsed: Double?
	var run: SplitterRun?
	var splitsData: Data!

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
		if let appearanceFile = fileWrapper.fileWrappers?[self.appearanceFileName],
		   let data = appearanceFile.regularFileContents,
		   let json = try? JSON(data: data){
			let newAppearance = SplitterAppearance(json: json)
			self.appearance = newAppearance
		}
		
		var beforeSplitter4 = false
		if let runInfoFile = fileWrapper.fileWrappers?[infoFileName],
		   let data = runInfoFile.regularFileContents,
		   let json = try? JSON(data: data) {
			let verString = json["version"].stringValue
			let verSplit = verString.split(separator: ".")
			versionUsed = Double(verSplit[0])
			self.runInfoData = splitToJSON().runInfoFromJSON(json: json)
			if versionUsed! < 4 {
				beforeSplitter4 = true
			}
		}
		if beforeSplitter4 {
			readOlderThanSplitter4(from: fileWrapper)
		} else {
			if let splitsFile = fileWrapper.fileWrappers?[splitsFileName],
			   let data = splitsFile.regularFileContents {
				self.splitsData = data
				splitsData.withUnsafeMutableBytes({ (ptr: UnsafeMutableRawBufferPointer) in
					
					let lsRun = Run.parse(ptr.baseAddress, ptr.count, "", true)
					if lsRun.parsedSuccessfully() {
						run = SplitterRun(run: lsRun.unwrap())
						
						run?.document = self
					} else {
						fatalError()
					}
				})
			}
			
			if let layoutFile = fileWrapper.fileWrappers?[layoutFileName],
			   let layoutData = layoutFile.regularFileContents,
			   let json = String(data: layoutData, encoding: .utf8) {
				run?.layout = Layout.parseJson(json)!
				//Add The title/icon columns if from Splitter < 5.0
				//Need to do this now, since even though this is done when loading the run, we have just changed the layout to be the layout in the Split file, which would remove the columns.
				if versionUsed ?? 0 < 5 {
					if let layout = LayoutEditor(run!.layout) {
						run?.layout = layout.close()
					}
				}
			}

			if let bgImage = fileWrapper.fileWrappers?[bgImageName],
			   let data = bgImage.regularFileContents {
				undoManager?.disableUndoRegistration()
				run?.backgroundImage = NSImage(data: data)
				undoManager?.enableUndoRegistration()
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
		
		let load = loadViewController()
		let vc = load.vc
		vc.document = self
		if let run = run {
			
			vc.run = run
		}
		if let ri = self.runInfoData {
			vc.runInfoData = ri
			vc.appearance = appearance
		}
	}
	
	override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		if let version = versionUsed, version < 4 {
			if !Settings.warningSuppresed(.overwritingSplitsFromOlderVersion) {
				if !saveOlderVersionAlert() {
					return
				}
				//TODO: Migrate
				if let iconFile = try? bundleFolder?.file(named: "gameIcon.png") {
					try? iconFile.delete()
				}
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
