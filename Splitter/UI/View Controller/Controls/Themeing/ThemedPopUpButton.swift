//
//  ThemedPopUpButton.swift
//  Splitter
//
//  Created by Michael Berk on 4/8/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class ThemedPopUpButton: NSPopUpButton, Themeable {
	var run: SplitterRun!
	var themeable: Bool = true
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setColorObserver()
		
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setColorObserver()
	}
	
	func setColor() {
		
		self.contentTintColor = run.textColor
		//not used now, but could be useful in the future for popup buttons with titles instead of images
		self.attributedTitle = NSAttributedString(string: self.title, attributes: [.foregroundColor: run.textColor])
		if let menu = menu {
			setColors(for: menu, color: run.textColor)
		}
		self.appearance = NSAppearance(named: .darkAqua)
	}
	func setColors(for menu: NSMenu, color: NSColor) {
		for item in menu.items {
			if var newImage = item.image {
				newImage.isTemplate = true
				newImage = newImage.image(with: color)
				item.image = newImage
			}
			if item.hasSubmenu, let submenu = item.submenu {
				setColors(for: submenu, color: color)
			}
			
		}
	}

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
