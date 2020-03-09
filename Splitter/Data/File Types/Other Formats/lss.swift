//
//  lss.swift
//  Splitter
//
//  Created by Michael Berk on 2/10/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

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
	override func makeWindowControllers() {
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)
		let vc = windowController.contentViewController as! ViewController
		
		if let url = self.fileURL {
			let ls = LiveSplit()
			ls.path = url.path
			vc.loadLS(ls: ls)
		}
	}

    override func data(ofType typeName: String) throws -> Data {
		let splitDoc = Document()
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
			let fileString = ls.liveSplitString()
			if let lsData = fileString.data(using: .utf8) {
				return lsData
			}
		}
		
		
		
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.  If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
		Swift.print(self.fileURL)
		if data == nil {
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}
    }

}
