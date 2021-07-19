//
//  DownloadWindowController.swift
//  Splitter
//
//  Created by Michael Berk on 8/2/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit
class DownloadWindowController: NSWindowController, NSWindowDelegate {
    static var windowOpened: Bool = false
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
        window?.delegate = self
		if let vc = window?.contentViewController as? DownloadViewController {
			vc.sField = searchField
		}
		if let _ = account { accountButton.reloadData() }
		NotificationCenter.default.addObserver(forName: .splitsIOLogin, object: nil, queue: nil, using: {_ in
			self.getUser()
		})
		NotificationCenter.default.addObserver(forName: .splitsIOLogout, object: nil, queue: nil, using: { notification in
			
			Settings.splitsIOUser = nil
			self.account = nil
		})
        
	}
    func windowWillClose(_ notification: Notification) {
        Self.windowOpened = false
    }
    override func windowWillLoad() {
        super.windowWillLoad()
        Self.windowOpened = true
    }
    
	
	func getUser() {
		try? SplitsIOKit.shared.getCurrentUser(completion: { runner in
			self.account = runner
			
		})
	}
    

	
}
