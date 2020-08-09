//
//  DownloadWindowController.swift
//  Splitter
//
//  Created by Michael Berk on 8/2/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class DownloadWindowController: NSWindowController {
	@IBOutlet weak var searchField: NSSearchField!
	
	override func windowDidLoad() {
		super.windowDidLoad()
		if let vc = window?.contentViewController as? DownloadViewController {
			vc.sField = searchField
		}
	}
}
