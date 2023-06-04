//
//  TimeRow.swift
//  
//
//  Created by Michael Berk on 3/22/21.
//

import Cocoa

class TimeRow: NSStackView, NibLoadable, SplitterComponent, NSTextFieldDelegate, Fontable {
	
	var fontable: Bool = true
	
	///Font used for displaying the time
	var timeFont: NSFont? {
		get {timeLabel.font}
		set {timeLabel.font = newValue}
	}
	var run: SplitterRun!
	var customSpacing: CGFloat? = nil
	var refreshUITimer = Timer()
	
	static func instantiateView(run: SplitterRun, viewController: ViewController) -> TimeRow {
		let row: TimeRow = TimeRow.instantiateView()
		row.viewController = viewController
		row.run = run
		row.setup()
		return row
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	func setup() {
		attemptsLabel.run = self.run
		timeLabel.run = run
		attemptsField.run = run
		attemptsField.formatter = OnlyIntegerValueFormatter()
		detachesHiddenViews = false
		attemptsStackView.detachesHiddenViews = false
		attemptsField.delegate = self
		run.updateFunctions.append(updateUI)
		setFontObserver()
	}
	func updateUI() {
		self.viewController.updateTimer()
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
		let showAttemptsLabelButton = ComponentOptionsButton(checkboxWithTitle: "Show Attempts Label", clickAction: { button in
			let oldValue = self.showAttemptsLabel
			self.undoableSetting(actionName: "Set Show Attempts Label", oldValue: oldValue, newValue: !oldValue, edit: { comp, value in
				comp.showAttemptsLabel = value
				button.state = .init(bool: value)
			})
			
		})
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
	
	@IBOutlet var contentView: NSView!
	@IBOutlet var timeLabel: ThemedTextField!
	@IBOutlet var attemptsField: ThemedTextField!
	var viewController: ViewController!
	var isSelected = false {
		didSet {
			self.didSetSelected()
		}
	}
	func controlTextDidEndEditing(_ obj: Notification) {
		self.run.attempts = Int(attemptsField.stringValue) ?? 0
	}
	
	func setFont() {
		if let csize = self.timeFont?.pointSize {
			if let font = self.run.timerFont {
				let nf = NSFont(name: font.fontName, size: csize)
				self.timeFont = nf
			} else {
				self.timeFont = NSFont.systemFont(ofSize: csize)
			}
		}
	}
}
