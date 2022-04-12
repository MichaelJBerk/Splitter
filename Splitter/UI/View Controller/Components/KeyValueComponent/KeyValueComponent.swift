//
//  SumOfBestComponent.swift
//  Splitter
//
//  Created by Michael Berk on 4/20/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class KeyValueComponent: NSStackView, SplitterComponent, NibLoadable {
	var run: SplitterRun!
	var customSpacing: CGFloat? = nil
	var key: KeyValueComponentType!
	private var componentIndex: Int!
	private var refreshUITimer = Timer()
	internal override func awakeAfter(using coder: NSCoder) -> Any? {
		return instantiateView() // You need to add this line to load view
	}
	
	static func instantiateView(with run: SplitterRun, _ viewController: ViewController, type: KeyValueComponentType, layoutIndex: Int) -> KeyValueComponent {
		let row: KeyValueComponent = KeyValueComponent.instantiateView()
		row.viewController = viewController
		row.run = run
		row.key = type
		row.componentIndex = layoutIndex
		row.initialization()
		return row
	}
	
	private func initialization() {
		textField.run = run
		keyField.run = run
		run.updateFunctions.append(updateUI)
		self.updateFields()
	}
	
	func updateUI() {
		if !self.isHidden {
			self.updateFields()
		}
	}
	
	func updateFields() {
		let state = run.getLayoutState()
		let kvs = state.componentAsKeyValue(componentIndex)
		keyField.stringValue = kvs.key()
		textField.stringValue = kvs.value()
	}
	
	var viewController: ViewController!
	
	var isSelected: Bool = false {
		didSet {
			didSetSelected()
		}
	}

	@IBOutlet var textField: ThemedTextField!
	@IBOutlet var keyField: ThemedTextField!
	
    
}

enum KeyValueComponentType: String, Codable, CaseIterable {
	case sumOfBest = "Sum of Best Segments"
	case previousSegment = "Previous Segment"
	case totalPlaytime = "Total Playtime"
	case currentSegment = "Segment Time"
	case possibleTimeSave = "Possible Time Save"
	
	var componentType: SplitterComponentType{
		switch self {
		case .sumOfBest:
			return .sumOfBest
		case .previousSegment:
			return .previousSegment
		case .totalPlaytime:
			return .totalPlaytime
		case .currentSegment:
			return .segment
		case .possibleTimeSave:
			return .possibleTimeSave
		}
	}
	
	init(from decoder: Decoder) throws {
		let str: String = try decoder.decodeSingleValue()
		if str == "Sum of Best Segments" {
			self = .sumOfBest
			return
		}
		if str == "Previous Segment" || str == "Live Segment" {
			self = .previousSegment
			return
		}
		if str == "Current Segment" {
			self = .currentSegment
			return
		}
		if str == "Possible Time Save" {
			self = .possibleTimeSave
			return
		}
		throw DecodingError.typeMismatch(Self.Type.self, .init(codingPath: decoder.codingPath, debugDescription: "Can't decode"))
		
	}
}
