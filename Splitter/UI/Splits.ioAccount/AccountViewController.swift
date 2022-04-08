//
//  AccountController.swift
//  Splitter
//
//  Created by Michael Berk on 8/12/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit
import Preferences

class AccountViewController: NSViewController, PreferencePane {
	var preferencePaneIdentifier = Preferences.PaneIdentifier.splitsIO
	var preferencePaneTitle: String = "Splits.io"
    var toolbarItemIcon: NSImage {
		let img = NSImage(named: "splitsio")!.copy() as! NSImage
        if #available(macOS 11.0, *) {
            img.isTemplate = true
        }
        return img
        
    }
	
	var container: NSView!
	
	var account: SplitsIORunner? {
		didSet {
			Settings.splitsIOUser = account
		}
	}
	
	///Indicates whether there's a user logged in
	var loggedIn: Bool {
		return account != nil
	}
	
	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		account = Settings.splitsIOUser
		makeViews()
		updateView()
	}
	convenience init() {
		let account = Settings.splitsIOUser
		self.init(account: account)
	}
	
	init(account: SplitsIORunner?) {
		super.init(nibName: nil, bundle: nil)
		self.account = account
		makeViews()
		
		updateView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		account = Settings.splitsIOUser
		makeViews()
		updateView()
		
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
        account = Settings.splitsIOUser
	}
	
	var profileView: AccountProfileView!
	var loginView: LoginView!
	
	func makeViews() {
//		profileView = AccountProfileView()
//		profileView.loadViewFromNib()
//		profileView.accountController = self
//		loginView = LoginView()
//		loginView.loadViewFromNib()
//		loginView.accountController = self
		
//		container = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 500))
		let size = NSSize(width: 480, height: 181)
		view = NSView(frame: .init(origin: .init(x: 0, y: 0), size: size))
//		self.addChild(loginView)
//		self.addChild(profileView)
		preferredContentSize = size
	}
	
	
	var currentView: AccountSubview?
	
	
	func updateView() {
		if currentView?.view.subviews.count ?? 0 > 0 {
			for sub in currentView?.view.subviews ?? [] {
				sub.removeFromSuperview()
			}
		}
//		view = NSView()
		currentView?.removeFromParent()
		
		if let account = account {
			let profileView = AccountProfileView()
			profileView.loadViewFromNib()
			profileView.accountController = self
			profileView.setAccount(account: account)
			currentView = profileView
		} else {
			let loginView = LoginView()
			loginView.loadViewFromNib()
			loginView.accountController = self
			currentView = loginView
		}
		self.addChild(currentView!)
		
		self.view.addSubview(currentView!.view)
		
	}
	
	
	func setUser(completion: @escaping() -> ()) {
		do {
			try SplitsIOKit.shared.getCurrentUser(completion: { user in
				self.account = user
				completion()
			})
			
		} catch {
			print(error)
			
		}
	}
	
	func login() {
		try? SplitsIOKit.shared.login {
			self.setUser {
				self.updateView()
			}
		}
	}
	func logout() {
		try? SplitsIOKit.shared.logout(completion: {
			self.account = nil
			self.updateView()
		})
	}
	/**
	If user is logged in, give the account view controller
	otherwise, give the login view controller
	*/
	
}
protocol AccountSubview: NSViewController, LoadableNib {
	var accountController: AccountViewController! {get set}
}
