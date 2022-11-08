//
//  AppDelegate.swift
//  Splitter
//
//  Created by Michael Berk on 12/22/19.
//  Copyright © 2019 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences
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
	
	static func getFromInfo(key: String) -> String? {
		return Bundle.main.object(forInfoDictionaryKey: key) as? String
	}
	
	static var splitsioclient: String {
		getFromInfo(key: "splitsioclient")!
	}
	static var splitsiosecret: String {
		getFromInfo(key: "splitsiosecret")!
	}
	
	static var splitsIOAuth = SplitsIOAuth(client: splitsioclient, secret: splitsiosecret, redirects: "splitter://login", url: Settings.splitsIOURL.absoluteString)
	public static var splitsIOKit = SplitsIOKit(auth: splitsIOAuth, url: Settings.splitsIOURL)
	
	public var hotkeyController: HotkeysViewController?
	public static var shared: AppDelegate? = NSApplication.shared.delegate as? AppDelegate
	var appKeybinds: [SplitterKeybind?] = []

	var statusBarController: StatusBarController!
	
	static var acessibilityNotificationName: NSNotification.Name {
		NSNotification.Name("com.apple.accessibility.api")
	}
	
	///Checks if Accessibility permissions are granted
	static var isAccessibilityGranted: Bool {
		return AXIsProcessTrusted()
	}
	
	/// Performs the appropriate keybind action for the given event
	/// - Parameter event: `NSEvent` to perform the keybind action for
	///
	/// When run, this method will take find the key that triggered `event` and perform its associated keybind action
	func performGlobalKeybindAction(event: NSEvent) {
		//I'm not using MASHotkey's shortcut binding features, because it blocked events from going to the underlying app
		if Settings.enableGlobalHotkeys {
			for k in self.appKeybinds {
				if let k = k, k == event, let action = keybindAction(keybind: k.title) {
					action()
				}
			}
		}
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
		statusBarController = StatusBarController()
		statusBarController.setupItem()
		if !Settings.notFirstUse {
			//Set default values for settings
			Settings.enableGlobalHotkeys = false
			Settings.notFirstUse = true
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
		setupKeybinds()
		
		print("Auth Enabled: ", SplitsIOKit.shared.hasAuth)
		
		//Add the hotkey event monitor
		NSEvent.addGlobalMonitorForEvents(matching: .keyUp, handler: performGlobalKeybindAction(event:))
		
		if Settings.menuBarMode {
			NSApp.activate(ignoringOtherApps: true)
			newWindowIfNone()
		}
		
		#if DEBUG
		if CommandLine.arguments.contains("-newFile") {
			Settings.showWelcomeWindow = false
		}
		if isUITesting {
			NSApp.windows.forEach({$0.close()})
		}
		if let pathToOpen = ProcessInfo.processInfo.environment["openFile"] {
			let fileToOpen = URL(fileURLWithPath: pathToOpen)
			NSDocumentController.shared.openDocument(withContentsOf: fileToOpen, display: true, completionHandler: {(doc, alreadyOpen, error) in
				
			})
		}
		#endif
	}
	//MARK: - Welcome window
	//Need to store this as a var on the class or the app will crash when closing the welcome window
	var welcomeWindow: KeyDownWindow!
	var searchWindow: NSWindow!
	
	@available(macOS 10.15, *)
	func openWelcomeWindow() {
		let welcomeView = WelcomeView()
		welcomeWindow = KeyDownWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 460), styleMask: [.fullSizeContentView, .titled, .closable], backing: .buffered, defer: false)
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
	
	// MARK: - Menu Items
	@IBAction func welcomeWindowMenuItem(_ sender: Any) {
		if #available(macOS 10.15, *) {
			self.openWelcomeWindow()
		}
	}
	
	@IBAction func searchWindowMenuItem( _ sender: Any) {
		self.openSearchWindow()
	}
	
	//MARK: -
	func openSearchWindow() {
		let board = NSStoryboard(name: "DownloadWindow", bundle: nil).instantiateController(withIdentifier: "windowController") as? DownloadWindowController
		if self.searchWindow == nil, let win = board?.window {
			self.searchWindow = win
			win.makeKeyAndOrderFront(nil)
		} else {
			self.searchWindow.makeKeyAndOrderFront(nil)
		}
	}

	#if DEBUG
	lazy var preferencesWindowController = PreferencesWindowController(
		preferencePanes: [
			GeneralPrefsViewController(),
			HotkeysViewController(),
			AccountViewController(),
			DebugPrefsViewController()
			]
	)
	#else
	lazy var preferencesWindowController = PreferencesWindowController(
		preferencePanes: [
			GeneralPrefsViewController(),
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
	
	//Handles the URL scheme for logging in to splits.io
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
	
	func applicationWillTerminate(_ notification: Notification) {
		NSColorPanel.shared.close()
	}
	
	func newWindowIfNone() {
		let windows = NSApp.windows
			.filter{$0.isVisible}
			.filter{$0.className != "NSStatusBarWindow"}
		if windows.count <= 1 {
			if AppDelegate.shared?.applicationShouldOpenUntitledFile(NSApp) == true {
				NSDocumentController.shared.newDocument(nil)
			}
		}
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
