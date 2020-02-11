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
	
	//TODO: make them into the actual identifier format instead of strings
	
	enum iconButton {
		static let removeGameIcon = NSUserInterfaceItemIdentifier("removeGameIcon")
		static let removeRunIcon = NSUserInterfaceItemIdentifier("removeRunIcon")
	}
	
	enum appMenu {
		static let updatesMenuItem = NSUserInterfaceItemIdentifier("updatesMenuItem")
	}
	
	enum fileMenu {
		enum importFromMenu{
			static let splitsIO = NSUserInterfaceItemIdentifier("importSplitsIO")
			static let liveSplit = NSUserInterfaceItemIdentifier("importLiveSplit")
		}
		enum exportFromMenu {
			static let splitsIO = NSUserInterfaceItemIdentifier("exportSplitsIO")
		}
	}
	
	
	//MARK: - Timer Menu
	enum timerMenu{
		static let startPause = NSUserInterfaceItemIdentifier("timerStartStop")
		static let stop = NSUserInterfaceItemIdentifier("timerPause")
		
		static let next = NSUserInterfaceItemIdentifier("timerNext")
		static let back = NSUserInterfaceItemIdentifier("timerBack")
		static let reset = NSUserInterfaceItemIdentifier("ResetCurrentSplitMenuItem")
	}
	
	//MARK: - Info Menu
	enum infoMenu {
		static let editTitle = NSUserInterfaceItemIdentifier("editTitleMenuItem")
		static let editSubtitle = NSUserInterfaceItemIdentifier("editSubtitleMenuItem")
		static let editGameIcon = NSUserInterfaceItemIdentifier("editGameIconMenuItem")
		static let clearSplits = NSUserInterfaceItemIdentifier("ClearMenuItem")
	}
	
	//MARK: -  Appearance Menu
	enum appearanceMenu {
		
		static let hideTitleBar = NSUserInterfaceItemIdentifier("HideStoplightsItem")
		static let hideButtons = NSUserInterfaceItemIdentifier("HideButtonsItem")
		static let showBestSplits = NSUserInterfaceItemIdentifier("ShowBestSplits")
	}
	
	//MARK: - Window Menu
	enum windowMenu {
		
		static let windowFloat = NSUserInterfaceItemIdentifier("WindowFloat")
		static let closeCurrentWindow = NSUserInterfaceItemIdentifier("CloseCurrentWindowMenuItem")
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
