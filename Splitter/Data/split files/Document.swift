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

class Document: NSDocument {

	var infoFileName = "runInfo.json"
	var otherFileName = "otherthing.json"
	var gameIconFileName = "gameIcon.png"
	
	
	var cleanFileURL: String? {
		if let fURL = self.fileURL {
			return fURL.absoluteString.replacingOccurrences(of: "file://", with: "")
		} else {
			return nil
		}
	}
	
	
	var fileWrapperURL: String?
	var wrapper:FileWrapper?
	
	
	
	var runInfoData: runInfo?
	
	var gameIcon: NSImage?
	var iconArray: [NSImage?] = []
	
	
	
	override init() {
	    super.init()
		wrapper = try? fileWrapper(ofType: ".split")
		
		// Add your subclass-specific initialization here.
	}

	override class var autosavesInPlace: Bool {
		return false
	}
	
	var viewController: ViewController? {
		if let vc =  windowControllers.first?.contentViewController as? ViewController {
			return vc
		}
		return nil
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
			if let gi = self.gameIcon{
				vc.gameIcon = gi
			}
			
		}
		
		
	}
	
	override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		if let vc = viewController {
			let newRunInfo = vc.saveToRunInfo()
			let newJE = JSONEncoder()
			let cleanParentURL = url.deletingLastPathComponent().absoluteString.replacingOccurrences(of: "file://", with: "")
			let newFileName = url.lastPathComponent
			
			let parentFolder = try? Folder(path: cleanParentURL)

			let currentBundleFolder = try? parentFolder?.createSubfolderIfNeeded(withName: newFileName)


			if let dataToSave = try? newJE.encode(newRunInfo) {
				let runInfoFile = try? currentBundleFolder?.createFileIfNeeded(withName: "runInfo.json")
				try? runInfoFile?.write(dataToSave)
			}
			if vc.gameIcon != nil {
				if let tiff = vc.gameIcon?.tiffRepresentation {
					let gameIconFile = try? currentBundleFolder?.createFileIfNeeded(withName: "gameIcon.png")
					try? gameIconFile?.write(tiff)
				}
			} else {
				if ((try? currentBundleFolder?.containsFile(named: "gameIcon.png")) != nil) {
					try? currentBundleFolder?.file(named: "gameIcon.png").delete()
				}
			}
			let iconArray = vc.iconArray
			Swift.print("is IA empty? ", iconArray.isEmpty)
			if !iconArray.isEmpty {
				let runIconsFolder = try? currentBundleFolder?.createSubfolderIfNeeded(withName: "segIcons")
				var i = 0
				while i < iconArray.count {
					let icon = iconArray[i]
					if icon != nil {
						let newIconFile = try? runIconsFolder?.createFileIfNeeded(withName: "\(i).png")
						try? newIconFile?.write((icon?.tiffRepresentation!)!)
					} else {
						if let iconFile = try? runIconsFolder?.file(named: "\(i).png") {
							try? iconFile.delete()
						}
					}
					i = i + 1
				}
				if runIconsFolder?.files.count() == 0 {
					try? runIconsFolder?.delete()
				}
				
			} else {
				if let runIconsFolder = try? currentBundleFolder?.subfolder(named: "runicons") {
					try? runIconsFolder.delete()
				}
			}
			
			fileWrapperURL = url.absoluteString
			
			self.wrapper = recursiveFileWrapper(folder: currentBundleFolder!)
		}
		
		
		super.save(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
	}
	
	func recursiveFileWrapper(folder: Folder) -> FileWrapper {
		var fwDictionary: [String: FileWrapper] = [:]
		
		
		
		for file in folder.files {
			fwDictionary[file.name] = try? FileWrapper(regularFileWithContents: file.read())
		}
		for subfolder in folder.subfolders {
			fwDictionary[subfolder.name] = recursiveFileWrapper(folder: subfolder)
		}
		
		let wrap = FileWrapper(directoryWithFileWrappers: fwDictionary)
		return wrap
	}
	
	override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
		if let wrap = self.wrapper {
			return wrap
		}
		
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}
	
	override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
		let newURL = cleanFileURL
		
		let bundleFolder = try? Folder(path: newURL!)
		
		let runInfoFile = try? bundleFolder?.file(named: "runInfo.json")
		let iconFile = try? bundleFolder?.file(named: "gameIcon.png")
		let segIconFolder = try? bundleFolder?.subfolder(named: "segIcons")
		
		let newJD = JSONDecoder()
		
		if runInfoFile != nil {
			
			let newRunInfo = try? newJD.decode(runInfo.self, from: runInfoFile!.read())
			self.runInfoData = newRunInfo
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


}
