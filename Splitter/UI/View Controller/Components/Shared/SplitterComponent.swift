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
	///View used to configure settings for this component
	///
	///This view is displayed when the component is selected in the Layout Editor
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
	
	func updateUI()
}

extension SplitterComponent {
	func updateUI() { }
	
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
			//If, for whatever reason, there's multiple "border" layers, we want to remove all of them
			self.layer?.sublayers?.filter({$0.name == "borderLayer"}).forEach({$0.removeFromSuperlayer()})
		}
	}
	func defaultComponentOptions() -> NSView {
		let visibleCheck = NSButton(checkboxWithTitle: "Hidden", target: self, action: #selector(hide(_:)))
		visibleCheck.state = .init(bool: isHidden)
		let spacingSetting = NSTextField()
		NSLayoutConstraint.activate([
			spacingSetting.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
		])
		spacingSetting.stringValue = "\(afterSpacing)"
		
		NotificationCenter.default.addObserver(forName: NSTextField.textDidChangeNotification, object: spacingSetting, queue: nil, using: { notification in
			//NOTE: Can still enter invalid numbers like 6.0.0
			let charSet = NSCharacterSet(charactersIn: "1234567890.").inverted
			let chars = spacingSetting.stringValue.components(separatedBy: charSet)
			spacingSetting.stringValue = chars.joined()
			self.afterSpacing = CGFloat(Double(spacingSetting.stringValue) ?? Double(self.defaultAfterSpacing))
		})
		
		let spacingLabel = NSTextField(labelWithString: "Spacing (After)")
		let resetButton = ComponentOptionsButton(title: "Reset", clickAction: { _ in
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
