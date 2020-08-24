//
//  lss.swift
//  Splitter
//
//  Created by Michael Berk on 2/10/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import Files

class lss: SplitterDoc {

    /*
    override var windowNibName: String? {
        // Override returning the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
        return "lss"
    }
    */

    override func windowControllerDidLoadNib(_ aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
		
		
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }
	
	var tempURL: URL?
	private var urlToLoad: URL? {
		if let url = tempURL {
			return url
		}
		else if let url = fileURL {
			return url
		}
			return nil
	}
	
	override func makeWindowControllers() {
		Swift.print(writableTypes(for: .saveOperation))
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)
		let vc = windowController.contentViewController as! ViewController
		vc.setColorForControls()
		if let url = urlToLoad {
			let ls = LiveSplit()
			ls.path = url.path
			vc.loadLS(ls: ls)
		}
	}
	
	override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		determineSave(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: 	contextInfo)
	}
	
	override func close() {
		super.close()
		if let tempURL = tempURL {
			let tempFile = try? File(path: tempURL.path)
			try? tempFile?.delete()
		}
		
	}
	
	
	
    override func data(ofType typeName: String) throws -> Data {
//		
//		
//		
//		
//		
//		
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.  If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
		if data == nil {
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}
    }

}
