//
//  TimeRowOptions.swift
//  Splitter
//
//  Created by Michael Berk on 6/4/23.
//  Copyright © 2023 Michael Berk. All rights reserved.
//
import AppKit
extension TimeRow {
	fileprivate var showAttemptsLabelButton: ComponentOptionsButton {
		ComponentOptionsButton(checkboxWithTitle: "Show Attempts Label", clickAction: { button in
			let oldValue = self.showAttemptsLabel
			self.undoableSetting(actionName: "Set Show Attempts Label", oldValue: oldValue, newValue: !oldValue, edit: { comp, value in
				comp.showAttemptsLabel = value
				button.state = .init(bool: value)
			})
		})
	}
	
	var optionsView: NSView! {
		let d = defaultComponentOptions() as! ComponentOptionsVstack
		let showAttemptsLabelButton = self.showAttemptsLabelButton
		//Can't move this outside of class since it needs the label button to exist
		let showAttemptsButton = ComponentOptionsButton(checkboxWithTitle: "Show Attempts", clickAction: {button in
			let oldValue = self.showAttempts
			self.undoableSetting(actionName: "Set Show Attempts", oldValue: oldValue, newValue: !oldValue, edit: {comp, value in
				comp.showAttempts = value
				button.state = .init(bool: value)
				showAttemptsLabelButton.isEnabled = value
			})
		})
		showAttemptsButton.state = .init(bool: showAttempts)
		
		showAttemptsLabelButton.state = .init(bool: showAttemptsLabel)
		showAttemptsLabelButton.sizeToFit()
		showAttemptsLabelButton.isEnabled = showAttempts
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
		
		return d
	}
}
