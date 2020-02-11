//
//  SettingsKeys.swift
//  Splitter
//
//  Created by Michael Berk on 1/7/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

enum SettingsKeys {
	public static let hideTitleBar = "hideTitleBar"
	public static let hideTimerButtons = "hideTimerButtons"
	public static let floatWindow = "floatWindow"
	public static let notFirstUse = "notFirstUse"
	public static let showBestSplits = "showBestSplits"
	public static let globalHotkeys = "enableGlobalHotkeys"
}

public struct Settings {
	///Whether or not the title bar is hidden by default on new windows
	public static var hideTitleBar: Bool {
		get {
			UserDefaults.standard.bool(forKey: SettingsKeys.hideTitleBar)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: SettingsKeys.hideTitleBar)
		}
	}
	///Whether or not the window will stay above all other windows by default on new windows
	public static var floatWindow: Bool {
		get {
			UserDefaults.standard.bool(forKey: SettingsKeys.floatWindow)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: SettingsKeys.floatWindow)
		}
	}
	///Whether or not the UI buttons are hidden by default on new windows
	public static var hideUIButtons: Bool {
		get {
			UserDefaults.standard.bool(forKey: SettingsKeys.hideTimerButtons)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: SettingsKeys.hideTimerButtons)
		}
	}
	///Whether or not the "Best Splits" column is hidden by default on new windows
	public static var showBestSplits: Bool {
		get {
			UserDefaults.standard.bool(forKey: SettingsKeys.showBestSplits)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: SettingsKeys.showBestSplits)
		}
	}
	///Whether or not the application has been used before
	public static var notFirstUse: Bool {
		get {
			UserDefaults.standard.bool(forKey: SettingsKeys.notFirstUse)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: SettingsKeys.notFirstUse)
		}
	}
	public static var enableGlobalHotkeys: Bool {
		
		get {
			UserDefaults.standard.bool(forKey: SettingsKeys.globalHotkeys)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: SettingsKeys.globalHotkeys)
			if let app = NSApp.delegate as? AppDelegate {
				app.setPaused(paused: !newValue)
			}
		}
		
	}
}

