//
//  TimeRowOptions.swift
//  Splitter
//
//  Created by Michael Berk on 6/4/23.
//  Copyright © 2023 Michael Berk. All rights reserved.
//
import AppKit

class TimeRowOptionsController: NSObject {
	
	init(timeRow: TimeRow) {
		self.timeRow = timeRow
		super.init()
		NotificationCenter.default.addObserver(forName: .fontChanged, object: self.timeRow.run, queue: nil, using: { _ in
			self.fontChanged(to: self.timeRow.run.timerFont)
		})
	}
	
	func fontChanged(to: NSFont?) {
		updateFontButtonTitle()
		updateFontResetState()
	}
	
	func updateFontButtonTitle() {
		var buttonTitle: String
		if let timerFont = self.timeRow.run.timerFont {
			buttonTitle = timerFont.displayName ?? "????"
		} else {
			buttonTitle = "Default"
		}
		fontButton.title = buttonTitle
		fontButton.font = self.timeRow.run.timerFont
	}
	
	func updateFontResetState() {
		fontResetButton?.isEnabled = !(timeRow.run.timerFont.isNil)
	}
	
	var timeRow: TimeRow!
	var fontButton: ComponentOptionsButton!
	var fontResetButton: ComponentOptionsButton!
	
	
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
		d.onFontChanged = self.changeFont(_:)
		d.fontPanelModes = [.face, .collection]
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
		
		let fontLabel = NSTextField(labelWithString: "Timer Font")
		//Ensure that the font label is what gets stretched, and not one of the other buttons
		fontLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
		fontButton = ComponentOptionsButton(title: "FONT", clickAction: { _ in
//			self.timeRow.run.timerFont = NSFont(name: "OMORI_GAME", size: 20)
			if let font = self.timeRow.run.timerFont {
				NSFontPanel.shared.setPanelFont(font, isMultiple: false)
			}
			NSFontManager.shared.orderFrontFontPanel(self)
//			NSFontPanel.shared.makeKeyAndOrderFront(self)
		})
		fontResetButton = ComponentOptionsButton(title: "Reset", clickAction: { _ in
			self.timeRow.run.timerFont = nil
		})
		let fontStack = NSStackView(views: [fontLabel, fontButton, fontResetButton])
		fontStack.orientation = .horizontal
		d.addArrangedSubview(fontStack)
		fontStack.distribution = .fill
		NSLayoutConstraint.activate([
			fontStack.leadingAnchor.constraint(equalTo: d.leadingAnchor),
			fontStack.trailingAnchor.constraint(equalTo: d.trailingAnchor),
		])
		fontChanged(to: self.timeRow.run.timerFont)
		return d
	}
	
	func changeFont(_ sender: NSFontManager?) {
		let newFont = sender?.convert(self.timeRow.run.timerFont ?? .systemFont(ofSize: NSFont.systemFontSize))
		self.timeRow.run.timerFont = newFont
	}
	
}
extension TimeRow {
	var optionsView: NSView! {
		optionsController.optionsView
	}
}


