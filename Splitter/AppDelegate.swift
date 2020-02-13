//
//  AppDelegate.swift
//  Splitter
//
//  Created by Michael Berk on 12/22/19.
//  Copyright © 2019 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences
import HotKey
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

	public var keybinds: [Keybind] = []
	
	func loadHotkeys() {
//		keybinds.append(Keybind(title: .NextSplit, keyDownHandler: self.viewController!.goToNextSplit))
		for var k in keybinds {
			
			if Storage.fileExists(k.KeybindFileName, in: .appSupport) {
				let globalK = Storage.retrieve(k.KeybindFileName, from: .appSupport, as: GlobalKeybindPreferences.self)
				k.globalKeybind = globalK
			}
		}
		
		

	}
	
	func setPaused(paused: Bool) {
		for var k in keybinds {
			if var h = k.hotkey {
				h.isPaused = paused
			}
		}
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
		
		setDefaultKeybindValues()
		
		loadHotkeys()
		
		// Insert code here to initialize your application
		
		//TODO: Secret for Appcenter
		let keys = SplitterKeys()
		MSAppCenter.start("\(keys.appCenter)", withServices:[
			MSAnalytics.self,
			MSCrashes.self
		])
		self.setPaused(paused: !Settings.enableGlobalHotkeys)

	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
	func clearHotkeys() {
		if let keybindsFolder = try? Folder(path: "~/Library/Application Support/Splitter/Keybinds") {
					for f in keybindsFolder.files {
						try? f.delete()
					}
				}
		for i in keybinds {
			i.globalKeybind = nil
			i.hotkey = nil
		}
//		keybinds = []
		setDefaultKeybindValues()
		loadHotkeys()
		
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
		
	
	


	@IBAction
	func preferencesMenuItemActionHandler(_ sender: NSMenuItem) {
//		preferencesWindowController.window = self.window
		
		preferencesWindowController.show()
	}
	
	
	func frontHandler()  {
//		print(keybinds.count)
		let h = keybinds[0].hotkey
		print(h?.isPaused)
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
	func otherHandler() {
//		NSApplication.shared.orderedWindows.forEach({ (window) in
//			if let mainWindow = window as? MainWindow {
//				print("ahh")
//				NSApplication.shared.activate(ignoringOtherApps: true)
//				mainWindow.makeKeyAndOrderFront(nil)
//				mainWindow.makeKey()
//			}
//		})
		
	}
	func StartPauseHandler() {
		if let vc = viewController {
			vc.timerButtonClick(self)
		}
	}
	
	

	
	
	
//	func setUpHandlers(){
//		for k in keybinds {
//			k.hotkey?.isPaused = false
//			if let h = k.hotkey {
//				switch k.Title {
//				case .BringToFront:
//					h.keyDownHandler = frontHandler
//				case .StartStopTimer:
//					h.keyDownHandler = startStopHandler
//				default:
//					break
////					h.keyDownHandler = otherHandler
//				}
//
//			}
//		}
//		
//	}
}

