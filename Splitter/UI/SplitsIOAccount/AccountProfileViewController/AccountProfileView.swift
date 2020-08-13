//
//  AccountViewController.swift
//  Splitter
//
//  Created by Michael Berk on 8/12/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit

class AccountProfileView: NSView, AccountSubview, LoadableNib {
	var accountController: AccountViewController!
	
	@IBOutlet var contentView: NSView!

	@IBOutlet weak var avatarView: NSImageView!
	@IBOutlet weak var usernameField: NSTextField!
	@IBOutlet weak var twitchUsernameLabel: NSTextField!
	@IBOutlet weak var twitchUsernameField: NSTextField!
	
	@IBOutlet weak var logoutButton: NSButton!
	
	@IBAction func logoutButtonClick(_ sender: NSButton) {
		logout()
	}
	
	
	func setAccount(account: SplitsIORunner) {
		usernameField.stringValue = account.displayName
		let hasTwitch = account.twitchName != nil
		twitchUsernameField.isHidden = !hasTwitch
		twitchUsernameLabel.isHidden = !hasTwitch
		twitchUsernameField.stringValue = account.twitchName ?? ""
	}
	func logout() {
		try? accountController.logout()
	}
}
