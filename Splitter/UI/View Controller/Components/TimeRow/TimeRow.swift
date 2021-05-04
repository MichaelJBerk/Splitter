//
//  TimeRow.swift
//  
//
//  Created by Michael Berk on 3/22/21.
//

import Cocoa

class TimeRow: NSStackView, NibLoadable, SplitterComponent, NSTextFieldDelegate {
	var run: SplitterRun!
	var customSpacing: CGFloat? = nil
	var refreshUITimer = Timer()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	func setup() {
		attemptsField.formatter = OnlyIntegerValueFormatter()
		detachesHiddenViews = false
		attemptsStackView.detachesHiddenViews = false
		attemptsField.delegate = self
		NotificationCenter.default.addObserver(forName: .startTimer, object: nil, queue: nil, using: { _ in 
			self.refreshUITimer = Cocoa.Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { timer in
				self.viewController.updateTimer()
			})
		})
		NotificationCenter.default.addObserver(forName: .stopTimer, object: nil, queue: nil, using: { _ in
			self.refreshUITimer.invalidate()
		})
	}
	
	let showAttemptsKey = "showAttempts"
	let showAttemptsLabelKey = "showAttemptsLabel"
	
	@IBOutlet weak var attemptsStackView: NSStackView!
	@IBOutlet weak var attemptsLabel: ThemedTextField!
	var showAttempts: Bool {
		get {
			!attemptsStackView.isHidden
		}
		set {
			attemptsStackView.isHidden = !newValue
		}
	}
	var showAttemptsLabel: Bool {
		get {
			!attemptsLabel.isHidden
		}
		set {
			attemptsLabel.isHidden = !newValue
		}
	}
	var roundTo: SplitRounding {
		get {
			viewController.roundTo
		}
		set {
			viewController.roundTo = newValue
		}
	}
	
	func saveState() throws -> ComponentState {
		var state = saveBasicState()
		state.properties[showAttemptsKey] = showAttempts
		state.properties[showAttemptsLabelKey] = showAttemptsLabel
		return state
	}
	func loadState(from state: ComponentState) throws {
		loadBasicState(from: state.properties)
		showAttempts = (state.properties[showAttemptsKey] as? JSONAny)?.value as? Bool ?? true
		showAttemptsLabel = (state.properties[showAttemptsLabelKey] as? JSONAny)?.value as? Bool ?? true
	}
	
	var optionsView: NSView! {
		let d = defaultComponentOptions() as! ComponentOptionsVstack
		let showAttemptsLabelButton = ComponentOptionsButton(checkboxWithTitle: "Show Attempts Label", clickAction: { self.showAttemptsLabel.toggle()})
		let showAttemptsButton = ComponentOptionsButton(checkboxWithTitle: "Show Attempts", clickAction: {
			self.showAttempts.toggle()
			showAttemptsLabelButton.isEnabled = self.showAttempts
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
	
	@IBOutlet var contentView: NSView!
	@IBOutlet var timeLabel: NSTextField!
	@IBOutlet var attemptsField: NSTextField!
	var viewController: ViewController!
	var isSelected = false {
		didSet {
			self.didSetSelected()
		}
	}
	func controlTextDidEndEditing(_ obj: Notification) {
		self.run.attempts = Int(attemptsField.stringValue) ?? 0
	}
	
//	@IBAction func attemptEdited(_ sender: Any) {
//
//	}
}
