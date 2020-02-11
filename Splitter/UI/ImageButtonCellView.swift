//
//  ImageButtonCellView.swift
//  Splitter
//
//  Created by Michael Berk on 1/26/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class ImageButtonCellView: NSTableCellView {

	@IBOutlet var imageButton: NSButton!
	var cellNumber: Int?
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
	
	
    
}
