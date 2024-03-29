//
//  TimeRow.swift
//  
//
//  Created by Michael Berk on 3/22/21.
//

import Cocoa


//This component itself conforms to Fontable (rather than just the controls within it) so that it can have its own `setFont` implementation
class TimeRow: NSStackView, NibLoadable, SplitterComponent, NSTextFieldDelegate, Fontable {
	
	var fontable: Bool = true
	var optionsController: TimeRowOptionsController!
	
	///Stubbed property from protocol
	var defaultFontSize: CGFloat?
	
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
		row.optionsController = TimeRowOptionsController(timeRow: row)
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
		if defaultFontSize == nil {
			let size = self.timeFont!.pointSize
			defaultFontSize = size
		}
		self.timeFont = run.fontManager.getTimerFont(fixedFontSize: false, defaultSize: defaultFontSize!)
	}
}
