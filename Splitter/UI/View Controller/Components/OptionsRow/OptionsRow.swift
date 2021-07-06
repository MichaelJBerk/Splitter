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
	
	var state: SplitterComponentState!
	
	static func instantiateView(with run: SplitterRun, _ viewController: ViewController) -> OptionsRow {
		let row: OptionsRow = OptionsRow.instantiateView()
		row.viewController = viewController
		row.run = run
		row.initialization()
		return row
	}
	
	var customSpacing: CGFloat? = nil
	
	private func initialization() {
		plusButton.run = run
		timeLabel.run = run
		columnOptionsButton.run = run
		detachesHiddenViews = false
		NotificationCenter.default.addObserver(forName: .timerStateChanged, object: self.run.timer, queue: nil, using: { notification in
			guard let timerState = notification.userInfo?["timerState"] as? TimerState else {return}
			if timerState == .stopped {
				self.addDeleteEnabled(true)
			} else {
				self.addDeleteEnabled(false)
			}
		})
	}
	
	var viewController: ViewController!
	
	@IBOutlet var contentView: NSView!
	
	@IBOutlet var plusButton: ThemedButton!
	@IBOutlet var columnOptionsButton: ThemedButton!
	@IBOutlet var tableButtonsStack: NSStackView!
	@IBOutlet weak var timeLabel: ThemedTextField!
	
	var isSelected: Bool = false {
		didSet {
			didSetSelected()
		}
	}
	@IBAction func splitsEditorButtonClick(_ sender: Any) {
		viewController!.displaySegmentEditor()
	}
	
	@IBAction func columnOptionsButtonClick(_ sender: Any) {
		viewController!.showLayoutEditor()
	}
	
	//TODO: see if I should just have a var "addDeleteEnabled" and set both equal to it instead of having a function for it
	///Sets whether the + and - buttons beneath the Table View are enabled or not
	func addDeleteEnabled(_ enabled: Bool) {
		plusButton.isEnabled = enabled
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
		let showLabelButton = ComponentOptionsButton(checkboxWithTitle: "Show Label", clickAction: {_ in 
			self.showLabel.toggle()			
		})
		
		showLabelButton.state = .init(bool: showLabel)
		defaultOptions.addArrangedSubview(showLabelButton)
		return defaultOptions
		
	}
	@objc func toggleLabel(sender: Any?) {
		showLabel.toggle()
	}
}
