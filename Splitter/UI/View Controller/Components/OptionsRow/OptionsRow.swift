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
//	internal override func awakeAfter(using coder: NSCoder) -> Any? {
//		return instantiateView() // You need to add this line to load view
//	}
//
//	internal override func awakeFromNib() {
//		super.awakeFromNib()
//		initialization()
//	}
	private func initialization() {
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
	
	var displayDescription: String = "OR Desc"
	
	@IBOutlet var contentView: NSView!
	
	@IBOutlet var plusButton: ThemedButton!
	@IBOutlet var minusButton: ThemedButton!
	@IBOutlet var columnOptionsButton: ThemedButton!
	@IBOutlet var tableButtonsStack: NSStackView!
	@IBOutlet weak var timeLabel: ThemedTextField!
	
	var isSelected: Bool = false {
		didSet {
			didSetSelected()
		}
	}
	@IBAction func plusButtonClick(_ sender: Any) {
		viewController!.addButtonClick(self)
	}
	@IBAction func minusButtonClick(_ sender: Any) {
		viewController!.removeButtonClick(sender)
	}
	@IBAction func columnOptionsButtonClick(_ sender: Any) {
		viewController!.displayColumnOptionsAsWindow(sender: sender)
	}
	
	//TODO: see if I should just have a var "addDeleteEnabled" and set both equal to it instead of having a function for it
	///Sets whethert the + and - buttons beneath the Table View are enabled or not
	func addDeleteEnabled(_ enabled: Bool) {
		plusButton.isEnabled = enabled
		minusButton.isEnabled = enabled
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
		let showLabelButton = ComponentOptionsButton(checkboxWithTitle: "Show Label", clickAction: {
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

extension NSView {
	//The trick with this is to use the root view of the XIB as the custom class - NOT file's owner
	public static func instantiateView<View: NSView>(for type: View.Type = View.self) -> View {
		let bundle = Bundle(for: type)
		let nibName = String(describing: type)

		guard bundle.path(forResource: nibName, ofType: "nib") != nil else {
			return View(frame: .zero)
		}

		var topLevelArray: NSArray?
		bundle.loadNibNamed(NSNib.Name(nibName), owner: nil, topLevelObjects: &topLevelArray)
		guard let results = topLevelArray as? [Any],
			let foundedView = results.last(where: {$0 is Self}),
			let view = foundedView as? View else {
				fatalError("NIB with name \"\(nibName)\" does not exist.")
		}
		return view
	}
	public func instantiateView() -> NSView {
		guard subviews.isEmpty else {
			return self
		}

		let loadedView = NSView.instantiateView(for: type(of: self))
		loadedView.frame = frame
		loadedView.autoresizingMask = autoresizingMask
		loadedView.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints

		loadedView.addConstraints(constraints.compactMap { ctr -> NSLayoutConstraint? in
			guard let srcFirstItem = ctr.firstItem as? NSView else {
				return nil
			}

			let dstFirstItem = srcFirstItem == self ? loadedView : srcFirstItem
			let srcSecondItem = ctr.secondItem as? NSView
			let dstSecondItem = srcSecondItem == self ? loadedView : srcSecondItem

			return NSLayoutConstraint(item: dstFirstItem,
									  attribute: ctr.firstAttribute,
									  relatedBy: ctr.relation,
									  toItem: dstSecondItem,
									  attribute: ctr.secondAttribute,
									  multiplier: ctr.multiplier,
									  constant: ctr.constant)
		})

		return loadedView
	}
}

protocol NibLoadable {
	static var nibName: String? { get }
	static func createFromNib(in bundle: Bundle) -> Self?
}

extension NibLoadable where Self: NSView {

	static var nibName: String? {
		return String(describing: self)
	}

	static func createFromNib(in bundle: Bundle = Bundle.main) -> Self? {
		guard let nibName = nibName else { return nil }
		var topLevelArray: NSArray? = nil
		bundle.loadNibNamed(NSNib.Name(nibName), owner: self, topLevelObjects: &topLevelArray)
		guard let results = topLevelArray else { return nil }
		let views = Array<Any>(results).filter { $0 is Self }
		return views.last as? Self
	}
}
