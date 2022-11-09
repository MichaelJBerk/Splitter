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
	//TODO: Make component options into a separate class
	
	func updateUI() { }
	
	var displayName: String {
		SplitterComponentType.FromType(self)!.displayTitle
	}
	
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
	
	func undoableSetting<T: Equatable>(actionName: String?, oldValue: T, newValue: T, edit: @escaping(Self, T) -> ()) {
		run.undoManager?.registerUndo(withTarget: self, handler: { comp in
			comp.undoableSetting(actionName: actionName, oldValue: newValue, newValue: oldValue, edit: edit)
		})
		if let actionName {
			run.undoManager?.setActionName(actionName)
		}
		edit(self, newValue)
									  
	}
	
	
	///Action when clicking the "Hidden" checkbox for this component
	///
	///In addition to toggling ``NSView.hide()``, it also handles undo management, and setting the button state correctly
	private func hiddenToggleAction(_ button: NSButton) {
		undoableSetting(actionName: "Hide \(displayName)", oldValue: self.isHidden, newValue: !self.isHidden, edit: { comp, val  in
			self.hide()
			button.state = .init(bool: val)
		})
	}
	
	
	///Method used by the "Spacing (After)" text field
	///
	///When the "Spacing (After)" text field is edited, it calls this method to actually set the value.
	///This method also handles undo registration for it, including the ability to update the text field in accordance with the new value.
	private func setAfterSpacing(tf: NSTextField, from current: CGFloat?, to new: CGFloat?) {
		run.undoManager?.registerUndo(withTarget: self, handler: { comp in
			comp.setAfterSpacing(tf: tf, from: new, to: current)
			comp.run.undoManager?.disableUndoRegistration()
			tf.stringValue = "\(current ?? self.defaultAfterSpacing)"
			comp.run.undoManager?.enableUndoRegistration()
		})
		run.undoManager?.setActionName("Set \(self.displayName) Spacing")
		afterSpacing = new ?? defaultAfterSpacing
	}
	
	func defaultComponentOptions() -> NSView {
		let visibleCheck = ComponentOptionsButton(checkboxWithTitle: "Hidden", clickAction: { button in
			self.hiddenToggleAction(button)
		})
		visibleCheck.state = .init(bool: isHidden)
		let spacingSetting = NSTextField()
		NSLayoutConstraint.activate([
			spacingSetting.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
		])
		spacingSetting.stringValue = "\(afterSpacing)"
		NotificationCenter.default.addObserver(forName: NSTextField.textDidBeginEditingNotification, object: spacingSetting, queue: nil, using: { _ in
			if self.run.undoManager?.groupingLevel == 0 {
				self.run.undoManager?.beginUndoGrouping()
			}
		})
		NotificationCenter.default.addObserver(forName: NSTextField.textDidChangeNotification, object: spacingSetting, queue: nil, using: { notification in
			//NOTE: Can still enter invalid numbers like 6.0.0
			let charSet = NSCharacterSet(charactersIn: "1234567890.").inverted
			let chars = spacingSetting.stringValue.components(separatedBy: charSet)
			spacingSetting.stringValue = chars.joined()
			let oldValue = self.afterSpacing;
			let newValue = CGFloat(Double(spacingSetting.stringValue) ?? Double(self.defaultAfterSpacing))
			let tf = notification.object as! NSTextField
			self.setAfterSpacing(tf: tf, from: oldValue, to: newValue)
		})
		NotificationCenter.default.addObserver(forName: NSTextField.textDidEndEditingNotification, object: spacingSetting, queue: nil, using: { _ in
			if self.run.undoManager?.groupingLevel ?? 0 > 0 {
				self.run.undoManager?.endUndoGrouping()
			}
		})
		
		let spacingLabel = NSTextField(labelWithString: "Spacing (Below)")
		let resetButton = ComponentOptionsButton(title: "Reset", clickAction: { _ in
			spacingSetting.stringValue = "\(self.defaultAfterSpacing)"
			let oldValue = self.afterSpacing
			self.undoableSetting(actionName: "Set \(self.displayName) Spacing", oldValue: oldValue, newValue: self.defaultAfterSpacing, edit: {
				$0.afterSpacing = $1
				spacingSetting.stringValue = "\($1)"
			})
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
