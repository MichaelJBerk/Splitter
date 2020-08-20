//
//  LoginViewController.swift
//  Splitter
//
//  Created by Michael Berk on 8/11/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit

class LoginView: NSViewController, LoadableNib {
	var accountController: AccountViewController!
//
//	override init(frame frameRect: NSRect) {
//        super.init(frame: frameRect)
//        loadViewFromNib()
//    }

//    required init?(coder decoder: NSCoder) {
//        super.init(coder: decoder)
//        loadViewFromNib()
//    }
	override var view: NSView {
		get {
			return contentView
		}
		set {
			contentView = newValue
		}
	}
	
	@IBOutlet weak var loginButton: NSButton!
	
	@IBOutlet var contentView: NSView!
	
	@IBAction func loginButtonClick(_ sender: NSButton) {
		login()
	}
	
	func login() {
		accountController.login()
	}
}
