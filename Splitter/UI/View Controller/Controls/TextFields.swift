//
//  TextFields.swift
//  Splitter
//
//  Created by Michael Berk on 3/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

extension NSView {
	func findVC() -> NSViewController? {
		if let nextR = self.nextResponder as? NSViewController {
				   return nextR
		} else if let nextR = self.nextResponder as? NSView {
		   return nextR.findVC()
		} else {
		   return nil
		}
	}
}

class MetadataField: NSTextField {
	
	override func textDidChange(_ notification: Notification) {
		super.textDidChange(notification)
		
		switch controller {
		case .mainViewController:
			let c = findVC() as! ViewController
			if let tabVC = c.advancedPopover?.contentViewController as? AdvancedTabViewController {
				if let infoVC = tabVC.tabView.selectedTabViewItem?.viewController as? InfoOptionsViewController {
					infoVC.runTitleField.stringValue = c.runTitleField.stringValue
					infoVC.categoryField.stringValue = c.categoryField.stringValue
				}
			}
		default:
			let c = findVC() as! InfoOptionsViewController
			if let d = c.delegate {
				d.runTitleField.stringValue = c.runTitleField.stringValue
				d.categoryField.stringValue = c.categoryField.stringValue
			}
		}
	}
	
	var controller: metaController? {
		if (findVC() as? ViewController) != nil {
			return .mainViewController
		} else if (findVC() as? InfoOptionsViewController) != nil {
			return .infoViewController
		}
		return nil
	}
	
	
	enum metaController {
		case mainViewController
		case infoViewController
	}
}
