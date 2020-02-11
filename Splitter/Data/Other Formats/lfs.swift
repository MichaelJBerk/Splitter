//
//  lfs.swift
//  Splitter
//
//  Created by Michael Berk on 2/10/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import Files

class lfs: NSDocument {

    /*
    override var windowNibName: String? {
        // Override returning the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
        return "lfs"
    }
    */
	
	override func makeWindowControllers() {
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)
		let vc = windowController.contentViewController as! ViewController
		
		if let url = self.fileURL {
			let ls = LiveSplit()
//			ls.path = url.path
			ls.path = "/Users/Documents/mario.timesplittracker"
			vc.loadLS(ls: ls)
		}
	}

    override func windowControllerDidLoadNib(_ aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.  If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
		
	
		
		
//        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		
    }

    override class var autosavesInPlace: Bool {
        return false
    }

}
