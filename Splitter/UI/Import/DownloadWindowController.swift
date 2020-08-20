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
	var account: SplitsIORunner? = Settings.splitsIOUser {
		didSet {
			accountButton.account = self.account
			accountButton.setAccountLabel()
			accountButton.setAccountImage()
		}
	}
	
	
	override func windowDidLoad() {
		super.windowDidLoad()
		if let vc = window?.contentViewController as? DownloadViewController {
			vc.sField = searchField
		}
		if let account = account { accountButton.reloadData() }
		NotificationCenter.default.addObserver(forName: .splitsIOLogin, object: nil, queue: nil, using: {_ in
			self.getUser()
		})
		NotificationCenter.default.addObserver(forName: .splitsIOLogout, object: nil, queue: nil, using: { notification in
			
			Settings.splitsIOUser = nil
			self.account = nil
		})
	}
	
	func getUser() {
		try? SplitsIOKit.shared.getCurrentUser(completion: { runner in
			self.account = runner
			
		})
	}

	
}
