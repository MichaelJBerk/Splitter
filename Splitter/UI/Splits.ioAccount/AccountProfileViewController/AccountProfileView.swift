//
//  AccountViewController.swift
//  Splitter
//
//  Created by Michael Berk on 8/12/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit


class AccountProfileView: NSViewController, LoadableNib {
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
	override var view: NSView {
		get {
			return contentView
		}
		set {
			contentView = newValue
		}
	}
	
	
	func setAccount(account: SplitsIORunner) {
		usernameField.stringValue = account.displayName
		let hasTwitch = account.twitchName != nil
		twitchUsernameField.isHidden = !hasTwitch
		twitchUsernameLabel.isHidden = !hasTwitch
		twitchUsernameField.stringValue = account.twitchName ?? ""
		if let avatarURL = URL(string: account.avatar) {
			let avatar = NSImage(byReferencing: avatarURL)
			avatarView.image = avatar
		} else {
			avatarView.image = #imageLiteral(resourceName: "splitsio")
		}
	}
	func logout() {
		accountController.logout()
	}
}
