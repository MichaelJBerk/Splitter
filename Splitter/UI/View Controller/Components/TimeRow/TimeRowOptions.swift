//
//  TimeRowOptions.swift
//  Splitter
//
//  Created by Michael Berk on 6/4/23.
//  Copyright © 2023 Michael Berk. All rights reserved.
//
import AppKit
import FontPopUp

class TimeRowOptionsController: NSObject {
	
	init(timeRow: TimeRow) {
		self.timeRow = timeRow
		super.init()
		NotificationCenter.default.addObserver(forName: .fontChanged, object: self.timeRow.run, queue: nil, using: { _ in
			self.fontStack.fontPopUp.selectedFont = self.timeRow.run.timerFont
		})
	}
	
	func fontChanged(to newFont: NSFont?) {
		self.timeRow.run.timerFont = newFont
	}
	
	var timeRow: TimeRow!
	var fontStack: ComponentOptionsFontStack!
	
	var showAttemptsLabelButton: ComponentOptionsButton {
		ComponentOptionsButton(checkboxWithTitle: "Show Attempts Label", clickAction: { button in
			let oldValue = self.timeRow.showAttemptsLabel
			self.timeRow.undoableSetting(actionName: "Set Show Attempts Label", oldValue: oldValue, newValue: !oldValue, edit: { comp, value in
				comp.showAttemptsLabel = value
				button.state = .init(bool: value)
			})
		})
	}

	var optionsView: NSView! {
		let d = timeRow.defaultComponentOptions() as! ComponentOptionsVstack
		let showAttemptsLabelButton = self.showAttemptsLabelButton
		//Can't move this outside of class since it needs the label button to exist
		let showAttemptsButton = ComponentOptionsButton(checkboxWithTitle: "Show Attempts", clickAction: {button in
			let oldValue = self.timeRow.showAttempts
			self.timeRow.undoableSetting(actionName: "Set Show Attempts", oldValue: oldValue, newValue: !oldValue, edit: {comp, value in
				comp.showAttempts = value
				button.state = .init(bool: value)
				showAttemptsLabelButton.isEnabled = value
			})
		})
		showAttemptsButton.state = .init(bool: timeRow.showAttempts)
		
		showAttemptsLabelButton.state = .init(bool: timeRow.showAttemptsLabel)
		showAttemptsLabelButton.sizeToFit()
		showAttemptsLabelButton.isEnabled = timeRow.showAttempts
		let bv = NSView(frame: NSRect(x: 0, y: 0, width: 20, height: showAttemptsLabelButton.frame.height))
		NSLayoutConstraint.activate([
			bv.widthAnchor.constraint(equalToConstant: 20)
		])
		bv.setContentHuggingPriority(.required, for: .horizontal)
		showAttemptsLabelButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
		let attemptsLabelButtonStack = NSStackView(views: [bv, showAttemptsLabelButton])
		attemptsLabelButtonStack.distribution = .equalSpacing
		attemptsLabelButtonStack.spacing = 0
		attemptsLabelButtonStack.alignment = .leading
		attemptsLabelButtonStack.orientation = .horizontal
		
		d.addArrangedSubview(showAttemptsButton)
		d.addArrangedSubview(attemptsLabelButtonStack)
		
		d.addSeparator()
		
		fontStack = ComponentOptionsFontStack(onFontChange: fontChanged(to:))
		d.addArrangedSubview(fontStack)
		return d
	}
	
}
extension TimeRow {
	var optionsView: NSView! {
		optionsController.optionsView
	}
}


