//
//  SplitsIODoc.swift
//  Splitter
//
//  Created by Michael Berk on 3/10/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit

class SplitsIODoc: SplitterDoc {
	
	var splitsio: SplitsIOExchangeFormat?
	
	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		
		
		
		self.addWindowController(windowController)
		let vc = windowController.contentViewController as! ViewController
		vc.setColorForControls()
		if let si = splitsio {
			vc.run.title = si.game?.longname ?? ""
			vc.run.subtitle = si.category?.longname ?? ""
			vc.run.attempts = si.attempts?.total ?? 0
			if let imageStr = si.imageURL, let imageURL = URL(string: imageStr) {
				let gameIcon = NSImage(byReferencing: imageURL)
				vc.gameIcon = gameIcon
			}
			if let segs = si.segments {
				var i = 0
				for s in segs {
					i = i + 1
					let title = s.name ?? "\(i)"
					let bestTS = TimeSplit(mil: s.bestDuration?.gametimeMS ?? 0)
					let splitRow = SplitTableRow(splitName: title, bestSplit: bestTS, currentSplit: TimeSplit(), previousSplit: bestTS, previousBest: bestTS)
					vc.currentSplits.append(splitRow)
				}
				vc.splitsTableView.reloadData()
			}
		}
		
	}
	override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, delegate: Any?, didSave didSaveSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
		determineSave(to: url, ofType: typeName, for: saveOperation, delegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
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
		var decoder = JSONDecoder()
		splitsio = try? decoder.decode(SplitsIOExchangeFormat.self, from: data)
		if splitsio == nil {
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}
		
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.  If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        
    }


}
