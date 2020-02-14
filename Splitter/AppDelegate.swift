//
//  AppDelegate.swift
//  Splitter
//
//  Created by Michael Berk on 12/22/19.
//  Copyright © 2019 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences
import Carbon
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import Keys
import Files

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet private var window: NSWindow!
	
	public var hotkeyController: HotkeysViewController?

	
	
	func loadHotkeys() {

		
		

	}
	
	func setPaused(paused: Bool) {
		
	}
	
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		
		if !Settings.notFirstUse {
			Settings.hideUIButtons = false
			Settings.hideTitleBar = false
			Settings.floatWindow = false
			Settings.showBestSplits = false
			Settings.notFirstUse = true
			Settings.enableGlobalHotkeys = false
		}
		
		
//		keybinds.append(Keybind(title: .NextSplit, keyDownHandler: self.viewController!.goToNextSplit))
		
		
		
		
		
		// Insert code here to initialize your application
		
		//TODO: Secret for Appcenter
		let keys = SplitterKeys()
		MSAppCenter.start("\(keys.appCenter)", withServices:[
			MSAnalytics.self,
			MSCrashes.self
		])
		

	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	lazy var preferencesWindowController = PreferencesWindowController(
		preferencePanes: [
			DefaultPreferenceViewController(),
			HotkeysViewController()
//			AdvancedPreferenceViewController()
		]
	)
	
	var viewController: ViewController? {
		if let vc =  NSApp.windows.first?.contentViewController as? ViewController {
			return vc
		}
		return nil
	}

	@IBAction func preferencesMenuItemActionHandler(_ sender: NSMenuItem) {
//		preferencesWindowController.window = self.window
		
		preferencesWindowController.show()
	}
	
	///Brings the current window to the front. Intended for use with keybinds.
	func frontHandler()  {
		
		NSApplication.shared.orderedWindows.forEach({ (window) in
			if let mainWindow = window as? MainWindow {
				NSApplication.shared.activate(ignoringOtherApps: true)
				mainWindow.makeKeyAndOrderFront(nil)
				mainWindow.makeKey()
			}
		})
		
	}
	
	func resetTimerHandler() {
		if let vc = viewController as? ViewController {
			vc.stopTimer()
			vc.clearCurrentTime()
			vc.startTimer()
		}
	}
	func StartPauseHandler() {
		if let vc = viewController {
			vc.timerButtonClick(self)
		}
	}
	
}
