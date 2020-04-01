//
//  splitterAppearance.swift
//  Splitter
//
//  Created by Michael Berk on 2/12/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON

struct splitterAppearance: Codable {
	var hideTitlebar: Bool?
	var hideButtons: Bool?
	var keepOnTop: Bool?
	var hideColumns: [String: Bool]?  = [:]
	var columnSizes: [String: CGFloat]? = [:]
	var windowWidth: CGFloat?
	var windowHeight: CGFloat?
	var roundTo: Int?
	
	
	
	init(viewController: ViewController) {
		self.hideTitlebar = viewController.titleBarHidden
		self.hideButtons = viewController.UIHidden
		self.keepOnTop = viewController.windowFloat
		self.hideColumns = [:]
		self.columnSizes = [:]
		for c in colIds {
			let colIndex = viewController.splitsTableView.column(withIdentifier: c.value)
			let col = viewController.splitsTableView.tableColumns[colIndex]
			let hidden = col.isHidden
			self.hideColumns?[c.key] = hidden
			
			var size = col.width
			self.columnSizes?[c.key] = size
		}
		self.windowWidth = viewController.view.window?.frame.width
		self.windowHeight = viewController.view.window?.frame.height
		self.roundTo = viewController.roundTo.rawValue
	}
	
	
	init(json: JSON) {
		self.hideTitlebar = json.dictionary?["hideTitlebar"]?.bool
		self.hideButtons = json.dictionary?["hideButtons"]?.bool
		self.keepOnTop = json.dictionary?["keepOnTop"]?.bool
		//showColumns is only for backwards compatibility with betas.
		//TODO: Remove in final version
		if let colDict = json.dictionary?["showColumns"]?.dictionary ?? json.dictionary?["hideColumns"]?.dictionary {
			if json.dictionary?["hideColumns"]?.dictionary == nil {
				let alert = NSAlert()
				alert.messageText = "This file will not be compatible the with the final release of splitter Splitter 1.0"
				alert.informativeText = "Save the file using this version to make it compatible with Splitter 1.0, once it's released"
				alert.alertStyle = .warning
				alert.runModal()
			}
			for c in colDict {
				self.hideColumns?[c.key] = c.value.boolValue
				
			}
		}
		
		if let sizeDict = json.dictionary?["columnSizes"]?.dictionary {
			for s in sizeDict {
				self.columnSizes?[s.key] = CGFloat(s.value.floatValue)
			
			}
		}
		
		//Need to do optional chaining so that CGFloat(x) doesn't complain about an optional value
		if let ww = json.dictionary?["windowWidth"]?.float {
			self.windowWidth = CGFloat(ww)
		}
		if let wh = json.dictionary?["windowHeight"]?.float {
			self.windowHeight = CGFloat(wh)
		}
		self.roundTo = json.dictionary?["roundTo"]?.int
		
		
	}
	
	

}

enum SplitterAppearanceError: Error {
	case encodeError
}

extension ViewController {
	///Sets the appearance of the VC to the contents of a SplitterAppearance object
	func setSplitterAppearance(appearance: splitterAppearance) {
		titleBarHidden = appearance.hideTitlebar ?? Settings.hideTitleBar
		UIHidden = appearance.hideButtons ?? Settings.hideUIButtons
		windowFloat = appearance.keepOnTop ?? Settings.floatWindow
		
		showHideTitleBar()
		showHideUI()
		setFloatingWindow()
		
		if let sc = appearance.hideColumns {
			for c in sc {
				if let id = colIds[c.key] {
					let cIndex = splitsTableView.column(withIdentifier: id)
					splitsTableView.tableColumns[cIndex].isHidden = c.value
				}
			}
		} else {
			for c in splitsTableView.tableColumns {
				switch c.identifier {
				case STVColumnID.previousSplitColumn:
					c.isHidden = true
				default:
					c.isHidden = false
				}
			}
		}
		
		if let cSizes = appearance.columnSizes {
			for c in cSizes {
				if let id = colIds[c.key] {
					let cIndex = splitsTableView.column(withIdentifier: id)
					splitsTableView.tableColumns[cIndex].width = c.value
				}
			}
		}
		
		if view.window != nil && appearance.windowWidth != nil && appearance.windowHeight != nil {
		
			let windowFrame = NSRect(x: view.window!.frame.origin.x, y: view.window!.frame.origin.y, width: appearance.windowWidth!, height: appearance.windowHeight!)
			view.window?.setFrame(windowFrame, display: true)
		}
		
		roundTo = SplitRounding(rawValue: appearance.roundTo ?? 0) ?? SplitRounding.tenths
		splitsTableView.reloadData()
	}
}
