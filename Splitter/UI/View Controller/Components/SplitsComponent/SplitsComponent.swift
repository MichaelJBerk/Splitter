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
	
	class SplitsOptionsView: ComponentOptionsVstack {
		typealias OptionsTab =  (view: NSView, title: String)
		var viewIndex: Int = 0 {
			didSet {
				for s in 1..<views.count {
					if s - 1 != viewIndex {
						views[s].isHidden = true
					} else {
						views[s].isHidden = false
					}
				}
			}
		}
		
		var tabs: [OptionsTab] = []
		
		var segmentedControl: NSSegmentedControl!
		
		var mainView: NSView! {
			tabs[viewIndex].view
		}
		
		@objc func tabChanged(sender: Any) {
			let sender = sender as! NSSegmentedControl
			viewIndex = sender.selectedSegment
		}
		
		static func makeView(tabs: [OptionsTab]) -> SplitsOptionsView {
			let seg = NSSegmentedControl(labels: tabs.map({$0.title}), trackingMode: .selectOne, target: nil, action: nil)
			seg.selectedSegment = 0
			let newView = SplitsOptionsView(views: [seg])
			newView.tabs = tabs
			newView.segmentedControl = seg
			newView.alignment = .centerX
			seg.target = newView
			seg.action = #selector(newView.tabChanged(sender:))
			for view in tabs.map({$0.view}) {
				newView.addArrangedSubview(view)
			}
			newView.viewIndex = 0
			return newView
		}
	
	}
	
	var coView: NSView {
		var views = [NSView]()
		for c in splitsTableView.tableColumns {
			let cName = colIds.first(where: {$1 == c.identifier})?.key ?? "nil"
			let checkButton = ComponentOptionsButton(checkboxWithTitle: cName, clickAction: {_ in
				let colID = self.splitsTableView.column(withIdentifier: c.identifier)
				let col = self.splitsTableView.tableColumns[colID]
				col.isHidden.toggle()
			})
			checkButton.state = .init(bool: !c.isHidden)
			views.append(checkButton)
		}
		let stack = ComponentOptionsVstack(views: views)
		stack.alignment = .leading
		return stack
	}
	
	var optionsView: NSView! {
		let d = defaultComponentOptions() as! ComponentOptionsVstack
		let showHeaderButton = ComponentOptionsButton(checkboxWithTitle: "Show Header") {_ in 
			self.showHeader.toggle()
		}
		showHeaderButton.state = .init(bool: showHeader)
		d.addArrangedSubview(showHeaderButton)

		let co = coView
		let superStack = SplitsOptionsView.makeView(tabs: [(d, "Options"), (co, "Columns")])
		NSLayoutConstraint.activate([
			superStack.widthAnchor.constraint(equalTo: d.widthAnchor),
			co.widthAnchor.constraint(equalTo: superStack.widthAnchor),
		])
		return superStack
	}
	
	var customSpacing: CGFloat? = nil
	
	var viewController: ViewController!
	
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
