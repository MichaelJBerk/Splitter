//
//  LayoutEditorListCell.swift
//  Splitter
//
//  Created by Michael Berk on 10/27/22.
//  Copyright © 2022 Michael Berk. All rights reserved.
//

import Cocoa

class LayoutEditorListCell: NSTableCellView {

	@IBOutlet private var dragIndicator: DragIndicator?
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	func setup() {
		///See the documentation on ``layoutEditorItemDragged`` for more info on why I call this
		NotificationCenter.default.addObserver(forName: .layoutEditorItemDragged, object: nil, queue: nil, using: { notification in
			if self.dragIndicator?.alwaysShowIcon == false {
				self.dragIndicator?.imageView.isHidden = true
			}
		})
	}
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
