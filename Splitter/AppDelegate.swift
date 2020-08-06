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
	public static var shared: AppDelegate? = NSApplication.shared.delegate as? AppDelegate
	
	var appKeybinds: [SplitterKeybind?] = []
	
	///Displays a dialog box informing the user to give Splitter the requisite permissions for Global Hotkeys to work.
	func keybindAlert() {
		let alert = NSAlert()
		alert.messageText = "A brief note about Global Hotkeys"
		alert.informativeText = """
		In order for Global Hotkeys to work, you'll need to give Splitter permission to see what you're typing, even if Splitter isn't the currently active app.
		
		Of course, even if you don't give Splitter permission to have Global Hotkeys, you can still continue to use all of its other features just fine.
		"""
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "Tell me more")
		switch alert.runModal() {
		case .alertSecondButtonReturn:
			NSWorkspace.shared.open(URL(string: "https://mberk.com/splitter/notAnotherTripToSystemPreferences.html")!)
		case .alertFirstButtonReturn:
			self.askToOpenAccessibilitySettings()
		default:
			return
		}
	}
	func reopenToApplyKeybindAlert() {
		let alert = NSAlert()
		alert.messageText = "Splitter's privacy settings have been changed"
		alert.informativeText = "In order for these changes to take effect, you will need to quit and reopen Splitter."
		alert.addButton(withTitle: "Dismiss")
		alert.runModal()
	}
	
	///Displays the system's prompt for the user to grant Splitter Accessibility permissions
	func askToOpenAccessibilitySettings() {
		let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
		let _ = AXIsProcessTrustedWithOptions(options)
	}
	///Checks if Accessibility permissions are granted
	func accessibilityGranted() -> Bool {
		return AXIsProcessTrusted()
	}
	
	/// Performs the appropriate keybind action for the given event
	/// - Parameter event: `NSEvent` to perform the keybind action for
	///
	/// When run, this method will take find the key that triggered `event` and perform its associated keybind action
	func performGlobalKeybindAction(event: NSEvent) {
		for k in self.appKeybinds {
			if let k = k, k == event, let action = keybindAction(keybind: k.title) {
				action()
			}
		}
	}
	///Takes the hotkeys set as SplitterKeybinds and registers them for global input monitoring.
	///
	///This method creates a global event monitor, watching for keypresses even when Splitter isn't the active app.
	///When an event is triggered, if Global Hotkeys are enabled, then it will perform the keybind action associated with the key that was pressed.
	///This does nothing if the app has not been granted Accessibility permissions in System Preferences
	func setGlobalKeybindMonitor() {
		NSEvent.addGlobalMonitorForEvents(matching: [.keyDown], handler: { event in
			//If global keybinds are disabled, it won't perform the keybind action.
			if Settings.enableGlobalHotkeys {
				self.performGlobalKeybindAction(event: event)
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
		} else {
			if Settings.lastOpenedBuild != otherConstants.build {
			}
		}
		
		
		
		Settings.lastOpenedVersion = otherConstants.version
		Settings.lastOpenedBuild = otherConstants.build
		loadDefaultSplitterKeybinds()
		setGlobalKeybindMonitor()
		
		DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.accessibility.api"), object: nil, queue: nil) { _ in
		  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.reopenToApplyKeybindAlert()
		  }
		}
		
		
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
		]
	)
	
	var viewController: ViewController? {
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
		preferencesWindowController.show()
	}
}
