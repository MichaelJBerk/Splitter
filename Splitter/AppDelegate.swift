//
//  AppDelegate.swift
//  Splitter
//
//  Created by Michael Berk on 12/22/19.
//  Copyright © 2019 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences
import Keys
import Files
import SwiftUI
import SplitsIOKit

extension NSApplication {
	static let appDelegate = NSApp.delegate as! AppDelegate
}

class otherConstants {

public static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
public static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet private var window: NSWindow!
	
	static var splitsIOAuth = SplitsIOAuth(client: SplitterKeys().splitsioclient, secret: SplitterKeys().splitsiosecret, redirects: "splitter://login")
	public static var splitsIOKit = SplitsIOKit(auth: splitsIOAuth, url: Settings.splitsIOURL)
	
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
		alert.addButton(withTitle: "Allow")
		alert.addButton(withTitle: "Dismiss")
		alert.showsHelp = true
		alert.delegate = keybindAlertDel
		switch alert.runModal() {
			
		case .alertFirstButtonReturn:
			NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
		default:
			return
		}
	}
	var keybindAlertDel = KeybindAlertDelegate()
	
	class KeybindAlertDelegate: NSObject, NSAlertDelegate {
		func alertShowHelp(_ alert: NSAlert) -> Bool {
			NSWorkspace.shared.open(URL(string: "https://mberk.com/splitter/notAnotherTripToSystemPreferences.html")!)
		}
	}
	func reopenToApplyKeybindAlert() {
		let alert = NSAlert()
		alert.messageText = "Splitter's privacy settings have been changed"
		alert.informativeText = "In order for these changes to take effect, you will need to quit and reopen Splitter."
		alert.addButton(withTitle: "Dismiss")
		alert.runModal()
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
	
	///Invoked immediately before opening an untitled file.
	///
	///This is used to make the welcome window appear on startup, or when there's no open file.
	func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
		if #available(macOS 10.15, *) {
			if Settings.showWelcomeWindow {
				DispatchQueue.main.async {
					guard sender.keyWindow == nil else { return }
					self.openWelcomeWindow()
				}
				return false
			} else {
				return true
			}
		} else {
			return true
		}
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
		let welcomeWindowItem = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.windowMenu.welcomeWindowItem)
		if #available(macOS 10.15, *) {
			welcomeWindowItem?.isHidden = false
		} else {
			welcomeWindowItem?.isHidden = true
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
	}
	//Need to store this as a var on the class or the app will crash when closing the welcome window
	var welcomeWindow: NSWindow!
	var searchWindow: NSWindow!
	
	@available(macOS 10.15, *)
	func openWelcomeWindow() {
		let welcomeView = WelcomeView()
		welcomeWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 460), styleMask: [.fullSizeContentView, .titled, .closable], backing: .buffered, defer: false)
		welcomeWindow.titleVisibility = .hidden
		welcomeWindow.titlebarAppearsTransparent = true
		welcomeWindow.isMovableByWindowBackground = true
		
		welcomeWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
		welcomeWindow.standardWindowButton(.zoomButton)?.isHidden = true
		welcomeWindow.setFrameAutosaveName("Welcome")
		welcomeWindow.contentView = NSHostingView(rootView: welcomeView)
		welcomeWindow.center()
		let wc = WelcomeWindowController(window: welcomeWindow)
		wc.showWindow(nil)
	}
	@IBAction func welcomeWindowMenuItem(_ sender: Any) {
		if #available(macOS 10.15, *) {
			self.openWelcomeWindow()
		}
	}
	@IBAction func searchWindowMenuItem( _ sender: Any) {
		self.openSearchWindow()
	}
	
	func openSearchWindow() {
        
        
		let board = NSStoryboard(name: "DownloadWindow", bundle: nil).instantiateController(withIdentifier: "windowController") as? DownloadWindowController
        if self.searchWindow == nil, let win = board?.window {
            self.searchWindow = win
            win.makeKeyAndOrderFront(nil)
        } else {
            self.searchWindow.makeKeyAndOrderFront(nil)
        }
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	#if DEBUG
	lazy var preferencesWindowController = PreferencesWindowController(
		preferencePanes: [
			DefaultPreferenceViewController(),
			HotkeysViewController(),
			AccountViewController(),
			DebugPrefsViewController()
			]
		
	)
	#else
	lazy var preferencesWindowController = PreferencesWindowController(
		preferencePanes: [
			DefaultPreferenceViewController(),
			HotkeysViewController(),
			AccountViewController()
			]
		
	)
	#endif
	
	
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
	func application(_ application: NSApplication, open urls: [URL]) {
		if let authURL = urls.first(where: { url in
			let comps = URLComponents(string: url.absoluteString)
			return comps?.host == "login"
		}) {
			do {
				try SplitsIOKit.shared.handleRedirectURL(url: authURL)
			} catch {
				print("Redirect Error: ", error)
			}
		}
		
	}

	@IBAction func preferencesMenuItemActionHandler(_ sender: NSMenuItem) {
		
		preferencesWindowController.show()
	}
}
	

extension AppDelegate: NSMenuItemValidation {
	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		if let id = menuItem.identifier, id == menuIdentifiers.windowMenu.welcomeWindowItem {
			if self.welcomeWindow != nil {return !self.welcomeWindow.isVisible}
		}
		return true
	}
}

extension SplitsIOKit {
	public static var shared = AppDelegate.splitsIOKit
}
