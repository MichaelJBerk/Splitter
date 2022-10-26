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
	
	@IBOutlet weak var globalHotkeyCheck: NSButton!
	var hotkeyVC: HotkeysViewController!
	
	@IBOutlet weak var debugPrintButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		self.preferredContentSize = .init(width: 480, height: 310)
		globalHotkeyCheck.state = .init(bool: Settings.enableGlobalHotkeys)
		globalHotkeyCheck.isEnabled = AppDelegate.isAccessibilityGranted
		DistributedNotificationCenter.default().addObserver(forName: AppDelegate.acessibilityNotificationName, object: nil, queue: nil) { thing in
			//Wait a second, otherwise `isAccessibilityGranted` may return the incorrect value
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					self.globalHotkeyCheck.isEnabled = AppDelegate.isAccessibilityGranted
			}
		}
    }
	
	@IBAction func globalHotkeyCheckClick(_ sender: NSButton) {
		guard let appDel = AppDelegate.shared else {return}
		if AppDelegate.isAccessibilityGranted {
			Settings.enableGlobalHotkeys = globalHotkeyCheck.state.toBool()
		} else {
			sender.state = .init(bool: false)
			appDel.keybindAlert()
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
	
	func openTellMeMore() {
		NSWorkspace.shared.open(URL(string: "https://splitter.mberk.com/notAnotherTripToSystemPreferences.html")!)
	}
}
