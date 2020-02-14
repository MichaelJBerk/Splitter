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
	let preferencePaneIdentifier = PreferencePane.Identifier.general
	let preferencePaneTitle = "Defaults"
	let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!

	override var nibName: NSNib.Name? { "DefaultPreferenceViewController" }
	
	@IBOutlet weak var titleBarCheck: NSButton!
	@IBOutlet weak var timerButtonCheck: NSButton!
	@IBOutlet weak var floatWindowCheck: NSButton!
	@IBOutlet weak var bestSplitsCheck: NSButton!
	
	
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
		
		titleBarCheck.state.fromBool(bool: Settings.hideTitleBar)
		timerButtonCheck.state.fromBool(bool: Settings.hideUIButtons)
		floatWindowCheck.state.fromBool(bool: Settings.floatWindow)
		bestSplitsCheck.state.fromBool(bool: Settings.showBestSplits)
		
		
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

	@IBAction func bestSplitsToggled(_ sender: Any) {
		Settings.showBestSplits = bestSplitsCheck.state.toBool()
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

	mutating func fromBool(bool: Bool)  {
		if bool {
			self = .on
		} else if !bool {
			self = .off
		}
	}
	
}
