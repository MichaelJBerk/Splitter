//
//  SplitterDocBundle.swift
//  Splitter
//
//  Created by Michael Berk on 2/12/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import Files


///Class for Splitter's Document Bundles
class SplitterDocBundle: SplitterDoc {
	
	var bundleFolder: Folder? {
		if let path = fileURL?.path {
			return try? Folder(path: path)
		}
		return nil
	}
	
	override internal var file: File? {
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
}
