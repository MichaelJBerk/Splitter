//
//  AccountController.swift
//  Splitter
//
//  Created by Michael Berk on 8/12/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit

class AccountViewController: NSViewController {
	var account: SplitsIORunner?
	
	///Indicates whether there's a user logged in
	var loggedIn: Bool {
		return account != nil
	}
	
	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	convenience init() {
		self.init(account: nil)
	}
	
	init(account: SplitsIORunner?) {
		super.init(nibName: nil, bundle: nil)
		self.account = account
		setView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	func setView() {
		if let account = account {
			let profileView = AccountProfileView()
			profileView.loadViewFromNib()
			profileView.accountController = self
			profileView.setAccount(account: account)
			self.view = profileView
			self.preferredContentSize = view.frame.size
			
		} else {
			let loginView = LoginView()
			loginView.loadViewFromNib()
			loginView.accountController = self
			self.view = loginView
			self.preferredContentSize = view.frame.size
		}
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
				self.setView()
			}
		}
		
	}
	func logout() {
		try? SplitsIOKit.shared.logout(completion: {})
	}
	/**
	If user is logged in, give the account view controller
	otherwise, give the login view controller
	*/
	
}
protocol AccountSubview: NSView {
	var accountController: AccountViewController! {get set}
}
