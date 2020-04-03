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
	
	
	func keybindAlert() {
		let alert = NSAlert()
		alert.messageText = "A brief note about Global Keybinds"
		alert.informativeText = """
		In order for Global Keybinds to work, you'll need to give Splitter permission to see what you're typing, even if Splitter isn't the currently active app.
		
		Of course, even if you don't give Splitter permission to have Global Keybinds, you can still continue to use all of its other features just fine.
		"""
		alert.addButton(withTitle: "Dismiss")
		alert.addButton(withTitle: "Tell me more")
		switch alert.runModal() {
		case .alertSecondButtonReturn:
//			keybindTellMeMore()
			NSWorkspace.shared.open(URL(string: "https://mberk.com/splitter/notAnotherTripToSystemPreferences.html")!)
		default:
			return
		}
		
		
	}
	
	func keybindTellMeMore() {
		let alert = NSAlert()
		alert.messageText = "Splitter, Global Keybinds, Privacy, and You"
		alert.informativeText = """
		By default, macOS doesn't allow applications to see what the user is pressing on their keyboard when the app isn't currently in use, and for good reason - a shady developer could make an app can store everything you type, which will probably include some amount of senstive information (i.e. passswords, credit cards, etc.).
		Of course, most apps aren't doing that (or at least, one would hope), so you can also tell macOS to allow specific apps to "listen" to whatever keys you're typing (or, as Apple calls it "Input Monitoring").
		One of Splitter's key features is the ability to control your run even if the app is in the background (a.k.a "Global Keybinds"). This necessitates that Splitter be able to keep track of whatever you're typing, so long as the window is open, and as fate would have it, you'll need to give it permission to do so.
		I'd like to make it clear that Splitter does not keep a record of any key presses that you perform when you aren't using the app. In fact, the only time it keeps any record of what you press is when you record a custom hotkey - so you can, you know, record a custom hotkey.
		
		If you'd like to give Splitter permission to have Global Hotkeys, open System Preferences, search for "Privacy Settings", unlock the padlock, scroll to Input Monitoring, and click the check next to Splitter. You may also need to quit Splitter and reopen it in order for the change to take effect.
		
		Of course, if you don't want to do that, you can still use the rest of Splitter's functionality. You can even still customize the hotkeys, too - but they won't activate unless Splitter is the currently active app.
		
		"""
		alert.addButton(withTitle: "OK")
		alert.runModal()
	}
	
	func setPaused(paused: Bool) {
		
	}
	func checkIfInputMonitoringIsEnabled() {
		let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
		let accessEnabled = AXIsProcessTrustedWithOptions(options)

		if !accessEnabled {
//			keybindAlert()
		}
	}
	//Takes the hotkeys set as SplitterKeybinds and registers them for global input monitoring.
	func MAStoStandardHotkeys() {
		
		NSEvent.addGlobalMonitorForEvents(matching: [.keyDown], handler: { event in
			
			for k in self.appKeybinds {
				let code = k?.keybind?.keyCode
				let mods = k?.keybind?.modifierFlags
				print(event.keyCode)
				let eventMods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
				if Int(event.keyCode) == code && eventMods == mods {
					let ka = self.keybindAction(keybind: k!.title)
					ka!()
				}
			}
		})
	}
	
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		if !Settings.notFirstUse {
			Settings.hideUIButtons = false
			Settings.hideTitleBar = false
			Settings.floatWindow = false
			Settings.showBestSplits = false
			Settings.enableGlobalHotkeys = false
			
			Settings.notFirstUse = true
			
			keybindAlert()
		}
		loadDefaultSplitterKeybinds()
		MAStoStandardHotkeys()
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
//							MASShortcutMonitor.shared()?.register(kb, withAction: keybindAction(keybind: k.title))
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
