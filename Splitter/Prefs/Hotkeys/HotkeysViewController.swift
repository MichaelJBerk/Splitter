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

final class HotkeysViewController: NSViewController, PreferencePane {
	let preferencePaneIdentifier = Preferences.PaneIdentifier.hotkeys
	let preferencePaneTitle = "Hotkeys"
    var toolbarItemIcon: NSImage {
        if #available(macOS 10.16, *) {
            return NSImage(systemSymbolName: "text.and.command.macwindow", accessibilityDescription: "Hotkeys")!
        } else {
            return #imageLiteral(resourceName: "Hotkeys")
        }
    }
	@IBOutlet weak var hotkeysTableView: NSTableView!
	
	@IBOutlet weak var globalHotkeysCheck: NSButton!
	@IBOutlet weak var outOfTableButton: NSButton!
	
	@IBOutlet weak var globalKeybindsHelpButton: NSButton!
	
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
		globalHotkeysCheck.state = .init(bool: Settings.enableGlobalHotkeys)
		context = UnsafeMutableRawPointer(observationInfo)
		for key in KeybindSettingsKey.allCases {
			
			NSUserDefaultsController.shared.addObserver(self, forKeyPath: "@values.\(key.rawValue)", options: .new, context: context)
		}
	}
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if context == self.context {
//			let c = change[.newKey] as?
			let setting = KeybindSettingsKey(rawValue: keyPath!)
			
		}
	}
	
	override func viewWillDisappear() {
		let app = NSApplication.shared.delegate as! AppDelegate
		app.hotkeyController = nil
		
	}
	
	override func viewWillAppear() {
	}
	
	@IBAction func globalHotkeysToggle(_ sender: NSButton) {
		guard let appDel = AppDelegate.shared else {return}
		if appDel.accessibilityGranted() {
			Settings.enableGlobalHotkeys = globalHotkeysCheck.state.toBool()
		} else {
			sender.state = .init(bool: false)
			appDel.keybindAlert()
		}
		let rowIndexes = IndexSet(arrayLiteral: 0)
		let colIndexes = IndexSet(arrayLiteral: 1)
		hotkeysTableView.reloadData(forRowIndexes: rowIndexes, columnIndexes: colIndexes)
	}
	
	@objc func openTellMeMore() {
		NSWorkspace.shared.open(URL(string: "https://splitter.mberk.com/notAnotherTripToSystemPreferences.html")!)
	}
	
	@IBAction func globalHelpClicked(_ sender: Any) {
		let helpText = """
When enabled, hotkeys will activate even when Splitter is not the currently active app
"""
		
		let alert = NSAlert()
		alert.messageText = helpText
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "Tell Me More")
		alert.beginSheetModal(for: self.view.window!, completionHandler: { response in
			switch response {
			case .alertSecondButtonReturn:
				self.openTellMeMore()
			default:
				return
			}
		})
//		switch alert.runModal() {
//		case .alertSecondButtonReturn:
//			self.openTellMeMore()
//
//		default: return
//		}
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
					app.appKeybinds[row]?.keybind = short?.shortcutValue
					app.updateKeyEquivs()
				}
				if !(Settings.enableGlobalHotkeys) {
					if let title = app.appKeybinds[row]?.title, title == .BringToFront {
						short?.isEnabled = false
					}
				} else {
					short?.isEnabled = true
				}
				return cell
			}
			
		}
		
		let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as! NSTableCellView
		return cell
		
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
