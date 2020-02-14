//
//  HotkeysViewController.swift
//  Splitter
//
//  Created by Michael Berk on 1/7/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences
import HotKey
import Carbon
import Files


final class HotkeysViewController: NSViewController, PreferencePane {
	let preferencePaneIdentifier = PreferencePane.Identifier.hotkeys
	let preferencePaneTitle = "Hotkeys"
	let toolbarItemIcon = #imageLiteral(resourceName: "Hotkeys")
	@IBOutlet weak var hotkeysTableView: NSTableView!
	
	@IBOutlet weak var globalHotkeysCheck: NSButton!
	@IBOutlet weak var outOfTableButton: NSButton!
	
	var cellButton: NSButton!
	var cellForEvent: buttonCell?
	
	var currentKeybind: Keybind?
	
	var viewController: ViewController? {
		if let vc =  NSApp.windows.first?.contentViewController as? ViewController {
			return vc
		}
		return nil
	}
	var listening = false {
		didSet {
			if listening {
				DispatchQueue.main.async {[weak self] in
//					self?.cellButton.highlight(true)
					
				}
			} else {
				DispatchQueue.main.async {[weak self] in
//					self?.cellButton.highlight(false)
				}
			}
		}
	}

	
	
	override var nibName: NSNib.Name? { "HotkeysViewController" }

	override func viewDidLoad() {
		super.viewDidLoad()
//		cellButton = hotkeysTableView.cellButton
		
		
//		cellButton.action = #selector(clickCellButton(_:))
//		NSApplication.shared.delegate.hotkey
		let app = NSApplication.shared.delegate as! AppDelegate
		app.hotkeyController = self
		
		
//		view.window?.windowController
		

		preferredContentSize = NSSize(width: view.frame.width, height: view.frame.height)
		hotkeysTableView.delegate = self
		hotkeysTableView.dataSource = self
		hotkeysTableView.reloadData()
		
		
		
//            updateKeybindButton(globalKeybinds)
//            updateClearButton(globalKeybinds)
//	}
		
		hotkeysTableView.reloadData()
		globalHotkeysCheck.state.fromBool(bool: Settings.enableGlobalHotkeys)
		
	}
	
	override func viewWillDisappear() {
		let app = NSApplication.shared.delegate as! AppDelegate
		app.hotkeyController = nil
		
	}
	
	override func viewWillAppear() {
		let app = NSApplication.shared.delegate as! AppDelegate
		app.hotkeyController = self
//		print("appear ", app.keybinds[0].globalKeybind?.description)
	}
	
	@IBAction func globalHotkeysToggle(_ sender: Any) {
		Settings.enableGlobalHotkeys = globalHotkeysCheck.state.toBool()
//		if let app = NSApp.delegate as? AppDelegate {
//			for k in app.keybinds {
//				print(k.hotkey?.isPaused)
//			}
//		}
	}
	
	@IBAction func clearHotkeyButtons(_ sender: Any) {
		if let app = NSApp.delegate as? AppDelegate {
			app.clearHotkeys()
			
		}
		self.currentKeybind = nil
		hotkeysTableView.reloadData()
	}
	
	//MARK: - Setting Hotkeys
	@IBAction func register(_ sender: Any?){
		unregister(nil)
		listening = true
		view.window?.makeFirstResponder(nil)
	}
		
	func unregister(_ sender: Any?) {
		

		if let s = sender as? buttonCell {
			if let b = s.cellButton {
				b.title = ""
			}
		}
	}
	
	func updateGlobalShortcut(_ event: NSEvent) {
		self.listening = false
		
		if let ck = currentKeybind {
			
			if let newBindD = ck.eventToKeybindPrefs(from: event)?.description {
				ck.updateKeybind(from: event)
				cellForEvent?.cellButton.title = newBindD
				
				
				let app = NSApplication.shared.delegate as! AppDelegate
			
				// Need to dinitalize the hotkeys. Since they will soon be reloaded from the file, it's not a problem.
				// You may wonder why I don't just clear out the keybinds array. Well, I tried doing that, and it would still remember the previous hotkey, so 🤷‍♂️
				for i in app.keybinds {
					i.hotkey = nil
				}

				app.setDefaultKeybindValues()
				app.loadHotkeys()
				
			}
		}
		
		//udpate keybind button
		self.cellForEvent = nil
		
	}
	//	}
		
	func getNewGlobalKeybind(_ event: NSEvent) -> GlobalKeybindPreferences? {
		if let ck = currentKeybind {
			return ck.eventToKeybindPrefs(from: event)
		}
		//return keybind.getKeybindFromEvent
		return nil
	}
	
	
	func updateKeybindButton(_ globalKeybindPreference : GlobalKeybindPreferences) {
		
		cellForEvent?.cellButton.title = globalKeybindPreference.description
	}
	
	//Needs to be here in case this is already activated

	override func keyDown(with event: NSEvent) {
		super.keyDown(with: event)
		
			if listening{
				
				let newKeybind = getNewGlobalKeybind(event)
				updateKeybindButton(newKeybind!)
			}
		
	}
	
}

extension HotkeysViewController: NSTableViewDataSource {
	func  numberOfRows(in tableView: NSTableView) -> Int {
		let app = NSApp.delegate as? AppDelegate
		return app!.keybinds.count
	}
}

extension HotkeysViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var cellText = ""
		var cellIdentifier = ""
		let app = NSApp.delegate as! AppDelegate
		let h = app.keybinds[row]
		if tableColumn == tableView.tableColumns[0] {
			cellText = h.Title.rawValue
			cellIdentifier = "HotkeyNames"
			
			
			if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
				
				cell.textField?.stringValue = cellText
				
				return cell
			}
			
		} else {
//			cellText = defaultHotkeys[row]
			cellIdentifier = "Hotkeys"
			
			if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? buttonCell {
				if let g = h.hotkey?.keyCombo.description{
					cell.cellButton.title = g
				} else {
					cell.cellButton.title = "[Not set]"
				}
				return cell
			}
		}
		
		let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as! NSTableCellView
		return cell
		
	}
	
	
}

extension PreferencesWindowController {
	
	//works when this one is triggered
	override public func keyDown(with event: NSEvent) {
		super.keyDown(with: event)
		
		let app = NSApplication.shared.delegate as! AppDelegate
		if let h = app.hotkeyController  {
			if h.listening {
 				h.updateGlobalShortcut(event)
			}
		}
	}
	
		
}



class buttonCell: NSTableCellView {
	
	@IBOutlet weak var cellButton: NSButton!
	@IBAction func clickCellButton(_ sender: Any) {
		let app = NSApplication.shared.delegate as! AppDelegate
		if let h = app.hotkeyController {
			let row = h.hotkeysTableView.row(for: self)
			let currentKeybind = app.keybinds[row]
			
//			let cb = cellButton
			h.currentKeybind = currentKeybind
			h.cellForEvent = self
			h.register(self)
		}
		
	}
}


