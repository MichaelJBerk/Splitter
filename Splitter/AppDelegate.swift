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

extension NSApplication {
	static let appDelegate = NSApp.delegate as! AppDelegate
}

class otherConstants {

public static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
public static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, MSCrashesDelegate {
	@IBOutlet private var window: NSWindow!
	
	public var hotkeyController: HotkeysViewController?
	
	var appKeybinds: [SplitterKeybind?] = []
	
	
	func keybindAlert() {
		let alert = NSAlert()
		alert.messageText = "A brief note about Global Hotkeys"
		alert.informativeText = """
		In order for Global Hotkeys to work, you'll need to give Splitter permission to see what you're typing, even if Splitter isn't the currently active app.
		
		Of course, even if you don't give Splitter permission to have Global Hotkeys, you can still continue to use all of its other features just fine.
		"""
		alert.addButton(withTitle: "Dismiss")
		alert.addButton(withTitle: "Tell me more")
		switch alert.runModal() {
		case .alertSecondButtonReturn:
			NSWorkspace.shared.open(URL(string: "https://mberk.com/splitter/notAnotherTripToSystemPreferences.html")!)
		default:
			return
		}
		
		
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
	
	func setKeyMonitor(event: NSEvent) {
		
		for k in self.appKeybinds {
			let code = k?.keybind?.keyCode
			let mods = k?.keybind?.modifierFlags
			let eventMods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
			
			
			
			if Int(event.keyCode) == code && eventMods == mods {
				let ka = self.keybindAction(keybind: k!.title)
				ka!()
			}
		}
	}
	///Takes the hotkeys set as SplitterKeybinds and registers them for global input monitoring.
	func MAStoStandardHotkeys() {
		
		NSEvent.addGlobalMonitorForEvents(matching: [.keyDown], handler: { event in
			if Settings.enableGlobalHotkeys {
				self.setKeyMonitor(event: event)
			}
		})
		//Set overrides for keys that KeyEquivalents has a problem with, like the spacebar
		NSEvent.addLocalMonitorForEvents(matching: [.keyDown], handler: { event in

			if event.keyCode == 49 {
				let filterK = self.appKeybinds.filter( { keybind in
					keybind?.keybind?.keyCode == Int(event.keyCode)
				})
				for k in filterK {
					let action = self.keybindAction(keybind: k!.title)
					action!()
				}
			}
			return event
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
		} else {
			if Settings.lastOpenedBuild != otherConstants.build {
			}
		}
		
        if #available(OSX 10.16, *) {
            preferencesWindowController.window?.toolbarStyle = .preference
        } else {
            // Fallback on earlier versions
        }
		Settings.lastOpenedVersion = otherConstants.version
		Settings.lastOpenedBuild = otherConstants.build
		loadDefaultSplitterKeybinds()
		MAStoStandardHotkeys()
		self.globalShortcuts = Settings.enableGlobalHotkeys
		
		
		MSCrashes.setDelegate(self)
		let keys = SplitterKeys()
		MSAppCenter.start("\(keys.appCenter)", withServices:[
			MSAnalytics.self,
			MSCrashes.self
		])
		MSAppCenter.setLogLevel(.verbose)
		MSCrashes.setEnabled(true)
		UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])
		MSCrashes.setUserConfirmationHandler({ (errorReports: [MSErrorReport]) in

		  // Your code to present your UI to the user, e.g. an NSAlert.
		  let alert: NSAlert = NSAlert()
		  alert.messageText = "Sorry about that!"
		  alert.informativeText = "Do you want to send an anonymous crash report so we can fix the issue?"
		  alert.addButton(withTitle: "Always send")
		  alert.addButton(withTitle: "Send")
		  alert.addButton(withTitle: "Don't send")
			alert.alertStyle = .warning

		  switch (alert.runModal()) {
		case .alertFirstButtonReturn:
			MSCrashes.notify(with: .always)
			break;
		case .alertSecondButtonReturn:
			MSCrashes.notify(with: .send)
			break;
		case .alertThirdButtonReturn:
			MSCrashes.notify(with: .dontSend)
			break;
		  default:
			break;
		  }

		  return true // Return true if the SDK should await user confirmation, otherwise return false.
		})
		
//		MSCrashes.generateTestCrash()
	}

	func crashes(_ crashes: MSCrashes!, shouldProcessErrorReport errorReport: MSErrorReport!) -> Bool {
	  return true; // return true if the crash report should be processed, otherwise false.
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
