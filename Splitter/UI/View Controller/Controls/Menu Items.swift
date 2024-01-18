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
	
	@IBAction func useRunAsDefaultMenuItem(_ sender: Any?) {
		SplitterDocumentController.sShared.useAsTemplate(doc: document)
	}
	
	@IBAction func resetDefaultRunMenuItem(_ sender: Any?) {
		SplitterDocumentController.sShared.resetTemplate()
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
		run.timer.previousSplit()
	}
	
	@IBAction func skipSplitMenuItem(_ sender: Any?) {
		run.timer.skipSplit()
	}
	
	@IBAction func showInfoPanelMenuItem(_ sender: Any) {
		displayInfoPopover(sender)
	}
	@IBAction func showLayoutEditorMenuItem(_ sender: Any) {
		showLayoutEditor()
	}
	
	@IBAction func editSegmentsMenuItem(_ sender: Any) {
		displaySplitsEditor()
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
}
extension AppDelegate {
	
	//MARK: Help Menu
	///Opens the Splitter landing page in a browser
	@IBAction func helpMenu(_ sender: Any?) {
		let url = URL(string: "splitter.mberk.com")!
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
		
		if let id = menuItem.identifier {
			switch id {
			case menuIdentifiers.fileMenu.resetDefaultRun:
				if SplitterDocumentController.sShared.templateFileExists {
					return true
				}
				return false
			case menuIdentifiers.runMenu.info,
				 menuIdentifiers.runMenu.editSegments,
				 menuIdentifiers.appearanceMenu.showLayoutEditor:
				if self.timerState == .stopped {
					return true
				}
				return false
			case menuIdentifiers.runMenu.StartSplit:
				return timerState != .paused
			case menuIdentifiers.runMenu.pause,
				menuIdentifiers.runMenu.stop:
				return timerState != .stopped
			case menuIdentifiers.runMenu.back:
				return timerState == .running
			case menuIdentifiers.runMenu.skipSplit:
				if timerState == .running, let cs = run.currentSplit, cs < run.segmentCount - 1, run.segmentCount > 1 {
					return true
				} else {
					return false
				}
			default:
				break
			}
			if let enabled = enabledMenuItems[id] {
				return enabled
			}
		}
		
		return true
	}
	
	
}
