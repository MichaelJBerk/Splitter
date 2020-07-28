//
//  GeneralPreferenceViewController.swift
//  Splitter
//
//  Created by Michael Berk on 1/7/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences

final class DefaultPreferenceViewController: NSViewController, PreferencePane {
	let preferencePaneIdentifier = Preferences.PaneIdentifier.general
	let preferencePaneTitle = "Defaults"
	let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!

	override var nibName: NSNib.Name? { "DefaultPreferenceViewController" }
	
	
	@IBOutlet weak var app: NSView!
	@IBOutlet weak var titleBarCheck: NSButton!
	@IBOutlet weak var timerButtonCheck: NSButton!
	@IBOutlet weak var floatWindowCheck: NSButton!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if timerButtonCheck.state == .on {
			print("state: on")
		} else if timerButtonCheck.state == .off {
			print("state: off")
		}
		let UIHidden = UserDefaults.standard.bool(forKey: SettingsKeys.hideTimerButtons)
		
		if UIHidden {
			print("UI Should be hidden")
		} else {
			print("UI Should be visisble")
		}
		
		titleBarCheck.state = .init(bool: Settings.hideTitleBar)
		timerButtonCheck.state = .init(bool: Settings.hideUIButtons)
		floatWindowCheck.state = .init(bool: Settings.floatWindow)
		
		
		preferredContentSize = NSSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
		
		

		
	}
	
	
	
	@IBAction func titleBarToggled(_ sender: Any) {
		Settings.hideTitleBar = titleBarCheck.state.toBool()
	}
	
	@IBAction func buttonsToggled(_ sender: Any) {
		
		Settings.hideUIButtons = timerButtonCheck.state.toBool()
		
	}
	
	@IBAction func floatToggle(_ sender: Any) {
		Settings.floatWindow = floatWindowCheck.state.toBool()
		
	}
	
	
}

extension NSControl.StateValue {
	
	func toBool() -> Bool {
		if self == .on {
			return true
		} else if self == .off {
			return false
		}
		return false
	}
	
	init (bool: Bool) {
		if bool {
			self = .on
		} else {
			self = .off
		}
	}
	
}

extension DefaultPreferenceViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let hey = Array(colIds.keys)
		let h2 = hey[row]
		if let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: nil) as? NSTableCellView {
			cell.textField?.stringValue = h2
			return cell
		}
		return nil
	}
}
extension DefaultPreferenceViewController: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return 1
	}
	
	
}
