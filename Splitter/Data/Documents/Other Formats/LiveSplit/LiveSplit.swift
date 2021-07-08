//
//  LiveSplit.swift
//  Splitter
//
//  Created by Michael Berk on 2/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa
import Files

extension ViewController {
	func loadLS(url: URL, asTemplate: Bool = false) {
		if let run = Run.parseFile(path: url.path, loadFiles: true) {
			self.run  = SplitterRun (run: run, isNewRun: false)
			if asTemplate {
				self.run.timer.resetHistories()
			}
			self.run.updateLayoutState()
		}
	}
}


extension NSImage {
	//TODO: Use this when saving to LiveSplit
	/** Turns an NSImage into the format necessary to be used with LiveSplitCore
	- Parameters:
		- withImage: Function that takes the data and passes it to LiveSplitCore
	
	In LiveSplitCore, methods dealing with images take two parameters: a pointer (`UnsafeMutableRawPointer?`) and the image's length (`Int`).
	
	`toLSImage` provides an easy way to deal with this in Swift, using an existing `NSImage`.
	
	Let's say you have `editor` - a `RunEditor`, and want to set the game's icon - an `NSImage` called `gameIcon`. You would use this method like so:
	```swift
	gameIcon.toLSImage { pointer, len in
		editor.setGameIcon(pointer, len)
	}
	```
	*/
	func toLSImage(_ withImage: (UnsafeMutableRawPointer?, Int) -> ()) {
		if var giData = tiffRepresentation {
			let giLen = giData.count
			giData.withUnsafeMutableBytes( { bytes in
				let umbp = bytes.baseAddress
				withImage(umbp, giLen)
			})
		}
	}
	
	static func parseImageFromLiveSplit(ptr: UnsafeMutableRawPointer?, len: size_t) -> NSImage? {
		if let p = ptr {
			let data = Data(bytes: p, count: Int(len))
			if let img = NSImage(data: data) {
				return img
			}
		}
		return nil
	}
}
