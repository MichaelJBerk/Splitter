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
		Swift.print(writableTypes(for: .saveOperation))
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
	
	override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		if typeName == "Split File" {
//			let newDoc = try? Document(type: "Split File")
////			for w in self.windowControllers {
////				w.document = newDoc
////			}
////			newDoc?.setWindow(self.windowControllers.first?.window)
//			NSDocumentController.shared.newDocument(nil)
//			newDoc?.save(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
//			saveSplitFile(url: url)
			saveSplitFile(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: 	contextInfo)
		} else {
//			super.save(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
			saveLiveSplitFile(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: 	contextInfo)
		}
	}
	
	
	
	
//    override func data(ofType typeName: String) throws -> Data {
//		
//		
//		
//		
//		
//		
//        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.  If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
		Swift.print(self.fileURL)
		if data == nil {
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}
    }

}
