//
//  Themeable.swift
//  Splitter
//
//  Created by Michael Berk on 7/7/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

protocol Themeable {
	func setColor()
	func setColorObserver()
	var run: SplitterRun! {get}
	var themeable: Bool {get set}
}
extension Themeable {
	//TODO: What was this used for?
	static var runKey: String {
		return "run"
	}
	func setColorObserver() {
		NotificationCenter.default.addObserver(forName: .updateComponentColors, object: run, queue: nil, using: { notification in
			if themeable {
				setColor()
			}
		})
	}
}
