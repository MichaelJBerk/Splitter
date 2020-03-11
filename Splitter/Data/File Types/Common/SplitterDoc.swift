//
//  SplitterDoc.swift
//  Splitter
//
//  Created by Michael Berk on 2/12/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import Files

enum DocFileType: String {
	//public static let
	case splitFile = "Split File"
	case liveSplit = "LiveSplit File"
	case splitsioFile = "Splits.io File"
}


///A filetype supported by Splitter
class SplitterDoc: NSDocument {
	
	
	func print(_ i: Any?) {
		Swift.print(i)
	}
	
	var file: File? {
		if let path = fileURL?.path {
			return try? File(path: path)
		}
		return nil
	}


	var cleanFileURL: String? {
		if let fURL = self.fileURL {
			return fURL.path.replacingOccurrences(of: "file://", with: "")
		} else {
			return nil
		}
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
	
	override func writableTypes(for saveOperation: NSDocument.SaveOperationType) -> [String] {
		return [DocFileType.splitFile.rawValue, DocFileType.liveSplit.rawValue, DocFileType.splitsioFile.rawValue]
	}
	
	var bundleFolder: Folder? {
		if let path = fileURL?.path {
			return try? Folder(path: path)
		}
		return nil
	}
	
	var fileWrapperURL: String?
	var wrapper:FileWrapper?

	
	///Converts a Folder, with all its subfolders, to a FIleWrapper
	func folderToFileWrapper(folder: Folder) -> FileWrapper {
		var fwDictionary: [String: FileWrapper] = [:]
		
		
		
		for file in folder.files {
			fwDictionary[file.name] = try? FileWrapper(regularFileWithContents: file.read())
		}
		for subfolder in folder.subfolders {
			fwDictionary[subfolder.name] = folderToFileWrapper(folder: subfolder)
		}
		
		let wrap = FileWrapper(directoryWithFileWrappers: fwDictionary)
		return wrap
	}
	
	
    /*
    override var windowNibName: String? {
        // Override returning the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
        return "SplitterDocBundle"
    }
    */
	
	
	
	override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
		if let wrap = self.wrapper {
			return wrap
		}
		
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}
	
	func encodeSplitterAppearance() -> Data? {
		if let vc = viewController {
			let app = splitterAppearance(viewController:vc)
			let newJE = JSONEncoder()
			if let sApp = try? newJE.encode(app) {
				return sApp
			}
			
		}
		return nil
	}
	
	
	func saveSplitFile(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		if let vc = viewController {
			let newRunInfo = vc.saveToRunInfo()
			let newJE = JSONEncoder()
			let cleanParentURL = url.deletingLastPathComponent().path//.absoluteString.replacingOccurrences(of: "file://", with: "")

			let newFileName = url.lastPathComponent
			
			let parentFolder = try? Folder(path: cleanParentURL)

			let currentBundleFolder = try? parentFolder?.createSubfolderIfNeeded(withName: newFileName)


			if let dataToSave = try? newJE.encode(newRunInfo) {
				let runInfoFile = try? currentBundleFolder?.createFileIfNeeded(withName: "runInfo.json")
				try? runInfoFile?.write(dataToSave)
			}
			
			if let splitterAppData = encodeSplitterAppearance() {
				let splitterAppFile = try? currentBundleFolder?.createFileIfNeeded(withName: "appearance.json")
				try? splitterAppFile?.write(splitterAppData)
			}
			
			
			if vc.gameIcon != nil {
				if let tiff = vc.gameIcon?.tiffRepresentation {
					let gameIconFile = try? currentBundleFolder?.createFileIfNeeded(withName: "gameIcon.png")
					try? gameIconFile?.write(tiff)
				}
			} else {
				if currentBundleFolder?.containsFile(named: "gameIcon.png") != nil {
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
			
			self.wrapper = folderToFileWrapper(folder: currentBundleFolder!)
		} else {
			
		}
		super.save(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
	}
	
	func saveLiveSplitFile(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		let ls = LiveSplit()
		if let vc = viewController {
			ls.runTitle = vc.runTitle
			ls.category = vc.category
			ls.attempts = vc.attempts
			ls.platform = vc.platform
			ls.gameVersion = vc.gameVersion
			ls.region = vc.gameRegion
			ls.splits = vc.currentSplits
			ls.lsPointer = vc.lsPointer
			ls.icons = vc.iconArray
			ls.gameIcon = vc.gameIcon
			let fileString = ls.liveSplitString()
			if let lsData = fileString.data(using: .utf8) {
				print("\(url.path)")
				
				var lssFolder = try? Folder(path: url.deletingLastPathComponent().path)
				var lssFile = try? lssFolder?.createFileIfNeeded(at: url.lastPathComponent)
				try? lssFile?.write(lsData)
				
			}
		}
	}
		
	func saveSplitsio(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		if let vc = viewController {
			let timer = SplitsIOTimer(shortname: "Splitter", longname: "Splitter", website: "https://mberk.com/splitter", version: "v\(otherConstants.version) (\(otherConstants.build))")
			let game = SplitsIOCategory(longname: vc.runTitle, shortname: nil, links: nil)
			let cat = SplitsIOCategory(longname: vc.category, shortname: nil, links: nil)
			var cs: [SplitsIOSegment] = []
			for s in vc.currentSplits {
				let best = s.bestSplit.TSToMil()
				let dur = SplitsIOBestDuration(realtimeMS: best, gametimeMS: best)
				let seg = SplitsIOSegment(name: s.splitName, endedAt: dur, bestDuration: dur, isSkipped: nil, histories: nil)
				cs.append(seg)
			}
			let sIO = SplitsIOExchangeFormat(schemaVersion: "v1.0.1", links: nil, timer: timer, attempts: nil, game: game, category: cat, runners: nil, segments: cs)
			if let sioData = try? sIO.jsonData() {
				let sioFolder = try? Folder(path: url.deletingLastPathComponent().path)
				let sioFile = try? sioFolder?.createFileIfNeeded(at: url.lastPathComponent)
				try? sioFile?.write(sioData)
			}
		}
	}
		
	func determineSave(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		switch typeName {
		case DocFileType.splitFile.rawValue:
			saveSplitFile(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: 	contextInfo)
		case DocFileType.liveSplit.rawValue:
			saveLiveSplitFile(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: 	contextInfo)
		case DocFileType.splitsioFile.rawValue:
			saveSplitsio(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
		default:
			break
		}
		
	}
	
//	override func data(ofType typeName: String) throws -> Data {
//
//	}
	
    /*
    override var windowNibName: String? {
        // Override returning the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
        return "SplitterDoc"
    }
    */
	
	

//    override func windowControllerDidLoadNib(_ aController: NSWindowController) {
//        super.windowControllerDidLoadNib(aController)
//        // Add any code here that needs to be executed once the windowController has loaded the document's window.
//    }

//    override func data(ofType typeName: String) throws -> Data {
//        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
//        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
//        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//    }
//    
//    override func read(from data: Data, ofType typeName: String) throws {
//        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
//        // Alternatively, you could remove this method and override read(from:ofType:) instead.  If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
//        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//    }

}
