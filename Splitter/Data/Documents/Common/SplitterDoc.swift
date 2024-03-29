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
	
	static func fileType(for fileExtension: String) -> DocFileType {
		//For some reason, the `NSDocument.save` method's `fileType` parameter can either return the actual file extension or the file name description, so we need to account for both possibilities.
		switch fileExtension {
		case "split", splitFile.rawValue:
			return .splitFile
		case "lss", liveSplit.rawValue:
			return .liveSplit
		case "json", splitsioFile.rawValue:
			return .splitsioFile
		default:
			return .splitFile
		}
	}
}

///A filetype supported by Splitter
/**
- Note:
This class contains the logic for saving each supported file type, since otherwise, it wouldn't be eaisliy possible to save each file from the same Save panel.
 
 ### How File Loading works:
 The following applies to all filetypes:
 - The subclass' `makeWindowControllers()` method is called, which calls ``SplitterDoc/loadViewController()``
 - ``loadViewController()`` creates a window controller, and loads the VC from the storyboard
	- Once loaded from storyboard, ``ViewController/viewDidLoad()`` is called
 - 
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
	
	func loadViewController() -> (windowController: NSWindowController, vc: ViewController){
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		windowController.window?.delegate = self
		self.addWindowController(windowController)
		let vc = windowController.contentViewController as! ViewController
		vc.document = self
		return (windowController, vc)
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
			let app = SplitterAppearance(viewController:vc)
			let newJE = JSONEncoder()
			if let sApp = try? newJE.encode(app) {
				return sApp
			}
		}
		return nil
	}
	
	//MARK: - Saving Files
	
	func saveOlderVersionAlert() -> Bool {
		
		let alert = NSAlert()
		let alertMessage = "\"\(displayName!)\" was created using an older version of Splitter."
		let informText = "Saving this run as a Split file using this version of Splitter will update it, making the file unusable in versions of Splitter prior to 4.0"
		alert.addButton(withTitle: "Save")
		alert.addButton(withTitle: "Cancel")
		alert.showsSuppressionButton = true
		
		alert.alertStyle = .warning
		alert.messageText = alertMessage
		alert.informativeText = informText
		
		let response = alert.runModal()
		if alert.suppressionButton!.state == .on {
			Settings.setWarning(.overwritingSplitsFromOlderVersion, suppresed: true)
		}
		switch response {
		case .cancel:
			return false
		case .alertFirstButtonReturn:
			return true
		default:
			return false
		}
	}
	
	///Saves a `.split` file
	func saveSplitFile(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		if let vc = viewController {
			let newRunInfo = vc.saveToRunInfo()
			let cleanParentURL = url.deletingLastPathComponent().path

			let newFileName = url.lastPathComponent
			
			let parentFolder = try? Folder(path: cleanParentURL)

			let currentBundleFolder = try? parentFolder?.createSubfolderIfNeeded(withName: newFileName)
			
			let newJE = JSONEncoder()
			
			//Encode RunInfo
			if let dataToSave = try? newJE.encode(newRunInfo) {
				let runInfoFile = try? currentBundleFolder?.createFileIfNeeded(withName: "runInfo.json")
				try? runInfoFile?.write(dataToSave)
			}
			
			//Encode Appearance
			if let splitterAppData = encodeSplitterAppearance() {
				let splitterAppFile = try? currentBundleFolder?.createFileIfNeeded(withName: "appearance.json")
				try? splitterAppFile?.write(splitterAppData)
			}
			
			//Save Background Image
			if let backgroundImage = vc.run.backgroundImage, let imageData = backgroundImage.tiffRepresentation {
				let backgroundImageFile = try? currentBundleFolder?.createFileIfNeeded(at: "bgImage.png")
				try? backgroundImageFile?.write(imageData)
			} else {
				if let bgImageFile = try? currentBundleFolder?.file(named: "bgImage.png") {
					try? bgImageFile.delete()
				}
			}
			
			let lssString = vc.run.saveToLSS()
			if let splitsFile = try? currentBundleFolder?.createFileIfNeeded(withName: "splits.lss") {
				try? splitsFile.write(lssString)
			}
			let lslJSONString = vc.run.layoutToJSON()
			if let layoutFile = try? currentBundleFolder?.createFileIfNeeded(withName: "layout.lsl") {
				try? layoutFile.write(lslJSONString)
			}
			
			
			fileWrapperURL = url.absoluteString
			if let currentBundleFolder = currentBundleFolder {
				self.wrapper = folderToFileWrapper(folder: currentBundleFolder)
			}
		} else {
		}
		super.save(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
		windowControllers.forEach({$0.window?.isDocumentEdited = false})
	}
	
	///Saves a `.lss` file
	func saveLiveSplitFile(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		if let vc = viewController {
			let fileString = vc.run.saveToLSS()
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
			if let sioString = vc.splitsIOUploader.makeSplitsIOJSON() {
				fileWrapperURL = url.absoluteString
				
				if let sioData = sioString.data(using: .utf8) {
					wrapper = FileWrapper(regularFileWithContents: sioData)
				}
				
			}
		}
		super.save(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
	}
	
	
	
	///Determines which format to save to
	func determineSave(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		let fileType = DocFileType.fileType(for: typeName)
		switch fileType {
		case DocFileType.splitFile:
			saveSplitFile(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: 	contextInfo)
		case DocFileType.liveSplit:
			saveLiveSplitFile(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: 	contextInfo)
		case DocFileType.splitsioFile:
			saveSplitsio(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
		}
		
	}
}

extension SplitterDoc: NSWindowDelegate {
	func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
		return undoManager
	}
}
