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
		let regexStr = #"[\d .]*-\d*"#
		let tag = release.tagName
		guard let tagVerRange = tag.range(of: regexStr, options: .regularExpression) else {return false}
		let tagVer = tag[tagVerRange]
		let tagVerSplit = tagVer.split(separator: "-")
		guard tagVerSplit.count > 1 else {return false}
		let newBuildStr = tagVerSplit[1]
		guard let newBuildNum = Int(newBuildStr) else {return false}
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
