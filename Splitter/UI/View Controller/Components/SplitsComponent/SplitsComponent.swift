//
//  SplitsComponent.swift
//  Splitter
//
//  Created by Michael Berk on 4/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
class SplitsComponent: NSScrollView, NibLoadable, SplitterComponent {
	
	var run: SplitterRun!
	var delegate: SplitsComponentDelegate!
	
	//MARK: - State
	var state: SplitterComponentState!
	
	var advancedVC: NSViewController!
	
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
	
	var showAdvancedSettings: Bool = false
	
	let showHeaderKey = "showHeader"
	let advancedSettingsKey = "showAdvancedSettings"
	func saveState() throws -> ComponentState {
		var state = saveBasicState()
		state.properties[showHeaderKey] = showHeader
		state.properties[advancedSettingsKey] = showAdvancedSettings
		return state
	}
	func loadState(from state: ComponentState) throws {
		loadBasicState(from: state.properties)
		showHeader = (state.properties[showHeaderKey] as? JSONAny)?.value as? Bool ?? true
		showAdvancedSettings = (state.properties[advancedSettingsKey] as? JSONAny)?.value as? Bool ?? true
	}
	
	//MARK: - LiveSplit Layout
	
	var componentIndex = 1
	
	///Returns the title for the column managed by LiveSplitCore
	///
	///This is typically used to check if a column is the Title or Icon column, which is managed by Splitter.
	func nameInLayoutForColumn(at index: Int) -> String {
		let timer = run.timer.lsTimer
		let layout =  run.layout.state(timer)
		let splits = layout.componentAsSplits(componentIndex)
		return splits.columnName(index)
	}
	
	//MARK: -
	
	var customSpacing: CGFloat? = nil
	
	var viewController: ViewController!
	var useViewController = true
	
	var splitsTableView: SplitterTableView {
		return documentView as! SplitterTableView
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	func setup() {
		///This works even if viewController hasn't been initalized yet, since `delegate` and `dataSource` are optional properties
		delegate = SplitsComponentDelegate(run: run, component: self)
		splitsTableView.delegate = delegate
		splitsTableView.dataSource = delegate
		
		//Get rows past the header to be hidden
		NotificationCenter.default.addObserver(forName: NSScrollView.didLiveScrollNotification, object: self, queue: nil, using: { notification in
			let scrollView = notification.object as! SplitsComponent

			let range = scrollView.splitsTableView.rows(in: scrollView.splitsTableView.visibleRect)
			for i  in range.lowerBound..<range.upperBound  {
				let rowView = scrollView.splitsTableView.rowView(atRow: i, makeIfNecessary: false) as! SplitterRowView
				
				let header = scrollView.splitsTableView.headerView
				let p = header!.convert(NSPoint(x: 0, y: header!.frame.minY), to: rowView)

				if p.y >= 0 {
					rowView.isHidden = true
				} else {
					rowView.isHidden = false
				}
			}
		})
		if #available(macOS 11.0, *) {
			splitsTableView.style = .fullWidth
		}
	}
	
	var leadingConstraint: NSLayoutConstraint {
		if useViewController {
			return self.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor)
		} else {
			return NSLayoutConstraint()
		}
	}
	var trailingConstraint: NSLayoutConstraint {
		if useViewController {
			return self.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
		} else {
			return NSLayoutConstraint()
		}
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
		if let bgColor = self.bgColor {
			let alpha = bgColor.alphaComponent * 0.6
			var effect = NSColor.SystemEffect.none
			if flag {
				effect = .pressed
			}
			bgColor.withAlphaComponent(alpha).withSystemEffect(effect).set()
			var fillStyle: NSCompositingOperation
			
			if bgColor.isLight() ?? false {
				fillStyle = .hardLight
			} else {
				fillStyle = .softLight
			}
			if alpha == 0 {
				fillStyle = .clear
			}
			slotRect.fill(using: fillStyle)
		}
	}
}
