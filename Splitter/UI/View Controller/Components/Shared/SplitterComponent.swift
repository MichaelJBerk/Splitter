//
//  SplitterComponent.swift
//  Splitter
//
//  Created by Michael Berk on 3/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation

/**
 The basic skeleton for a component.
 
 Each component must conform to this protocol.

 Components can have various different settings that should be retained when saving the file. It's generally encouraged to piggyback on LiveSplitCore for this as much as possible, i.e. using ``SplitterRun/editLayout(_:)``. However, some settings aren't supported in LSC, or can be relatively difficult to implement in it. For these, use ``ComponentState`` - see ``SplitterComponent/saveState()-153ok`` and ``SplitterComponent/loadState(from:)-60bti`` for more info.
 
**/
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
	
	///Persist the component's state to a `.split` file
	///
	/// - Returns: The state to be saved to `appearance.json`
	///
	/// This method is used when saving the component to a `.split` file. Use it to save state information that is not handled by LiveSplitCore.
	///
	/// - NOTE: The default implementation simply returns ``saveBasicState()``. For a custom implementation of `saveState`, use ``saveBasicState()`` as the "base" state, which you then augment with whatever settings you want.
	///
	/// See ``ComponentState/properties`` for more information
	func saveState() throws -> ComponentState
	///Load the component's state from a `.split` file
	///
	/// - Parameter state: The state loaded from `appearance.json`
	///
	///This method is used when loading the component from a `.split` file. Use this to load state information that is included in the given `state` parameter.
	///
	/// - NOTE: The default implementation simply calls ``loadBasicState(from:)``. For a custom implementation, you should also call it, and then load whatever other state information you want.
	///
	///See ``ComponentState/properties`` for more information
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
		
		let spacingLabel = NSTextField(labelWithString: "Spacing (Below)")
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
