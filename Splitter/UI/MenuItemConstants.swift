//
//  MenuItemTags.swift
//  Splitter
//
//  Created by Michael Berk on 1/7/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

enum menuIdentifiers {
	
	enum iconButton {
		static let removeGameIcon = NSUserInterfaceItemIdentifier("removeGameIcon")
		static let removeRunIcon = NSUserInterfaceItemIdentifier("removeRunIcon")
	}
	
	//MARK: - App Menu
	enum appMenu {
		static let updatesMenuItem = NSUserInterfaceItemIdentifier("updatesMenuItem")
		static let customizeTouchBarItem = NSUserInterfaceItemIdentifier("customizeTouchBarItem")
	}
	
	//MARK: - File Menu
	enum fileMenu {
		
		static let newFromSplitsIO = NSUserInterfaceItemIdentifier("newFromSplitsIO")
		static let uploadToSplitsIO = NSUserInterfaceItemIdentifier("uploadToSplitsIO")
	}
	
	//MARK: - Timer Menu
	enum runMenu{
		static let StartSplit = NSUserInterfaceItemIdentifier("timerStartStop")
		static let stop = NSUserInterfaceItemIdentifier("stopTimer")
		static let pause = NSUserInterfaceItemIdentifier("pauseTimer")
		
		static let back = NSUserInterfaceItemIdentifier("timerBack")
		static let skipSplit = NSUserInterfaceItemIdentifier("skipSplit")
		
		static let info = NSUserInterfaceItemIdentifier("InfoMenuBarItem")
		
		static let editSegments = NSUserInterfaceItemIdentifier("editSegmentsMenuItem")
	}
	
	//MARK: -  Appearance Menu
	enum appearanceMenu {
		
		static let hideTitleBar = NSUserInterfaceItemIdentifier("HideStoplightsItem")
		static let hideButtons = NSUserInterfaceItemIdentifier("HideButtonsItem")
		
		static let showColumnOptions = NSUserInterfaceItemIdentifier("showColumnOptions")
	}
	
	//MARK: - Window Menu
	enum windowMenu {
		
		static let windowFloat = NSUserInterfaceItemIdentifier("WindowFloat")
		static let closeCurrentWindow = NSUserInterfaceItemIdentifier("CloseCurrentWindowMenuItem")
		static let welcomeWindowItem = NSUserInterfaceItemIdentifier("welcomeWindowMenuItem")
	}
	
	//MARK: Right-Click Menu
	///Menu items for the main View Controller
	enum runVCMenu {
		static let infoPanel = NSUserInterfaceItemIdentifier("InfoMenuItem")
	}
}

//MARK: ButtonIdentifiers

enum buttonIdentifiers {
//MARK: - Trash Can Button
	static let TrashCanClearCurrentTime = NSUserInterfaceItemIdentifier(rawValue: "ClearCurrentTimeMenuItem")
	static let TrashCanClearAllSplits = NSUserInterfaceItemIdentifier(rawValue: "ClearAllSplitsMenuItem")
	
//	MARK: -
	static let GameIconButton = NSUserInterfaceItemIdentifier("GameIconButton")
}

extension NSMenu {
	
	///Returns the menu item with the given identifier
	func item(withIdentifier: NSUserInterfaceItemIdentifier) -> NSMenuItem? {
		for i in items {
			if let id = i.identifier {
				if id == withIdentifier {
					return i
				}
			}
			if let im = i.submenu{
				let subItem = im.item(withIdentifier: withIdentifier)
				if let sid = subItem?.identifier {
					if sid == withIdentifier{
						return subItem
					}
				}
			}
		}
		return nil
	}

}
