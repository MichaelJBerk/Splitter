//
//  OptionsRow.swift
//  Splitter
//
//  Created by Michael Berk on 4/18/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class OptionsRow: NSStackView, NibLoadable, SplitterComponent {
	var run: SplitterRun!
	
	static func instantiateView(with run: SplitterRun, _ viewController: ViewController) -> OptionsRow {
		let row: OptionsRow = OptionsRow.instantiateView()
		row.viewController = viewController
		row.run = run
		row.initialization()
		return row
	}
	
	var customSpacing: CGFloat? = nil
	
	private func initialization() {
		editSplitsButton.run = run
		timeLabel.run = run
		editLayoutButton.run = run
		detachesHiddenViews = false
		NotificationCenter.default.addObserver(forName: .timerStateChanged, object: self.run.timer, queue: nil, using: { notification in
			guard let timerState = notification.userInfo?["timerState"] as? TimerState else {return}
			if timerState == .stopped {
				self.editingEnabled(true)
			} else {
				self.editingEnabled(false)
			}
		})
	}
	
	var viewController: ViewController!
	
	@IBOutlet var contentView: NSView!
	
	@IBOutlet var editSplitsButton: ThemedButton!
	@IBOutlet var editLayoutButton: ThemedButton!
	@IBOutlet var tableButtonsStack: NSStackView!
	@IBOutlet weak var timeLabel: ThemedTextField!
	
	var isSelected: Bool = false {
		didSet {
			didSetSelected()
		}
	}
	@IBAction func splitsEditorButtonClick(_ sender: Any) {
		viewController!.displaySplitsEditor()
	}
	
	@IBAction func columnOptionsButtonClick(_ sender: Any) {
		viewController!.showLayoutEditor()
	}
	
	///Sets whether the + and - buttons beneath the Table View are enabled or not
	func editingEnabled(_ enabled: Bool) {
		editSplitsButton.isEnabled = enabled
		editLayoutButton.isEnabled = enabled
	}
	
	let showLabelKey = "showLabel"
	var showLabel: Bool {
		get {
			return !timeLabel.isHidden
		}
		set {
			timeLabel.isHidden = !newValue
		}
	}
	
	func saveState() throws -> ComponentState {
		var state = saveBasicState()
		state.properties[showLabelKey] = showLabel
		return state
	}
	func loadState(from state: ComponentState) throws {
		loadBasicState(from: state.properties)
		showLabel = (state.properties[showLabelKey] as? JSONAny)?.value as? Bool ?? true
	}
	
	var optionsView: NSView! {
		let defaultOptions = defaultComponentOptions() as! ComponentOptionsVstack
		let showLabelButton = ComponentOptionsButton(checkboxWithTitle: "Show Label", clickAction: {button in
			let oldValue = self.showLabel
			self.undoableSetting(actionName: "Show Label", oldValue: oldValue, newValue: !oldValue, edit: { comp, value in
				comp.showLabel = value
				button.state = .init(bool: value)
			})
		})
		
		showLabelButton.state = .init(bool: showLabel)
		defaultOptions.addArrangedSubview(showLabelButton)
		return defaultOptions
		
	}
	
	private func toggleShowLabel(_ val: Bool, button: NSButton) {
		let showLabel = self.showLabel
		run.undoManager?.registerUndo(withTarget: self, handler: { comp in
			self.toggleShowLabel(showLabel, button: button)
		})
		button.state = .init(bool: val)
		undoManager?.setActionName("Show Label")
		self.showLabel = val
	}
	
}
