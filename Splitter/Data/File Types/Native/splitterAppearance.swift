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

struct CodableColor: Codable {
	 var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

	 var nsColor : NSColor {
		return NSColor(red: red, green: green, blue: blue, alpha: alpha)
	 }
	init (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
		self.red = red
		self.green = green
		self.blue = blue
		self.alpha = alpha
	}
	init (red: Float, green: Float, blue: Float, alpha: Float) {
		self.red = CGFloat(red)
		self.green = CGFloat(green)
		self.blue = CGFloat(blue)
		self.alpha = CGFloat(alpha)
	}

	 init(nsColor : NSColor) {
		let ciColor = CIColor(color: nsColor)!
		red = ciColor.red
		green = ciColor.green
		blue = ciColor.blue
		alpha = ciColor.alpha
//		nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		 
	 }
	
	init(json: JSON) {
		let red = json.dictionary?["red"]?.floatValue
		let green = json.dictionary?["green"]?.floatValue
		let blue = json.dictionary?["blue"]?.floatValue
		let alpha = json.dictionary?["alpha"]?.floatValue
		self.init(red: red!, green: green!, blue: blue!, alpha: alpha!)
	}
}

struct splitterAppearance: Codable {
	var hideTitlebar: Bool?
	var hideButtons: Bool?
	var keepOnTop: Bool?
	var hideColumns: [String: Bool]?  = [:]
	var columnSizes: [String: CGFloat]? = [:]
	var windowWidth: CGFloat?
	var windowHeight: CGFloat?
	var roundTo: Int?
	
	var bgColor: CodableColor?
	var tableColor: CodableColor?
	var textColor: CodableColor?
	var selectColor: CodableColor?
	
	
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
		self.bgColor = CodableColor(nsColor: viewController.bgColor)
		self.tableColor = CodableColor(nsColor: viewController.tableBGColor)
		self.textColor = CodableColor(nsColor: viewController.textColor)
		self.selectColor = CodableColor(nsColor: viewController.selectedColor)
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
		if let bgColorDict = json.dictionary?["bgColor"] {
			self.bgColor = CodableColor(json: bgColorDict)
		}
		if let tableColorDict = json.dictionary?["tableColor"] {
			self.tableColor = CodableColor(json: tableColorDict)
		}
		if let textColorDict = json.dictionary?["textColor"] {
			self.textColor = CodableColor(json: textColorDict)
		}
		if let selectColorDict = json.dictionary?["selectColor"] {
			self.selectColor = CodableColor(json: selectColorDict)
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
		if let bgc = appearance.bgColor?.nsColor {
			bgColor = bgc
		}
		if let tableC = appearance.tableColor?.nsColor {
			tableBGColor = tableC
			(NSApp.delegate as! AppDelegate).headColor = tableBGColor
		}
		if let textC = appearance.textColor?.nsColor {
//			tableBGColor = tableC
			if textC == NSColor.textColor {
				textColor = .textColor
			} else {
				textColor = textC
			}
		}
		
		if let selectC = appearance.selectColor?.nsColor {
			selectedColor = selectC
		}
		
		
		roundTo = SplitRounding(rawValue: appearance.roundTo ?? 0) ?? SplitRounding.tenths
		splitsTableView.reloadData()
		setColorForControls()
		
	}
}
