//
//  SplitterTableView.swift
//  Splitter
//
//  Created by Michael Berk on 4/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class SplitterTableView: NSTableView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
	//Overriding keyDown so that typing a letter for a hotkey doesn't select that segment
	override func keyDown(with event: NSEvent) {
		superview?.keyDown(with: event)
	}
}
