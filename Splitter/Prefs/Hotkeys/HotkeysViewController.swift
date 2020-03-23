//
//  HotkeysViewController.swift
//  Splitter
//
//  Created by Michael Berk on 1/7/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences
import Carbon
import Files


final class HotkeysViewController: NSViewController, PreferencePane {
	let preferencePaneIdentifier = PreferencePane.Identifier.hotkeys
	let preferencePaneTitle = "Hotkeys"
	let toolbarItemIcon = #imageLiteral(resourceName: "Hotkeys")
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

	override func viewDidLoad() {
		super.viewDidLoad()

		
		preferredContentSize = NSSize(width: view.frame.width, height: view.frame.height)
		hotkeysTableView.delegate = self
		hotkeysTableView.dataSource = self
		hotkeysTableView.reloadData()
		
		hotkeysTableView.reloadData()
		globalHotkeysCheck.state.fromBool(bool: Settings.enableGlobalHotkeys)
		
	}
	
	override func viewWillDisappear() {
		let app = NSApplication.shared.delegate as! AppDelegate
		app.hotkeyController = nil
		
	}
	
	override func viewWillAppear() {
	}
	
	@IBAction func globalHotkeysToggle(_ sender: Any) {
		Settings.enableGlobalHotkeys = globalHotkeysCheck.state.toBool()
		if let app = NSApp.delegate as? AppDelegate {
			app.globalShortcuts = globalHotkeysCheck.state.toBool()
		}

	}
	@IBAction func globalHelpClicked(_ sender: Any) {
		let helpText = """
When enabled, hotkeys will activate even when Splitter
is not the currently active app
"""
		let pop = NSPopover()
		let tf = NSTextField(labelWithString: helpText)
		let vc = NSViewController()
		vc.view = tf
		pop.contentViewController = vc
		pop.behavior = .transient
		pop.show(relativeTo: globalKeybindsHelpButton.frame, of: self.view, preferredEdge: .minY)
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
				short?.associatedUserDefaultsKey = app.appKeybinds[row]?.settings.rawValue
				short?.shortcutValueChange = { (sender) in
				if short?.shortcutValue != nil {
					short?.associatedUserDefaultsKey = app.appKeybinds[row]?.settings.rawValue
						app.updateSplitterKeybind(keybind: app.appKeybinds[row]!.title, shortcut: short!.shortcutValue)
				}
				if short?.shortcutValue == nil {
					print("empty")
					let sc = app.appKeybinds[row]!
					MASShortcutBinder.shared()?.breakBinding(withDefaultsKey: sc.settings.rawValue)
					MASShortcutMonitor.shared()?.unregisterShortcut(sc.keybind)
					app.appKeybinds[row]!.keybind = nil
					app.updateKeyEquivs()
					}
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
