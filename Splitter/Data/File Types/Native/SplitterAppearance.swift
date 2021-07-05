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
import Codextended

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
	 }
	
	init(json: JSON) {
		let red = json.dictionary?["red"]?.floatValue
		let green = json.dictionary?["green"]?.floatValue
		let blue = json.dictionary?["blue"]?.floatValue
		let alpha = json.dictionary?["alpha"]?.floatValue
		self.init(red: red!, green: green!, blue: blue!, alpha: alpha!)
	}
}

struct ComponentState: Codable {
	var type: SplitterComponentType
	var properties: [String: Codable]
	
	init(type: SplitterComponentType, properties: [String: Codable]) {
		self.type = type
		self.properties = properties
	}
	
	init(from decoder: Decoder) throws {
		self.type = try decoder.decode("type")
		self.properties = try decoder.decode("properties", as: [String: JSONAny].self)
	}
	func encode(to encoder: Encoder) throws {
		try encoder.encode(type, for: "type")
		let propMap: [String: JSONAny] = try properties.mapValues({
			let e = try $0.encoded()
			return try e.decoded(as: JSONAny.self, using: JSONDecoder())
			
		})
		try encoder.encode(propMap, for: "properties")
	}
	
}

//for 4.0, only store order; no custom options (yet)

struct SplitterAppearance: Codable {
	var hideTitlebar: Bool?
	var hideButtons: Bool?
	var hideTitle: Bool?
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
	var diffsLongerColor: CodableColor?
	var diffsShorterColor: CodableColor?
	var components: [ComponentState]?
	
	
	//MARK: - Splitter 4.0 Settings
	
	
	
	/// Initalizes a SplitterAppearance Object
	/// - Parameters:
	///   - viewController: `ViewController` to save settings from
	///   - postV4: Determines if values that have been migrated to `layout.lsl` are included. Defaults to `true`.
	init(viewController: ViewController, postV4: Bool = true) {
		self.hideTitlebar = viewController.titleBarHidden
		self.hideButtons = viewController.buttonHidden
		self.keepOnTop = viewController.windowFloat
		self.hideTitle = viewController.hideTitle
		self.hideColumns = [:]
		self.columnSizes = [:]
		for c in colIds {
			let colIndex = viewController.splitsTableView.column(withIdentifier: c.value)
			let col = viewController.splitsTableView.tableColumns[colIndex]
			let hidden = col.isHidden
			self.hideColumns?[c.key] = hidden
			
			let size = col.width
			self.columnSizes?[c.key] = size
		}
		self.windowWidth = viewController.view.window?.frame.width
		self.windowHeight = viewController.view.window?.frame.height
		self.selectColor = CodableColor(nsColor: viewController.selectedColor)
		if !postV4 {
			self.tableColor = CodableColor(nsColor: viewController.run.tableColor)
			self.bgColor = CodableColor(nsColor: viewController.run.backgroundColor)
			self.textColor = CodableColor(nsColor: viewController.run.textColor)
			self.diffsLongerColor = CodableColor(nsColor: viewController.run.longerColor)
			self.diffsShorterColor = CodableColor(nsColor: viewController.run.shorterColor)
		}
		if postV4 {
			self.components = []
			for component in viewController.mainStackView.views.map({$0 as! SplitterComponent}) {
				self.components!.append(try! component.saveState())
			}
		}
	}
	
	
	init(json: JSON) {
		self.hideTitlebar = json.dictionary?["hideTitlebar"]?.bool
		self.hideButtons = json.dictionary?["hideButtons"]?.bool
		self.keepOnTop = json.dictionary?["keepOnTop"]?.bool
		self.hideTitle = json.dictionary?["hideTitle"]?.bool
		if let cols = json.dictionary?["hideColumns"]?.dictionary {
			for c in cols {
				self.hideColumns?[c.key] = c.value.bool
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
		if let diffsLongerColorDict = json.dictionary?["diffsLongerColor"] {
			self.diffsLongerColor = CodableColor(json: diffsLongerColorDict)
		}
		if let diffsShorterColorDict = json.dictionary?["diffsShorterColor"] {
			self.diffsShorterColor = CodableColor(json: diffsShorterColorDict)
		}
		
		
		//Need to do optional chaining so that CGFloat(x) doesn't complain about an optional value
		if let ww = json.dictionary?["windowWidth"]?.float {
			self.windowWidth = CGFloat(ww)
		}
		if let wh = json.dictionary?["windowHeight"]?.float {
			self.windowHeight = CGFloat(wh)
		}
		if let comps = try? json.dictionary?["components"]?.rawData() {
			let components = try! JSONDecoder().decode([ComponentState].self, from: comps)
			self.components = components
			print("")
		}
		
		
	}
	
	

}

enum SplitterAppearanceError: Error {
	case encodeError
}

extension ViewController {
	///Sets the appearance of the VC to the contents of a SplitterAppearance object
	func setSplitterAppearance(appearance: SplitterAppearance) {
		titleBarHidden = appearance.hideTitlebar ?? Settings.hideTitleBar
		buttonHidden = appearance.hideButtons ?? false
		windowFloat = appearance.keepOnTop ?? Settings.floatWindow
		hideTitle = appearance.hideTitle ?? false
		
		//Backwards Compatbility
		if buttonHidden {
			prevNextRow.isHidden = true
			startRow.isHidden = true
			optionsRow.isHidden = true
		}
		
		showHideTitleBar()
		setFloatingWindow()
		showHideTitle()
		
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
			run.backgroundColor = bgc
		}
		if let tableC = appearance.tableColor?.nsColor {
			run.tableColor = tableC
		}
		if let textC = appearance.textColor?.nsColor {
			if textC == NSColor.textColor {
				run.textColor = .textColor
			} else {
				run.textColor = textC
			}
		}
		
		if let selectC = appearance.selectColor?.nsColor {
			selectedColor = selectC
		}
		if let longC = appearance.diffsLongerColor?.nsColor {
			run.longerColor = longC
		}
		if let shortC = appearance.diffsShorterColor?.nsColor {
			run.shorterColor = shortC
		}
		
		splitsTableView.reloadData()
		setColorForControls()
		
	}
}
