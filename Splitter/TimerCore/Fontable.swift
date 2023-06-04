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
	var fontable: Bool {get set}
}

extension Fontable {
	func setFontObserver() {
		NotificationCenter.default.addObserver(forName: .fontChanged, object: run, queue: nil, using: { notification in
			if fontable {
				setFont()
			}
		})
	}
}

//Need separate extension for each; I tried making it into a single protocol, but it wouldn't work.

extension NSCell {
	func setFont(run: SplitterRun) {
		if let csize = self.font?.pointSize {
			if let font = run.runFont {
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
		if let csize = self.font?.pointSize {
			if let font = run.runFont {
				let nf = NSFont(name: font.fontName, size: csize)
				self.font = nf
			} else {
				self.font = NSFont.systemFont(ofSize: csize)
			}
		}
	}
}
