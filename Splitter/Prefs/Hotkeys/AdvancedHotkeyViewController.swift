//
//  AdvancedHotkeyViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/10/22.
//  Copyright © 2022 Michael Berk. All rights reserved.
//

import Cocoa
import Carbon

class AdvancedHotkeyViewController: NSViewController {
	
	@IBOutlet weak var globalHotkeySwitch: NSSwitch!
	@IBOutlet weak var goToSettingsSection: NSView!
	@IBOutlet weak var goToSettingsButton: NSButton!
	@IBOutlet weak var enableGlobalHotkeyLabel: NSTextField!
	
	var hotkeyVC: HotkeysViewController!
	
	@IBOutlet weak var debugPrintButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		globalHotkeySwitch.state = .init(bool: Settings.enableGlobalHotkeys)
		
		setAccessibilityPermissionState()
		goToSettingsButton.title = "Open System \(Settings.prefsText)"
		
		DistributedNotificationCenter.default().addObserver(forName: AppDelegate.acessibilityNotificationName, object: nil, queue: nil) { thing in
			//Wait a second, otherwise `isAccessibilityGranted` may return the incorrect value
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					self.setAccessibilityPermissionState()
			}
		}
    }
	
	///Sets the state of views that change depending on whether or not accessibility permission has ben granted
	func setAccessibilityPermissionState() {
		globalHotkeySwitch.isEnabled = AppDelegate.isAccessibilityGranted
		enableGlobalHotkeyLabel.textColor = AppDelegate.isAccessibilityGranted ? .textColor : .disabledControlTextColor
		goToSettingsSection.isHidden = AppDelegate.isAccessibilityGranted
	}
	
	@IBAction func globalHotkeySwitchClick(_ sender: Any?) {
		if AppDelegate.isAccessibilityGranted {
			Settings.enableGlobalHotkeys = globalHotkeySwitch.state.toBool()
		} else {
			globalHotkeySwitch.state = .init(bool: false)
		}
		let rowIndexes = IndexSet(arrayLiteral: 0)
		let colIndexes = IndexSet(arrayLiteral: 1)
		hotkeyVC.hotkeysTableView.reloadData(forRowIndexes: rowIndexes, columnIndexes: colIndexes)
	}
	
	
	@IBAction func globalHotkeysHelpButton(_ sender: Any) {
		openTellMeMore()
	}
	
	@IBAction func printDebugInfo(_ sender: Any) {
		let isTrusted = AXIsProcessTrusted()
		var debugText: String = ""
		debugText.append("Acessibility Permission:  \(isTrusted)\n")
		debugText.append("Global Hotkeys Enabled: \(Settings.enableGlobalHotkeys)\n")
		debugText.append("\n")
		debugText.append("Keybinds:\n")
		guard let appDel = AppDelegate.shared else {return}
		
		for k in appDel.appKeybinds {
			if let k = k {
				debugText.append("\(k.title) \(String(describing: k.keybind)) \(k.settings)\n")
			}
		}
		print(debugText)
		let alert = NSAlert()
		alert.messageText = "Make sure that the hotkeys are actually properly set"
		alert.informativeText = debugText
		alert.runModal()

	}
	
	@IBAction func goToSettingsButtonClicked(_ sender: NSButton) {
		openSystemPrefs()
	}
	
	func openSystemPrefs() {
		NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
	}
	
	func openTellMeMore() {
		NSWorkspace.shared.open(URL(string: "https://splitter.mberk.com/HotkeyPrivacy.html")!)
	}
}
