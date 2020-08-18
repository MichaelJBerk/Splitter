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
			setAccountLabel()
			setAccountImage()
		}
	}
	func reloadData() {
		setAccountLabel()
		setAccountImage()
	}
	func setAccountLabel() {
		if let account = account {
			accountLabel.stringValue = account.displayName
		} else {
			accountLabel.stringValue = "Sign In"
		}
	}
	
	
	func setAccountImage() {
		if let account = account, let avatarURL = URL(string: account.avatar) {
			let avatar = NSImage(byReferencing: avatarURL)
			accountIcon.image = avatar
		} else {
			accountIcon.image = NSImage(named: NSImage.userName)
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
		//For some reason, I need to manually do this so it doesn't show the placeholder when the view first appears if you're already logged in
		
		account = Settings.splitsIOUser
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
