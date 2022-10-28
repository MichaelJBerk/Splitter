//
//  HotkeysViewController.swift
//  Splitter
//
//  Created by Michael Berk on 1/7/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences
import Files
import SwiftUI

final class HotkeysViewController: NSViewController, PreferencePane {
	let preferencePaneIdentifier = Preferences.PaneIdentifier.hotkeys
	let preferencePaneTitle = "Hotkeys"
	
	var shortcutsRequiringGlobalHotkeys = Set<MASShortcutView>()
    var toolbarItemIcon: NSImage {
        if #available(macOS 10.16, *) {
            return NSImage(systemSymbolName: "text.and.command.macwindow", accessibilityDescription: "Hotkeys")!
        } else {
            return #imageLiteral(resourceName: "Hotkeys")
        }
    }
	@IBOutlet weak var hotkeysTableView: NSTableView!
	
	@IBOutlet weak var outOfTableButton: NSButton!
	
	var viewController: ViewController? {
		if let vc =  NSApp.windows.first?.contentViewController as? ViewController {
			return vc
		}
		return nil
	}
	
	override var nibName: NSNib.Name? { "HotkeysViewController" }
	var context: UnsafeMutableRawPointer?
	override func viewDidLoad() {
		super.viewDidLoad()

		
		preferredContentSize = NSSize(width: view.frame.width, height: view.frame.height)
		hotkeysTableView.delegate = self
		hotkeysTableView.dataSource = self
		hotkeysTableView.reloadData()
		
		hotkeysTableView.reloadData()
		context = UnsafeMutableRawPointer(observationInfo)
		for key in KeybindSettingsKey.allCases {
			NSUserDefaultsController.shared.addObserver(self, forKeyPath: "@values.\(key.rawValue)", options: .new, context: context)
		}
		DistributedNotificationCenter.default().addObserver(forName: AppDelegate.acessibilityNotificationName, object: nil, queue: nil) { thing in
			//Wait a second, otherwise `isAccessibilityGranted` may return the incorrect value
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					self.updateGlobalOnlyHotkeysEnabled()
			}
		}
	}
	
	override func viewWillDisappear() {
		let app = NSApplication.shared.delegate as! AppDelegate
		app.hotkeyController = nil
		
	}
	
	override func viewWillAppear() {
	}
	
	@IBAction func advancedButtonAction(_ sender: Any) {
		let advanced = AdvancedHotkeyViewController(nibName: "AdvancedHotkeyViewController", bundle: nil)
		advanced.hotkeyVC = self
		self.presentAsSheet(advanced)
		
	}
	
	@IBAction func clearHotkeyButtons(_ sender: Any) {
		if let app = NSApp.delegate as? AppDelegate {
			
			var i = 0
			while i < app.appKeybinds.count {
				let view = hotkeysTableView.rowView(atRow: i, makeIfNecessary: false)?.view(atColumn: 1) as! buttonCell
				view.cellShortcutView.shortcutValue = nil
				i = i + 1
			}
		}
		
		hotkeysTableView.reloadData()
	}
}

extension HotkeysViewController: NSTableViewDataSource {
	func  numberOfRows(in tableView: NSTableView) -> Int {
		let app = NSApp.delegate as? AppDelegate
		return app?.appKeybinds.count ?? 0//app?.keybinds.count ?? 1
	}
}

extension HotkeysViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var cellIdentifier = ""
		let app = NSApp.delegate as! AppDelegate
		if tableColumn == tableView.tableColumns[0] {
			cellIdentifier = "HotkeyNames"
			if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
				if let text = app.appKeybinds[row]?.title.rawValue {
					cell.textField?.stringValue = text
				} else {
					cell.textField?.stringValue = "Nothing for now"
				}
				return cell
			}
			
		} else {
			cellIdentifier = "Hotkeys"
			if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? buttonCell {
				
				
				let short = cell.cellShortcutView
				let val = SplitterShortcutValdator()
				short?.shortcutValidator = val
				
				let set = app.appKeybinds[row]!.settings.rawValue
				short?.associatedUserDefaultsKey = set
				short?.shortcutValueChange = { (sender) in
					if let shortcut = sender?.shortcutValue, shortcut.isFunctionKey == true {
						let alert = NSAlert()
						let keyString = shortcut.keyCodeString.description
						alert.messageText = "\(keyString) isn't supported as a global hotkey."
						alert.informativeText = "Function keys, such as \(keyString) aren't currently supported supported as global hotkeys. They will only work while Splitter is active."
						alert.showsSuppressionButton = true
						if !Settings.warningSuppresed(.hotkeysCantBeFunctionKey) {
							alert.beginSheetModal(for: self.view.window!) { response in
								if alert.suppressionButton?.state == .on {
									Settings.setWarning(.hotkeysCantBeFunctionKey, suppresed: true)
								}
							}
						}
					}
					app.appKeybinds[row]?.keybind = short?.shortcutValue
					app.updateKeyEquivs()
				}
				if let short, app.appKeybinds[row]?.title == .BringToFront {
					shortcutsRequiringGlobalHotkeys.insert(short)
				}
				updateGlobalOnlyHotkeysEnabled()
				return cell
			}
			
		}
		
		let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as! NSTableCellView
		return cell
		
	}
	
	///Indicates if hotkeys that are only available when Global Hotkeys are turned on should be enabled
	var shouldEnableGlobalOnlyHotkeys: Bool {
		AppDelegate.isAccessibilityGranted && Settings.enableGlobalHotkeys
	}
	
	///
	func updateGlobalOnlyHotkeysEnabled() {
		for shortcut in shortcutsRequiringGlobalHotkeys {
			shortcut.isEnabled = shouldEnableGlobalOnlyHotkeys
		}
		
	}
}

class buttonCell: NSTableCellView {
	
	@IBOutlet weak var cellShortcutView: MASShortcutView!

}


class SplitterShortcutValdator: MASShortcutValidator {
	override init() {
		super.init()
		self.allowAnyShortcutWithOptionModifier = true
	}
	
	override func isShortcutValid(_ shortcut: MASShortcut!) -> Bool {
		return true
	}
	
}

extension MASShortcut {
	var isFunctionKey: Bool {
		switch self.keyCode {
		case
			kVK_F1,
			kVK_F2,
			kVK_F3,
			kVK_F4,
			kVK_F5,
			kVK_F6,
			kVK_F7,
			kVK_F8,
			kVK_F9,
			kVK_F10,
			kVK_F11,
			kVK_F12,
			kVK_F13,
			kVK_F14,
			kVK_F15,
			kVK_F16,
			kVK_F17,
			kVK_F18,
		kVK_F19:
			return true
		default:
			return false
		}
		
	}
}
