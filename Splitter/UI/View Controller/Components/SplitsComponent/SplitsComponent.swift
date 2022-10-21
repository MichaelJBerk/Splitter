//
//  SplitsComponent.swift
//  Splitter
//
//  Created by Michael Berk on 4/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
import LiveSplitKit
class SplitsComponent: NSScrollView, NibLoadable, SplitterComponent {
	
	var run: SplitterRun!
	var delegate: SplitsComponentDelegate!
	
	//MARK: - State
	
	var advancedVC: NSViewController!
	
	var showHeader: Bool {
		get {
			return !(splitsTableView.headerView == nil)
		}
		set {
			if newValue {
				splitsTableView.headerView = NSTableHeaderView()
				splitsTableView.enclosingScrollView?.contentView.contentInsets.top = 28
//				self.contentInsets.top = 28
			} else {
				splitsTableView.headerView = nil
//				self.contentInsets.top = 0
				splitsTableView.enclosingScrollView?.contentView.contentInsets.top = 0
			}
		}
	}
	
	//We save this here instead of loading this setting from LiveSplit, since LSC doesn't have a toggle for column header
	let showHeaderKey = "showHeader"
	let widthsKey = "columnWidths"
	let hideIconColumnKey = "hideIconColumn"
	let hideTitleColumnKey = "hideTitleColumn"
	let hideVScrollKey = "hideVScroll"
	let hideHScrollKey = "hideHScroll"
	
	func saveState() throws -> ComponentState {
		var state = saveBasicState()
		state.properties[showHeaderKey] = showHeader
		let widths = splitsTableView.tableColumns.map {Float($0.width)}
		state.properties[widthsKey] = widths
		state.properties[hideIconColumnKey] = splitsTableView.tableColumns[0].isHidden
		state.properties[hideTitleColumnKey] = splitsTableView.tableColumns[1].isHidden
		state.properties[hideVScrollKey] = self.hasVerticalScroller
		state.properties[hideHScrollKey] = self.hasHorizontalScroller
		return state
	}
	
	func loadState(from state: ComponentState) throws {
		loadBasicState(from: state.properties)
		showHeader = state.getProperty(with: showHeaderKey, of: Bool.self) ?? true
		if let widths = state.getProperty(with: widthsKey, of: [Float].self)?.map({CGFloat($0)}) {
			for i in 0..<splitsTableView.tableColumns.count {
				splitsTableView.tableColumns[i].width = widths[i]
			}
		}
		if let hideIcon = state.getProperty(with: hideIconColumnKey, of: Bool.self) {
			splitsTableView.tableColumns[0].isHidden = hideIcon
		}
		if let hideTitle = state.getProperty(with: hideTitleColumnKey, of: Bool.self) {
			splitsTableView.tableColumns[1].isHidden = hideTitle
		}
		if let hideVScroll = state.getProperty(with: hideVScrollKey, of: Bool.self) {
			self.hasVerticalScroller = hideVScroll
		}
		if let hideHScroll = state.getProperty(with: hideHScrollKey, of: Bool.self) {
			self.hasVerticalScroller = hideHScroll
		}
	}
	
	//MARK: - LiveSplit Layout
	
	var componentIndex = 1
	
	/// Returns the title for the column managed by LiveSplitCore
	///
	/// This is typically used to check if a column is the Title or Icon column, which is managed by Splitter.
	/// - Parameter index: The index in LiveSplit (i.e. ignoring the icon/title columns)
	/// - Returns: Name of the given column
	func nameInLayoutForColumn(at index: Int) -> String {
//		let timer = run.timer.lsTimer
		let layout = run.layout
//		let layout =  run.layout.state(timer)
//		let splits = layout.componentAsSplits(componentIndex)
		if let le = LayoutEditor(layout) {
			le.select(componentIndex)
			let name = le.getColumnName(index)
			run.layout = le.close()
			return name
		}
		return "hey"
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
	
	///Called when a column has been resized
	///
	///Used to allow the user to undo setting the column width
	private func didResize(column: NSTableColumn, oldSize: NSNumber) {
		run.undoManager?.registerUndo(withTarget: self, handler: { c in
			c.run.undoManager?.registerUndo(withTarget: self, handler: { c2 in
				c2.didResize(column: column, oldSize: oldSize)
			})
			let resizeColIndex = c.splitsTableView.column(withIdentifier: column.identifier)
			let resizeCol = c.splitsTableView.tableColumns[resizeColIndex]
			resizeCol.width = CGFloat(truncating: oldSize)
		})
		run.undoManager?.setActionName("Set Column Width")
	}
	
	func setup() {
		///This works even if viewController hasn't been initalized yet, since `delegate` and `dataSource` are optional properties
		delegate = SplitsComponentDelegate(run: run, component: self)
		splitsTableView.delegate = delegate
		splitsTableView.dataSource = delegate
		
		let ls = run.getLayoutState()
		let lsComp = ls.componentAsSplits(componentIndex)
		let numberOfColumns = lsComp.columnsLen(0)
		for _ in 0..<numberOfColumns {
			addColumn()
		}
		NotificationCenter.default.addObserver(forName: .runEdited, object: self.run, queue: nil, using: { _ in
			self.splitsTableView.reloadData()
		})
		NotificationCenter.default.addObserver(forName: NSTableView.columnDidResizeNotification, object: splitsTableView, queue: nil, using: { notification in
			let col = notification.userInfo?["NSTableColumn"] as! NSTableColumn
			let old = notification.userInfo?["NSOldWidth"] as! NSNumber
			self.didResize(column: col, oldSize: old)
		})
		
		if #available(macOS 11.0, *) {
			splitsTableView.style = .fullWidth
		}
	}
	
	func removeColumn(fromLS: Bool = true) {
		run.undoManager?.beginUndoGrouping()
		run.undoManager?.registerUndo(withTarget: self, handler: { sc in
			sc.addColumn()
			NotificationCenter.default.post(name: .runEdited, object: sc.run)
		})
		let lastCol = splitsTableView.tableColumns.last!
		splitsTableView.removeTableColumn(lastCol)
		if fromLS {
			run.removeColumn(component: componentIndex)
			
		}
		run.undoManager?.endUndoGrouping()
		splitsTableView.reloadData()
	}
	
	func addColumn() {
		run.undoManager?.beginUndoGrouping()
		run.undoManager?.registerUndo(withTarget: self, handler: {sc in
			sc.removeColumn(fromLS: false)
			NotificationCenter.default.post(name: .runEdited, object: sc.run)
		})
		let id = UUID()
		let itemID = NSUserInterfaceItemIdentifier(rawValue: "LS \(id.uuidString)")
		let column = NSTableColumn(identifier: itemID)
		splitsTableView.addTableColumn(column)
		splitsTableView.setHeaderColor(textColor: run.textColor, bgColor: run.tableColor)
		splitsTableView.setCornerColor(cornerColor: run.tableColor)
		run.undoManager?.endUndoGrouping()
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
