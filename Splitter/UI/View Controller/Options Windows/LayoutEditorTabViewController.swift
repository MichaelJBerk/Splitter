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
			viewController.columnOptionsPopover?.contentSize = v.preferredContentSize
		}
	}
    
}
