//
//  IconButton.swift
//  Splitter
//
//  Created by Michael Berk on 1/29/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class IconButton: NSButton {
	
	var iconButtonType: IconButtonType = .splitIcon {
		didSet {
			if iconButtonType == .gameIcon {
			}
		}
	}
	

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
		
		if let contextMenu = self.menu {
			for i in contextMenu.items {
				i.representedObject = self
			}
		}
		self.iconButtonType = .splitIcon
		
    }
	
	
}

enum IconButtonType {
	case splitIcon, gameIcon
}
