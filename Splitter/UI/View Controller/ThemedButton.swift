//
//  ThemedButton.swift
//  Splitter
//
//  Created by Michael Berk on 4/8/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class ThemedButton: NSButton, Themeable {
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setColorObserver()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setColorObserver()
	}
	func setColor(run: SplitterRun) {
		var newImage = self.image
		newImage?.isTemplate = true
		newImage = newImage?.image(with: run.textColor)
		self.image = newImage
		self.contentTintColor = run.textColor
		self.attributedTitle = NSAttributedString(string: self.title, attributes: [.foregroundColor: run.textColor])
		self.appearance = NSAppearance(named: .darkAqua)
		self.shadow = .none
	}
	
	var themeable: Bool = true
	

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
