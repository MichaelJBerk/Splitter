//
//  DownloadWindowController.swift
//  Splitter
//
//  Created by Michael Berk on 8/2/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit
class DownloadWindowController: NSWindowController {
	@IBOutlet weak var searchField: NSSearchField!
	@IBOutlet weak var accountButton: AccountButtonView!
	
	
	
	override func windowDidLoad() {
		super.windowDidLoad()
		if let vc = window?.contentViewController as? DownloadViewController {
			vc.sField = searchField
		}
	}
}
