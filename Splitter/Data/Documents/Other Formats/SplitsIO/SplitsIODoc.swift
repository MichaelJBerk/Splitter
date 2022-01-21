//
//  SplitsIODoc.swift
//  Splitter
//
//  Created by Michael Berk on 3/10/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit
import LiveSplitKit
class SplitsIODoc: SplitterDoc {
	
	var splitsio: SplitsIOExchangeFormat?
	
	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let load = loadViewController()
		let vc = load.vc
		
		if let si = splitsio {
			let newRun = SplitterRun(run: Run(), isNewRun: true)
			vc.run = newRun
			vc.run.document = self
			vc.undoManager?.disableUndoRegistration()
			vc.run.title = si.game?.longname ?? ""
			vc.run.subtitle = si.category?.longname ?? ""
			vc.run.attempts = si.attempts?.total ?? 0
			if let imageStr = si.imageURL, let imageURL = URL(string: imageStr) {
				let gameIcon = NSImage(byReferencing: imageURL)
				vc.run.gameIcon = gameIcon
			}
			if let segs = si.segments {
				vc.run.editRun { editor in
					vc.run.removeSegment(0)
					for s in 0..<segs.count {
						let seg = segs[s]
						var prevSeg = TimeSplit(mil: seg.bestDuration?.realtimeMS ?? 0)
						if s > 0 {
							editor.insertSegmentBelow()
							editor.selectOnly(s)
							prevSeg = TimeSplit(mil: segs[s-1].bestDuration?.realtimeMS ?? 0)
							let currentSeg = TimeSplit(mil: seg.bestDuration?.realtimeMS ?? 0)
							prevSeg = currentSeg - prevSeg
						}
						editor.activeSetName(seg.name ?? "")
						_ = editor.activeParseAndSetBestSegmentTime(prevSeg.timeString)
						
					}
				}
			}
			vc.undoManager?.enableUndoRegistration()
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
		let decoder = JSONDecoder()
		splitsio = try? decoder.decode(SplitsIOExchangeFormat.self, from: data)
		if splitsio == nil {
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}
		
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.  If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        
    }


}
