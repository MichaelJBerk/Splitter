//
//  Fontable.swift
//  Splitter
//
//  Created by Michael Berk on 12/22/22.
//  Copyright © 2022 Michael Berk. All rights reserved.
//

import Cocoa

protocol Fontable {
	func setFont()
	func setFontObserver()
	var run: SplitterRun! {get}
	///Initial font size for the control
	///
	///- NOTE: The default implementation does not set this. The `NSControl` implemention _does_ set this when ``setFont()-75x2j`` is run.
	var defaultFontSize: CGFloat? {get set}
	///Option to opt in/out of Fontable behaviors
	var fontable: Bool {get set}
	///Determines if the control responds to Splitter's font size adjustment
	var fixedFontSize: Bool {get}
}

extension Fontable {
	func setFontObserver() {
		NotificationCenter.default.addObserver(forName: .fontChanged, object: run, queue: nil, using: { notification in
			if fontable {
				setFont()
			}
		})
	}
	var fixedFontSize: Bool {
		return false
	}
}

//Need separate extension for each; I tried making it into a single protocol, but it wouldn't work.

extension NSCell {
	func setFont(run: SplitterRun) {
		if let csize = self.font?.pointSize {
			if let font = run.textFont {
				let nf = NSFont(name: font.fontName, size: csize)
				self.font = nf
			} else {
				self.font = NSFont.systemFont(ofSize: csize)
			}
		}
	}
}

extension Fontable where Self: NSCell {
	func setFont() {
		self.setFont(run: run)
	}
}

extension Fontable where Self: NSControl {
	func setFont() {
		self.setFont(run: run)
	}
}

extension NSControl {
	@objc func setFont(run: SplitterRun) {
		if var control = self as? Fontable {
			if control.defaultFontSize == nil {
				if let size = self.font?.pointSize {
					control.defaultFontSize = size
				} else {
					control.defaultFontSize = 12
				}
			}
			let defaultSize = control.defaultFontSize!
			
			var csize = defaultSize
			if !control.fixedFontSize {
				csize = csize + run.textFontSize
			}
			if let font = run.textFont {
				let nf = NSFont(name: font.fontName, size: csize)
				self.font = nf
			} else {
				self.font = NSFont.systemFont(ofSize: csize)
			}
		}
	}
}
