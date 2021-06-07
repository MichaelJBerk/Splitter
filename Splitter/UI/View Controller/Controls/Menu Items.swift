//
//  Menu Items.swift
//  Splitter
//
//  Created by Michael Berk on 2/4/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa
import Preferences

extension ViewController {
	//MARK: - Actions for the Menu Bar
	
	@IBAction func hotkeysMenuItem(_ sender: Any?) {
		if let app = NSApp.delegate as? AppDelegate {
			app.preferencesWindowController.show(preferencePane: Preferences.PaneIdentifier.hotkeys)
		}
	}
	
	
	//MARK - File Menu
	
	@IBAction func uploadToSplitsIOMenuItem(_ sender: Any?) {
		splitsIOUploader.uploadToSplitsIO()
	}
	//MARK: Run Menu
	///Action for Menu Bar that starts/pauses the timer
	@IBAction func startSplitMenuItem(_ sender: Any?) {
		startSplitTimer()
		
	}
	@IBAction func pauseMenuItem(_ sender: Any?) {
		pauseResumeTimer()
	}
	
	@IBAction func stopMenuItem(_ sender: Any?) {
		cancelRun()
	}

	@IBAction func prevSplitMenuItem(_ sender: Any?) {
		goToPrevSplit()
	}
	
	@IBAction func skipSplitMenuItem(_ sender: Any?) {
		skipSplit()
	}
	
	@IBAction func resetRunMenuItem(_ sender: Any) {
		resetRun()
	}
	
	@IBAction func resetCurrentSplitMenuItem(_ sender: Any) {
		resetCurrentSplit()
	}
	
	@IBAction func showInfoPanelMenuItem(_ sender: Any) {
		displayInfoPopover(sender)
	}
	@IBAction func showColumnOptionsMenuItem(_ sender: Any) {
		displayColumnOptionsAsWindow(sender: sender)
	}
	
	@IBAction func addRowMenuItem(sender: Any) {
		addButtonClick(sender)
	}
	@IBAction func removeRowMenuItem(sender: Any) {
		removeButtonClick(sender)
	}
	
	
	//MARK: Appearance Menu
	
		
	//MARK: Window Menu
	@IBAction func toggleKeepOnTop(_ sender: Any? ) {
		windowFloat.toggle()
		setFloatingWindow()
	}
		
	///Action for Menu Bar that closes the current window. This can be useful if the title bar has been hidden by the user
	@IBAction func closeMenuItem(_ sender: Any) {
		view.window?.close()
	}
	
	//MARK: Help Menu
	///Opens the Splitter landing page in a browser
	@IBAction func helpMenu(_ sender: Any?) {
		let url = URL(string: "https://mberk.com/splitter")!
		NSWorkspace.shared.open(url)
	}
	///Opens the FAQ Wiki page in a browser
	@IBAction func faqMenuItemAction(_ sender: Any?) {
		let url = URL(string: "https://github.com/MichaelJBerk/Splitter/wiki/FAQ")!
		NSWorkspace.shared.open(url)
	}
	///Opens the invite to the Discord server
	@IBAction func discordMenuItemAction(_ sender: Any?) {
		let url = URL(string: "https://mberk.com/splitter/discord")!
		NSWorkspace.shared.open(url)
	}
}

extension ViewController: NSMenuItemValidation {
	///Sets which menu items should be enabled
	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		
		if let id = menuItem.identifier, let enabled = enabledMenuItems[id] {
			return enabled
		}
		return true
	}
	
	
}
