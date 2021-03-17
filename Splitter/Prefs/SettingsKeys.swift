//
//  SettingsKeys.swift
//  Splitter
//
//  Created by Michael Berk on 1/7/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa
import SplitsIOKit

enum SettingsKeys {
	public static let hideTitleBar = "hideTitleBar"
	public static let lastOpenedVersion = "lastOpenedVersion"
	public static let lastOpenedBuild = "lastOpenedBuild"
	public static let hideTimerButtons = "hideTimerButtons"
	public static let floatWindow = "floatWindow"
	public static let notFirstUse = "notFirstUse"
	public static let showBestSplits = "showBestSplits"
	public static let globalHotkeys = "enableGlobalHotkeys"
	public static let showWelcomeWindow = "showWelcomeWindow"
	public static let splitsIOURL = "splitsIOURL"
}

public enum Warning: String {
	case overwritingSplitsFromOlderVersion
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
	///The version of Splitter most recently opened by the user
	public static var lastOpenedVersion: String {
		get {
			UserDefaults.standard.string(forKey: SettingsKeys.lastOpenedVersion) ?? ""
		}
		set {
			UserDefaults.standard.set(otherConstants.version, forKey: SettingsKeys.lastOpenedVersion)
		}
	}
	///The build of Splitter most recently opened by the user
	public static var lastOpenedBuild: String {
		get {
			UserDefaults.standard.string(forKey: SettingsKeys.lastOpenedBuild) ?? ""
		}
		set {
			UserDefaults.standard.set(otherConstants.build, forKey: SettingsKeys.lastOpenedBuild)
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
		}
	}
	public static var showWelcomeWindow: Bool {
		set {
			UserDefaults.standard.set(newValue, forKey: SettingsKeys.showWelcomeWindow)
		}
		get {
			guard UserDefaults.standard.object(forKey: SettingsKeys.showWelcomeWindow) != nil else {return true}
			return UserDefaults.standard.bool(forKey: SettingsKeys.showWelcomeWindow)
		}
		
	}
	public static var splitsIOURL: URL {
		get {
			UserDefaults.standard.url(forKey: SettingsKeys.splitsIOURL) ?? URL(string: "https://splits.io")!
		}
		set {
			UserDefaults.standard.set(newValue, forKey: SettingsKeys.splitsIOURL)
			SplitsIOKit.shared.splitsIOURL = newValue
			
		}
	}
	public static var splitsIOUser: SplitsIORunner? {
		set {
			let encodedData = try? PropertyListEncoder().encode(newValue)
			UserDefaults.standard.setValue(encodedData, forKey: "splitsIOUser")
		}
		get {
			if let data = UserDefaults.standard.value(forKey: "splitsIOUser") as? Data {
				let user = try? PropertyListDecoder().decode(SplitsIORunner.self, from: data)
				return user
			}
			return nil
		}
	}
	
	///`true` if warning is suppresed, `false` if not
	public static func warningSuppresed(_ warning: Warning) -> Bool {
		guard UserDefaults.standard.object(forKey: warning.rawValue) != nil else {return false}
		return UserDefaults.standard.bool(forKey: warning.rawValue)
	}
	public static func setWarning(_ warning: Warning, suppresed: Bool) {
		UserDefaults.standard.setValue(suppresed, forKey: warning.rawValue)
	}
}

