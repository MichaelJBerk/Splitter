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
	
//	var keybinds: [MASShortcut?] = []
	
	
	override var nibName: NSNib.Name? { "HotkeysViewController" }

	override func viewDidLoad() {
		super.viewDidLoad()
//		cellButton = hotkeysTableView.cellButton
		
		
//		cellButton.action = #selector(clickCellButton(_:))
//		NSApplication.shared.delegate.hotkey
		let app = NSApplication.shared.delegate as! AppDelegate
		
		
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
		
//		keybinds = app.keybinds
//		print("appear ", app.keybinds[0].globalKeybind?.description)
	}
	
	@IBAction func globalHotkeysToggle(_ sender: Any) {
		Settings.enableGlobalHotkeys = globalHotkeysCheck.state.toBool()
		if let app = NSApp.delegate as? AppDelegate {
			app.globalShortcuts = globalHotkeysCheck.state.toBool()
		}
//		if let app = NSApp.delegate as? AppDelegate {
//			for k in app.keybinds {
//				print(k.hotkey?.isPaused)
//			}
//		}
	}
	
	@IBAction func clearHotkeyButtons(_ sender: Any) {
		if let app = NSApp.delegate as? AppDelegate {
			
		}
		
		hotkeysTableView.reloadData()
	}
	
	//MARK: - Setting Hotkeys
		

		
	func getNewGlobalKeybind(_ event: NSEvent) -> GlobalKeybindPreferences? {
		
		//return keybind.getKeybindFromEvent
		return nil
	}
	
	
	func updateKeybindButton(_ globalKeybindPreference : GlobalKeybindPreferences) {
		
		//TODO: Update title
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
		return app?.appKeybinds.count ?? 0//app?.keybinds.count ?? 1
	}
}

extension HotkeysViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var cellText = ""
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
//			cellText = defaultHotkeys[row]
			cellIdentifier = "Hotkeys"
			
			
			if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? buttonCell {
				
				
				let short = cell.cellShortcutView
				let val = MASShortcutValidator()
				val.allowAnyShortcutWithOptionModifier = true
				short?.shortcutValidator = val
				short?.associatedUserDefaultsKey = app.appKeybinds[row]?.settings.rawValue
				
				short?.shortcutValueChange = { (sender) in
					if let sv = short?.shortcutValue {
						short?.associatedUserDefaultsKey = app.appKeybinds[row]?.settings.rawValue
						

						app.updateSplitterKeybind(keybind: app.appKeybinds[row]!.title, shortcut: short!.shortcutValue)
					}
					
					
//					MASShortcutMonitor.shared()?.register(v, withAction: )
					
					
					
					
//					MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: SettingsKeys.keybindKeys.bringToFront, toAction: callback)
//					MASShortcutMonitor.shared().register(short?.shortcutValue, withAction: callback)
					
				}
				
//				cell.cellShortcutView.shortcutValueChange = { (sender) in
//					var callback: () -> Void
//					callback = app.frontHandler
//
//					cell.cellShortcutView.associatedUserDefaultsKey = SettingsKeys.keybindKeys.bringToFront
//					MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: SettingsKeys.keybindKeys.bringToFront, toAction: callback)
//					let sk: SplitterKeybind = cell.cellShortcutView!.shortcutValue as! SplitterKeybind
//					callback = {
//						cell.clickthing(cell.cellShortcutView)
//					}
//					callback = {
//						cell.hotkeyHandler(cell.cellShortcutView.shortcutValue)
//					}
					
//					MASShortcutMonitor.shared()?.register(cell.cellShortcutView.shortcutValue, withAction: callback)
//				}
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
// 				h.updateGlobalShortcut(event)
			}
		}
	}
	
		
}


//
class buttonCell: NSTableCellView {

//	@IBOutlet weak var cellButton: NSButton!
	
//	func clickthing(_ sender: MASShortcutView?) -> ((MASShortcutView?) -> Void)? {
//
//		var callback = {
//			print("hey")
//		}
//		print("laaaaa")
//		return nil
		
//	}
//	func hotkeyHandler(_ sender: MASShortcut?) {
//		let hey = MASShortcutMonitor.shared().map( {(thing) in
//
//			print(thing)
//			}
//		)
//		let hey2 = MASHotKey.registeredHotKey(with: sender!)
//		hey2?.action
//
//
//	}
//
	
	@IBOutlet weak var cellShortcutView: MASShortcutView!

}


