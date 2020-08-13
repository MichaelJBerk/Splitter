//
//  AccountButtonViewController.swift
//  Splitter
//
//  Created by Michael Berk on 8/11/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit

@IBDesignable
class AccountButtonView: NSView, LoadableNib {
	@IBOutlet var contentView: NSView!
	
	@IBOutlet var accountLabel: NSTextField!
	@IBOutlet var accountIcon: NSImageView!
	var account: SplitsIORunner? = Settings.splitsIOUser {
		didSet {
			Settings.splitsIOUser = account
			if let account = account {
				accountLabel.stringValue = account.displayName
			} else {
				accountLabel.stringValue = "Sign In"
			}
		}
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		loadViewFromNib()
		let click = NSClickGestureRecognizer(target: self, action: #selector(clicked(_:)))
		self.addGestureRecognizer(click)
		getUser()
		NotificationCenter.default.addObserver(forName: .splitsIOLogin, object: nil, queue: nil, using: {_ in
			self.getUser()
		})
		NotificationCenter.default.addObserver(forName: .splitsIOLogout, object: nil, queue: nil, using: { notification in
			self.account = nil
		})
	}
	
	func getUser() {
		try? SplitsIOKit.shared.getCurrentUser(completion: { runner in
			self.account = runner
			
		})
	}
	
	@objc func clicked(_ sender: Any) {
		let aView = AccountViewController()
		let pop = NSPopover()
		pop.contentViewController = aView
		pop.behavior = .semitransient
//		print(aView.currentView.frame.size)
		pop.contentSize = aView.currentView.view.frame.size
		pop.show(relativeTo: accountLabel.frame, of: self, preferredEdge: .minY)
		
		NotificationCenter.default.addObserver(forName: .splitsIOLogout, object: nil, queue: nil, using: { _ in
			pop.close()
		})
	}
    
}
