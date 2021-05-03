//
//  SplitterComponent.swift
//  Splitter
//
//  Created by Michael Berk on 3/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation

protocol SplitterComponent: NSView {
	var viewController: ViewController! {get set}
	var displayTitle: String { get }
	var displayDescription: String { get }
	var optionsView: NSView! { get }
	var isSelected: Bool {get set}
	var leadingConstraint: NSLayoutConstraint {get}
	var trailingConstraint: NSLayoutConstraint {get}
	var defaultAfterSpacing: CGFloat {get}
	var customSpacing: CGFloat? {get set}
	var selectedLayer: CALayer {get}
	var run: SplitterRun! {get set}
	
	func didSetSelected()
	func saveState() throws -> ComponentState
	func loadState(from state: ComponentState) throws
}

extension SplitterComponent {
	var leadingConstraint: NSLayoutConstraint {
		self.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 7)
	}
	var trailingConstraint: NSLayoutConstraint {
		self.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -7)
	}
	var selectedLayer: CALayer {
		let newLayer = CALayer()
		newLayer.frame = self.bounds
		newLayer.borderWidth = 2
		newLayer.borderColor = NSColor.selectedControlColor.cgColor
		newLayer.cornerRadius = 10
		newLayer.name = "borderLayer"
		return newLayer
	}
	
	
	func didSetSelected() {
		if isSelected {
			self.wantsLayer = true
			self.layer?.addSublayer(selectedLayer)
		} else {
			self.layer?.sublayers?.first(where: {$0.name == "borderLayer"})?.removeFromSuperlayer()
		}
	}
	func defaultComponentOptions() -> NSView {
		let visibleCheck = NSButton(checkboxWithTitle: "Hidden", target: self, action: #selector(hide(_:)))
		visibleCheck.state = .init(bool: isHidden)
		let spacingSetting = NSTextField()
		spacingSetting.stringValue = "\(afterSpacing)"
		
		NotificationCenter.default.addObserver(forName: NSTextField.textDidChangeNotification, object: spacingSetting, queue: nil, using: { notification in
			//NOTE: Can still enter invalid numbers like 6.0.0
			let charSet = NSCharacterSet(charactersIn: "1234567890.").inverted
			let chars = spacingSetting.stringValue.components(separatedBy: charSet)
			spacingSetting.stringValue = chars.joined()
			self.afterSpacing = CGFloat(Double(spacingSetting.stringValue) ?? Double(self.defaultAfterSpacing))
		})
		
		let spacingLabel = NSTextField(labelWithString: "Spacing (After)")
		let resetButton = ComponentOptionsButton(title: "Reset", clickAction: {
			spacingSetting.stringValue = "\(self.defaultAfterSpacing)"
			self.afterSpacing = self.defaultAfterSpacing
		})
		let spacingStack = NSStackView(views: [spacingLabel, spacingSetting, resetButton])
		spacingStack.orientation = .horizontal
		let stacks: [NSView] = [
			visibleCheck,
			spacingStack
		]
		let vStack = ComponentOptionsVstack(views: stacks)
		
		return vStack
	}
	var defaultAfterSpacing: CGFloat {
		return 5
	}
	var afterSpacing: CGFloat {
		get {
			if let cs = customSpacing {
				return cs
			} else {
				return defaultAfterSpacing
			}
		}
		set {
			customSpacing = newValue
			viewController.mainStackView.setCustomSpacing(customSpacing ?? defaultAfterSpacing, after: self)
		}
		
	}
	var optionsView: NSView! {
		let d = self.defaultComponentOptions()
		return d
	}
	func saveState() throws -> ComponentState  {
		let state = saveBasicState()
		return state
	}
	func loadState(from state: ComponentState) throws {
		loadBasicState(from: state.properties)
	}
	
	func basicStateMapping() -> [String: Codable] {
		return ["isHidden": isHidden,
				"afterSpacing": CGFloat(afterSpacing)
		]
	}
	
	func saveBasicState() -> ComponentState {
		return ComponentState(type: SplitterComponentType.FromType(self)!, properties: basicStateMapping())
	}
	func loadBasicState(from state: [String: Codable]) {
		self.isHidden = (state["isHidden"] as! JSONAny).value as! Bool
		
		let f = (state["afterSpacing"] as! JSONAny).value
		self.afterSpacing = CGFloat(JSONAny.adaptToFloat(value: f))
	}
}

extension JSONAny {
	static func adaptToFloat(value: Any) -> Float {
		if value is Int64 {
			return Float(value as! Int64)
		} else if value is Double {
			return Float(value as! Double)
		} else {
			return 0
		}
	}
}

extension SplitterComponent where Self: NSView {
	
}

protocol SplitterComponentState: Codable {
	var afterSpacing: Float { get set }
	var isHidden: Bool { get set }
	var componentType: SplitterComponentType {get}
}

extension SplitterComponentState {
	
	static func decode<T: SplitterComponentState>(data: Data) throws -> T {
		return try JSONDecoder().decode(T.self, from: data)
	}
	func encode() throws -> Data {
		return try JSONEncoder().encode(self)
	}
	
}


struct BasicComponentState: SplitterComponentState {
	var componentType: SplitterComponentType
	var afterSpacing: Float
	var isHidden: Bool
	
}
enum SplitterComponentType: Int, Codable, CaseIterable {
	case title
	case splits
	case tableOptions
	case time
	case start
	case prevNext
	case sumOfBest
	
	var componentType: SplitterComponent.Type {
		switch self {
		case .title:
			return TitleComponent.self
		case .splits:
			return SplitsComponent.self
		case .tableOptions:
			return OptionsRow.self
		case .time:
			return TimeRow.self
		case .start:
			return StartRow.self
		case .prevNext:
			return PrevNextRow.self
		case .sumOfBest:
			return SumOfBestComponent.self
		}
	}
	static func FromType(_ type: SplitterComponent) -> SplitterComponentType? {
		//Switch won't work here, and I have no idea why
		if type is TitleComponent {
			return .title
		} else if type is SplitsComponent {
			return .splits
			
		} else if type is OptionsRow {
			return .tableOptions
		} else if type is TimeRow {
			return .time
		} else if type is StartRow {
			return .start
		} else if type is PrevNextRow {
			return .prevNext
		} else if type is SumOfBestComponent {
			return .sumOfBest
		}
		return nil
	}
}

typealias ComponentStateDict = [String: JSONAny]



//enum ComponentStateType: Codable {
//	case basic(BasicComponentState)
//	case title(TitleComponent.TitleComponentState)
//	case timeRow(TimeRow.TimeRowState)
//	case optionsRow(OptionsRow.OptionsRowState)
//	case splits(SplitsComponent.SplitsComponentState)
//
//	init(from decoder: Decoder) throws {
//		let container = try decoder.singleValueContainer()
//		if let basic = try? container.decode(BasicComponentState.self) {
//			self = .basic(basic)
//		}
//	}
//	func encode(to encoder: Encoder) throws {
//
//	}
//
//}

protocol LiveSplitSplitterComponent: SplitterComponent {
	
}

extension NSView {
	@objc func hide(_ sender: Any?) {
		self.isHidden.toggle()
	}
}
class ComponentOptionsButton: NSButton {
	var clickAction: () -> () = {}
	override func mouseDown(with event: NSEvent) {
		super.mouseDown(with: event)
		clickAction()
	}
	
	convenience init (checkboxWithTitle title: String, clickAction: @escaping () -> ()) {
		self.init(checkboxWithTitle: title, target: nil, action: nil)
		self.clickAction = clickAction
	}
	convenience init (title: String, clickAction: @escaping () -> ()) {
		self.init(title: title, target: nil, action: nil)
		self.clickAction = clickAction
	}
}

class ComponentOptionsVstack: NSStackView {
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.orientation = .vertical
		self.alignment = .leading
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var isFlipped: Bool {
		return true
	}
}
