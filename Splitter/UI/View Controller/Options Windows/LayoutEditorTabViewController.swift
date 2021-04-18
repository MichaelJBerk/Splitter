//
//  LayoutEditorTabViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class LayoutEditorTabViewController: NSTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	var viewController: ViewController!
	
	override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
		super.tabView(tabView, didSelect: tabViewItem)
		if let v = tabViewItem?.viewController {
			self.preferredContentSize = v.preferredContentSize
			if let pop = viewController.columnOptionsPopover {
				pop.contentSize = v.preferredContentSize
			} else {
				if let window = view.window {
					let newFrame = NSRect(x: window.frame.origin.x, y: window.frame.origin.y, width: v.preferredContentSize.width, height: v.preferredContentSize.height)
					self.view.window?.animator().setFrame(newFrame, display: true, animate: true)
				}
			}
		}
	}
    
}
