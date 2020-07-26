//
//  SplitterDoc.swift
//  Splitter
//
//  Created by Michael Berk on 2/12/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import Files
import SplitsIOKit

enum DocFileType: String {
	//public static let
	case splitFile = "Split File"
	case liveSplit = "LiveSplit File"
	case splitsioFile = "Splits.io File"
	
	static func fileExtension(fileExtension: String) -> DocFileType {
		switch fileExtension {
		case "split":
			return .splitFile
		case "lss":
			return .liveSplit
		case "json":
			return .splitsioFile
		default:
			return .splitFile
		}
	}
}



///A filetype supported by Splitter
/**
- Note:
This class contains the logic for saving each supoorted file type, since otherwise, it wouldn't be eaisliy possible to save each file from the same Save panel.
*/
class SplitterDoc: NSDocument {
	
	///Writes the textual representations of the given items into the standard output.
	///
	///This is only here because swift's default `print` command is overriden by `NSDocument`'s `print` command.
	func print(_ i: Any?) {
		Swift.print(i as Any)
	}
	
	///A`File` that represents the document
	var file: File? {
		if let path = fileURL?.path {
			return try? File(path: path)
		}
		return nil
	}

	/// Returns the file's URL in a form that can be loaded properly
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
	
	///ViewController of the file
	var viewController: ViewController? {
		if let vc =  windowControllers.first?.contentViewController as? ViewController {
			return vc
		}
		return nil
	}
	///Returns the types that Splitter supports
	override func writableTypes(for saveOperation: NSDocument.SaveOperationType) -> [String] {
		return [DocFileType.splitFile.rawValue, DocFileType.liveSplit.rawValue, DocFileType.splitsioFile.rawValue]
	}
	///Folder of the File Bundle. Used for `.split` files
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
	
	
	override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
		if let wrap = self.wrapper {
			return wrap
		}
		
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}
	
	///Converts the window's setting to the data to be written to an `appearance.json` file
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
	
	//MARK: - Saving Files

//	
	///Saves a `.split` file
	func saveSplitFile(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		if let vc = viewController {
			let newRunInfo = vc.saveToRunInfo()
			let newJE = JSONEncoder()
			let cleanParentURL = url.deletingLastPathComponent().path

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
			if let currentBundleFolder = currentBundleFolder {
				self.wrapper = folderToFileWrapper(folder: currentBundleFolder)
			}
		} else {
		}
		super.save(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
	}
	
	///Saves a `.lss` file
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
				fileWrapperURL = url.absoluteString
				wrapper = FileWrapper(regularFileWithContents: lsData)
				
			}
		}
		super.save(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
	}
	///Saves a file in the  Splits.io Exchange Format (`.json`)
	func saveSplitsio(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		if let vc = viewController {
			let timer = SplitsIOTimer(shortname: "Splitter", longname: "Splitter", website: "https://mberk.com/splitter", version: "v\(otherConstants.version) (\(otherConstants.build))")
			let game = SplitsIORunCategory(longname: vc.runTitle, shortname: nil, links: nil)
			let cat = SplitsIORunCategory(longname: vc.category, shortname: nil, links: nil)
			var cs: [SplitsIOSegment] = []
			for s in vc.currentSplits {
				let best = s.bestSplit.TSToMil()
				let dur = SplitsIOBestDuration(realtimeMS: best, gametimeMS: best)
				let seg = SplitsIOSegment(name: s.splitName, endedAt: dur, bestDuration: dur, isSkipped: nil, histories: nil)
				cs.append(seg)
			}
			let sIO = SplitsIOExchangeFormat(schemaVersion: "v1.0.1", links: nil, timer: timer, attempts: nil, game: game, category: cat, runners: nil, segments: cs)
			if var sioString = try? sIO.jsonString() {
				fileWrapperURL = url.absoluteString
				sioString = sioString.replacingOccurrences(of: "schemaVersion", with: "_schemaVersion")
				if let sioData = sioString.data(using: .utf8) {
					wrapper = FileWrapper(regularFileWithContents: sioData)
				}
				
			}
		}
		super.save(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
	}
	
	///Determines which format to save to
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
}
