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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		self.preferredContentSize = .init(width: 480, height: 310)
		globalHotkeyCheck.state = .init(bool: Settings.enableGlobalHotkeys)
    }
	
	@IBAction func globalHotkeyCheckClick(_ sender: NSButton) {
		guard let appDel = AppDelegate.shared else {return}
		if appDel.accessibilityGranted() {
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
		print("Acessibility Permission:  \(isTrusted)")
		print("Global Hotkeys Enabled: \(Settings.enableGlobalHotkeys)")
		print("Keybinds:")
		guard let appDel = AppDelegate.shared else {return}
		for k in appDel.appKeybinds {
			if let k = k {
				
				print("\(k.title) \(String(describing: k.keybind)) \(k.settings)")
			}
		}

	}
	
	func openTellMeMore() {
		NSWorkspace.shared.open(URL(string: "https://splitter.mberk.com/notAnotherTripToSystemPreferences.html")!)
	}
}
