//
//  UpdaterStuff.swift
//  Splitter
//
//  Created by Michael Berk on 2/14/23.
//  Copyright © 2023 Michael Berk. All rights reserved.
//

import Foundation
import Defaults
import BasicUpdater

class UpdateController:NSObject {
	static let shared = UpdateController()
	
	let updater = Updater(projectURL: URL(string: "https://github.com/michaeljberk/Splitter"), shouldUpdateTo: { release in
		let regexStr = #"\d*$"#
		let tag = release.tagName
		let range = tag.range(of: regexStr, options: .regularExpression)!
		let newBuildStr = String(tag[range])
		let newBuildNum = Int(newBuildStr)!
		let currentBuildStr = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
		let currentBuildNum = Int(currentBuildStr)!
		return newBuildNum > currentBuildNum
	})
	
	@objc func checkForUpdates() {
		updater.checkForUpdates()
	}
	
	func addUpdateCommand() {
		let settingsItem = NSApp.mainMenu!.item(withIdentifier: menuIdentifiers.appMenu.settingsMenuItem)!
		let appMenu = NSApp.mainMenu!.items[0].submenu!
		let settingsIndex = appMenu.index(of: settingsItem)
		let updateItem = NSMenuItem(title: "Check for Updates...", action: #selector(checkForUpdates), keyEquivalent: "")
		updateItem.target = self
		appMenu.insertItem(updateItem, at: settingsIndex + 1)
	}
}
