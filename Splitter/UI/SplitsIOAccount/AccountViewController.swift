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
	let toolbarItemIcon: NSImage = #imageLiteral(resourceName: "splitsio")
	
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
	}
	override func viewDidLayout() {
		super.viewDidLayout()
		if let w = view.window?.windowController as? PreferencesWindowController {
			w.setFrame()
		}
	}
	
	var profileView: AccountProfileView!
	var loginView: LoginView!
	
	func makeViews() {
		profileView = AccountProfileView()
		profileView.loadViewFromNib()
		profileView.accountController = self
//		let p = profileView.frame.size
//		self.view = profileView
//		var s = view.frame.size
		
		loginView = LoginView()
		loginView.loadViewFromNib()
		loginView.accountController = self
//		let l = loginView.frame.size
		container = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
		self.view = container
		self.addChild(loginView)
		self.addChild(profileView)
	}
	
	
	var currentView: NSViewController!
	
	
	func updateView() {
		if container.subviews.count > 0 {
			for sub in container.subviews {
				sub.removeFromSuperview()
			}
		}
		
		if let account = account {
			profileView.setAccount(account: account)
			currentView = profileView
			
		} else {
			currentView = loginView
		}
		
		container.addSubview(currentView.view)
		currentView.view.frame = self.container.bounds

		preferredContentSize = currentView.view.frame.size
		view.needsDisplay = true
		view.canDrawSubviewsIntoLayer = true
		
		
		
//		blankView.addSubview(self.view)
		
//		currentView.wantsLayer = true
//		currentView.needsDisplay = true
		let s = view.frame.size
//		let c = currentView.frame.size
		NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: currentView, queue: nil, using: { notification in
			if let viewFromNotification = notification.object as? NSView {
				let s = viewFromNotification.frame.size
				self.preferredContentSize = viewFromNotification.frame.size
			}
		})
		
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
protocol AccountSubview: NSView {
	var accountController: AccountViewController! {get set}
}
