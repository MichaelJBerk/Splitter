//
//  AppDelegate.swift
//  Splitter
//
//  Created by Michael Berk on 12/22/19.
//  Copyright © 2019 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import Keys
import Files

class otherConstants {

public static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
public static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet private var window: NSWindow!
	
	public var hotkeyController: HotkeysViewController?
	
	var appKeybinds: [SplitterKeybind?] = []
	
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
			Settings.enableGlobalHotkeys = true
			
			Settings.notFirstUse = true
		}
		loadDefaultSplitterKeybinds()
		self.globalShortcuts = Settings.enableGlobalHotkeys
		
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
//		if let vc =  NSApp.windows.first?.contentViewController as? ViewController {
//			return vc
//		}
		get {
			var viewC: ViewController? = nil
			for window in NSApp.orderedWindows {
				if let mainWindow = window as? MainWindow {
					if let vc = mainWindow.contentViewController as? ViewController {
						if NSApp.isActive {
							if vc.view.window?.isMainWindow == true  || vc.view.window?.isKeyWindow == true {
								viewC = vc
							}
						} else {
							viewC = vc
							break
						}
					}
				}
				
			}
			return viewC
		}
	}

	@IBAction func preferencesMenuItemActionHandler(_ sender: NSMenuItem) {
//		preferencesWindowController.window = self.window
		
		preferencesWindowController.show()
	}
	

	var globalShortcuts: Bool! {
		didSet {
			if !globalShortcuts {
				MASShortcutMonitor.shared()?.unregisterAllShortcuts()
			} else {
				for i in appKeybinds {
					if let k = i {
						if let kb = k.keybind {
//							updateSplitterKeybind(keybind: k.title, shortcut: kb)
							MASShortcutMonitor.shared()?.register(kb, withAction: keybindAction(keybind: k.title))
						}
					}
				}
			}
		}
	}
	
	
	
	// {
//		didSet {
//			if !globalShortcuts {
//				MASShortcutMonitor.shared()?.unregisterAllShortcuts()
//			}
//			else {
//				for i in appKeybinds {
//					if let k = i {
//						if let kb = k.keybind {
//							updateSplitterKeybind(keybind: k.title, shortcut: kb)
//						}
////					let a = keybindAction(keybind: k.title)
////					MASShortcutMonitor.shared()?.register(k.keybind, withAction: a)
//					}
//				}
//			}
//		}
//	}
}
