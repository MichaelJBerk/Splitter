//
//  SplitsComponent.swift
//  Splitter
//
//  Created by Michael Berk on 4/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
class SplitsComponent: NSScrollView, NibLoadable, SplitterComponent, LiveSplitSplitterComponent {
	var run: SplitterRun!
	var state: SplitterComponentState!
	
	struct SplitterScrollViewState: SplitterComponentState {
		var componentType: SplitterComponentType = .splits
		
		var isHidden: Bool
		
		var afterSpacing: Float
	}
	
	var showHeader: Bool {
		get {
			return !(splitsTableView.headerView?.isHidden ?? true)
		}
		set {
			splitsTableView.headerView?.isHidden = !newValue
		}
	}
	
	let showHeaderKey = "showHeader"
	func saveState() throws -> ComponentState {
		var state = saveBasicState()
		state.properties[showHeaderKey] = showHeader
		return state
	}
	func loadState(from state: ComponentState) throws {
		loadBasicState(from: state.properties)
		showHeader = (state.properties[showHeaderKey] as? JSONAny)?.value as? Bool ?? true
	}
	var optionsView: NSView! {
		let d = defaultComponentOptions() as! ComponentOptionsVstack
		let showHeaderButton = ComponentOptionsButton(checkboxWithTitle: "Show Header") {
			self.showHeader.toggle()
		}
		showHeaderButton.state = .init(bool: showHeader)
		d.addArrangedSubview(showHeaderButton)
		return d
	}
	
	var customSpacing: CGFloat? = nil
	
	var viewController: ViewController!
	
	var displayTitle: String = "Splits"
	
	var splitsTableView: SplitterTableView {
		return documentView as! SplitterTableView
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	func setup() {
		///This works even if viewController hasn't been initalized yet, since `delegate` and `dataSource` are optional properties
		splitsTableView.delegate = viewController
		splitsTableView.dataSource = viewController
		if #available(macOS 11.0, *) {
			splitsTableView.style = .fullWidth
		}
	}
	
	var displayDescription: String = ""
	
	
	var leadingConstraint: NSLayoutConstraint {
		self.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor)
	}
	var trailingConstraint: NSLayoutConstraint {
		self.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
	}
	
	var isSelected: Bool = false {
		didSet {
			didSetSelected()
		}
	}
	var defaultAfterSpacing: CGFloat {
		return 7
	}
	
	///Background color when scrolling past the items in the table view
	///
	///This is set after setting the scroll view's corner color. We can't just use the `backgroundColor` property, because then the correct color won't display
	var tableBGColor: NSColor?
	
	override func draw(_ dirtyRect: NSRect) {}
	
	override func hide(_ sender: Any?) {
		super.hide(sender)
		//TODO: After showing, make window bigger
		
	}
}

class SplitterScroller: NSScroller {
	
	var bgColor: NSColor?
	
	override func drawKnobSlot(in slotRect: NSRect, highlight flag: Bool) {
	}
}
