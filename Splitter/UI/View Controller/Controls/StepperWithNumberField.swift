//
//  StepperWithNumberField.swift
//  Splitter
//
//  Created by Michael Berk on 12/14/23.
//  Copyright © 2023 Michael Berk. All rights reserved.
//

import AppKit

class StepperWithNumberField: NSStackView, NSTextFieldDelegate {
	//Based on  https://stackoverflow.com/questions/70778911/how-do-i-define-an-action-for-a-custom-nscontrol-in-code

	var numberField: NSTextField!
	var stepper: NSStepper!

	var floatValue: Float {

		get {
			return stepper.floatValue
		}
		set {
			stepper.floatValue = newValue
			numberField.floatValue = newValue
		}
	}

	convenience init(minValue: Float, maxValue: Float) {
	
		let numberField = NSTextField()
		numberField.autoresizingMask = [.width, .height]
		numberField.floatValue = 100
		numberField.isEditable = true
		numberField.alignment = .right
	
		let formatter = NumberFormatter()
		formatter.allowsFloats = true
		formatter.minimum = minValue as NSNumber
		formatter.maximum = maxValue as NSNumber

		numberField.formatter = formatter
		let stepper = NSStepper()
		stepper.minValue = Double(minValue)
		stepper.maxValue = Double(maxValue)
		stepper.increment = 1
		stepper.valueWraps = false
		
		self.init(views: [numberField, stepper])
		self.orientation = .horizontal
		self.numberField = numberField
		self.stepper = stepper
		
		self.numberField.delegate = self
		self.stepper.target = self
		self.stepper.action = #selector(self.stepperClicked)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}

	func controlTextDidEndEditing(_ notification: Notification) {
		if let nobj = notification.object as? NSTextField {
			stepper.floatValue = nobj.floatValue
			self.handler?(self)
		}
	}
	
	public typealias Handler = (StepperWithNumberField) -> Void
	var handler: Handler?

	@objc func stepperClicked(sender: NSStepper) {
		numberField.floatValue = stepper.floatValue
		self.handler?(self)
	}
}
