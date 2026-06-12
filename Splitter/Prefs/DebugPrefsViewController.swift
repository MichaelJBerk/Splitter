//
//  DebugPrefsViewController.swift
//  Splitter
//
//  Created by Michael Berk on 7/26/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//
#if DEBUG
import Cocoa
import Settings

class DebugPrefsViewController: NSViewController, SettingsPane {
	var paneIdentifier: Settings.PaneIdentifier = .debug
	
	var paneTitle: String = "Debug"
	var toolbarItemIcon: NSImage {
		if #available(macOS 11.0, *), let img = NSImage(systemSymbolName: "hammer", accessibilityDescription: nil) {
			return img
		} else {
			return NSImage(named: NSImage.mobileMeName)!
		}
	}
	
	override var nibName: NSNib.Name? { "DebugPrefsViewController" }
	@IBOutlet var splitsIOURLTextField: NSTextField!
	@IBOutlet var splitsIOClientIDField: NSTextField!
	@IBOutlet var splitsIOSecretIDField: NSTextField!
	@IBOutlet var placeholderSIOCheck: NSButton!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
		preferredContentSize = NSSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
		placeholderSIOCheck.state = .init(bool: AppSettings.placeholderSIO)
		
	}
	override func viewDidAppear() {
		super.viewDidAppear()
		splitsIOURLTextField.stringValue = AppSettings.splitsIOURL.absoluteString
		
	}
	
	@IBAction func editURLTextField(_ sender: NSTextField) {
		if let url = URL(string: sender.stringValue) {
			AppSettings.splitsIOURL = url
		}
	}
	
	@IBAction func editClientTextField(_ sender: NSTextField) {
		if sender.stringValue == "" {
			AppSettings.splitsIOClientOverride = nil
		} else {
			AppSettings.splitsIOClientOverride = sender.stringValue
		}
	}
	
	@IBAction func editSecretTextField(_ sender: NSTextField) {
		if sender.stringValue == "" {
			AppSettings.splitsIOSecretOverride = nil
		} else {
			AppSettings.splitsIOSecretOverride = sender.stringValue
		}
	}
	
	@IBAction func sioInfoButtonClick(_ sender: NSButton) {
		let alert = NSAlert()
		alert.informativeText = "The following is persisted in the DB, and is what will be used for auth on next startup:\n\n\n\n\n\n\n\n\n\n\n\nURL: \(AppSettings.splitsIOURL)"
		alert.beginSheetModal(for: self.view.window!)
	}
	
	@IBAction func togglePlaceholderSIO(_ sender: NSButton) {
		AppSettings.placeholderSIO = sender.state.toBool()
	}
    
}
#endif
