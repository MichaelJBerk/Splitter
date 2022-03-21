//
//  SplitsComponentAdvancedOptions.swift
//  Splitter
//
//  Created by Michael Berk on 2/3/22.
//  Copyright © 2022 Michael Berk. All rights reserved.
//

import Cocoa
import LiveSplitKit

class SplitsComponentAdvancedOptions: NSViewController {
	
	convenience init(splitsComp: SplitsComponent) {
		self.init()
		self.splitsComponent = splitsComp
	}
	
	var outlineView: NSOutlineView!
	var splitsComponent: SplitsComponent!
	
	var splitsTableView: NSTableView {
		splitsComponent.splitsTableView
	}
	
	var run: SplitterRun {
		splitsComponent.run
	}
	
	override func loadView() {
		self.view = .init(frame: .init(x: 0, y: 0, width: 400, height: 250))
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		outlineView = NSOutlineView()
		let scrollView = NSScrollView(frame: view.frame)
		scrollView.documentView = outlineView
		self.view = scrollView
		
		outlineView.delegate = self
		outlineView.dataSource = self
		outlineView.backgroundColor = .clear
		outlineView.enclosingScrollView?.drawsBackground = false
		outlineView.addTableColumn(.init())
		outlineView.headerView = nil
		outlineView.usesAutomaticRowHeights = true
		outlineView.reloadData()
		outlineView.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
		outlineView.allowsColumnResizing = false
		outlineView.setDraggingSourceOperationMask(.move, forLocal: true)
		outlineView.registerForDraggedTypes([.string])
		outlineView.indentationPerLevel = 5
		outlineView.intercellSpacing = .init(width: 0, height: 5)
		
    }
    
}

class ColObject: NSObject {
	
	init(colID: NSUserInterfaceItemIdentifier, isSubitem: Bool = false, hasSubitem: Bool = false) {
		self.colID = colID
		self.isSubitem = isSubitem
		self.hasSubitem = hasSubitem
	}
	
	var colID: NSUserInterfaceItemIdentifier
	var isSubitem: Bool
	var hasSubitem: Bool = true
	
	override func isEqual(_ object: Any?) -> Bool {
		guard let object = object as? ColObject else {return false}
		
		return object.colID == self.colID && object.isSubitem == self.isSubitem
	}
	
	
}

extension SplitsComponentAdvancedOptions: NSOutlineViewDelegate, NSOutlineViewDataSource {
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return splitsTableView.numberOfColumns
		}
		if let item = item as? ColObject, !item.isSubitem {
			return 1
		}
		return 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			return ColObject(colID: splitsTableView.tableColumns[index].identifier)
		}
		if let item = item as? ColObject, !item.isSubitem {
			return ColObject(colID: item.colID, isSubitem: true)
		}
		return 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let item = item as? ColObject, !item.isSubitem {
			return true
		}
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		if let item = item as? ColObject, !item.isSubitem {
			return true
		}
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		
		guard let item = item as? ColObject else {return nil}
		
		let cell = NSTableCellView()
		
		let ci = splitsTableView.column(withIdentifier: item.colID)
		
		var title = splitsComponent.nameInLayoutForColumn(at: ci)
		
		if title == STVColumnID.iconColumnTitle {
			title = "Icon"
			if item.isSubitem {
				let check = ComponentOptionsButton(checkboxWithTitle: "Hidden", clickAction: { button in
					self.splitsTableView.tableColumns[ci].isHidden = button.state.toBool()
				})
				check.state = .init(bool: splitsTableView.tableColumns[ci].isHidden)
				cell.addSubview(check)
				cell.heightAnchor.constraint(equalTo: check.heightAnchor).isActive = true
				return cell
			}
		}
		if title == STVColumnID.titleColumnTitle {
			title = "Title"
			if item.isSubitem {
				let check = ComponentOptionsButton(checkboxWithTitle: "Hidden", clickAction: { button in
					self.splitsTableView.tableColumns[ci].isHidden = button.state.toBool()
				})
				check.state = .init(bool: splitsTableView.tableColumns[ci].isHidden)
				cell.addSubview(check)
				cell.heightAnchor.constraint(equalTo: check.heightAnchor).isActive = true
				return cell
			}
		}
		
		if item.isSubitem {
			let stack = advancedOptions(for: ci)
			cell.addSubview(stack)
			cell.heightAnchor.constraint(equalTo: stack.heightAnchor).isActive = true
			return cell
		}
		
		let tf = NSTextField(labelWithString: title)
		cell.addSubview(tf)
		cell.textField = tf
		tf.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			cell.heightAnchor.constraint(equalTo: tf.heightAnchor, constant: 8),
			tf.widthAnchor.constraint(equalTo: cell.widthAnchor),
			tf.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
			tf.centerXAnchor.constraint(equalTo: cell.centerXAnchor)
		])
		
		return cell
	}
	
	func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		if let item = item as? ColObject, !item.isSubitem {
			return item.colID.rawValue as NSString
		}
		return nil
	}
	
	func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
		guard let item = item as? ColObject, let ds = info.draggingSource as? NSOutlineView, ds == outlineView else {return [] } 
		let di = splitsTableView.tableColumns.firstIndex(where: {$0.identifier.rawValue == item.colID.rawValue
		})!
		outlineView.setDropItem(nil, dropChildIndex: di)
		return .generic
	}
	
	func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
		guard let items = info.draggingPasteboard.pasteboardItems else {return false}
		let s = items.first?.string(forType: .string)!
		let sourceIndex = splitsTableView.tableColumns.firstIndex(where: {$0.identifier.rawValue == s})!
		splitsTableView.moveColumn(sourceIndex, toColumn: index)
		outlineView.reloadData()
		return true
	}
}

extension SplitsComponentAdvancedOptions {
	
	//MARK: Advanced Column Options
	func advancedOptions(for index: Int) -> NSView {
		
		let optionsStack = NSStackView(views: [])
		optionsStack.orientation = .vertical
		
		let startPop = startWithPopup(index: index)
		let startPopLabel = NSTextField(labelWithString: "Start With")
		let startStack = NSStackView(views: [startPopLabel, startPop])
		startStack.orientation = .horizontal
		
		optionsStack.addArrangedSubview(startStack)
		
		let updatePop = updateWithPopup(index: index)
		let updateWithLabel = NSTextField(labelWithString: "Update With")
		let uwStack = NSStackView(views: [updateWithLabel, updatePop])
		uwStack.orientation = .horizontal
		optionsStack.addArrangedSubview(uwStack)
		
		let updateTriggerPop = updateTriggerPop(index: index)
		let updateTriggerLabel = NSTextField(labelWithString: "Update Trigger")
		let utStack = NSStackView(views: [updateTriggerLabel, updateTriggerPop])
		utStack.orientation = .horizontal
		optionsStack.addArrangedSubview(utStack)
		
		let comparisonPop = comparisonPop(index: index)
		let comparisonLabel = NSTextField(labelWithString: "Comparison")
		let compStack = NSStackView(views: [comparisonLabel, comparisonPop])
		compStack.orientation = .horizontal
		optionsStack.addArrangedSubview(compStack)
		
		
		NSLayoutConstraint.activate([
			startPopLabel.leadingAnchor.constraint(equalTo: optionsStack.leadingAnchor),
			updateWithLabel.leadingAnchor.constraint(equalTo: optionsStack.leadingAnchor),
			updateTriggerLabel.leadingAnchor.constraint(equalTo: optionsStack.leadingAnchor),
			comparisonLabel.leadingAnchor.constraint(equalTo: optionsStack.leadingAnchor),
			
			startPop.trailingAnchor.constraint(equalTo: optionsStack.trailingAnchor),
			updatePop.trailingAnchor.constraint(equalTo: optionsStack.trailingAnchor),
			updateTriggerPop.trailingAnchor.constraint(equalTo: optionsStack.trailingAnchor),
			comparisonPop.trailingAnchor.constraint(equalTo: optionsStack.trailingAnchor),
		])
		
		return optionsStack
	}
	
	func startWithPopup(index: Int) -> ComponentPopUpButton {
		let pop = ComponentPopUpButton(title: "", selectAction: {
			for v in ColumnStartWith.allCases {
				if v.menuItemTitle == $0.selectedItem?.title {
					self.run.setStartWith(v, for: index)
				}
			}
		})
		let menu = NSMenu()
		for i in ColumnStartWith.allCases {
			menu.addItem(.init(title: i.menuItemTitle, action: nil, keyEquivalent: ""))
		}
		pop.menu = menu
		pop.selectItem(withTitle: run.getStartWith(for: index).menuItemTitle)
		return pop
	}
	
	func updateWithPopup(index: Int) -> ComponentPopUpButton {
		let pop = ComponentPopUpButton(title: "", selectAction: {
			for v in ColumnUpdateWith.allCases {
				if v.menuItemTitle == $0.selectedItem?.title {
					self.run.setUpdateWith(v, for: index)
				}
			}
		})
		let menu = NSMenu()
		for i in ColumnUpdateWith.allCases {
			menu.addItem(.init(title: i.menuItemTitle, action: nil, keyEquivalent: ""))
		}
		pop.menu = menu
		pop.selectItem(withTitle: run.getUpdateWith(for: index).menuItemTitle)
		return pop
		
	}
	
	func updateTriggerPop(index: Int) -> ComponentPopUpButton {
		let pop = ComponentPopUpButton(title: "", selectAction: {
			for v in ColumnUpdateTrigger.allCases {
				if v.menuItemTitle == $0.selectedItem?.title {
					self.run.setUpdateTrigger(v, for: index)
				}
			}
		})
		let menu = NSMenu()
		for i in ColumnUpdateTrigger.allCases {
			menu.addItem(.init(title: i.menuItemTitle, action: nil, keyEquivalent: ""))
		}
		pop.menu = menu
		pop.selectItem(withTitle: run.getUpdateTrigger(for: index).menuItemTitle)
		return pop
		
	}
	
	func comparisonPop(index: Int) -> ComponentPopUpButton {
		//TODO: Default comparison should list the run's default comparison
		let defaultCompItem = NSMenuItem(title: "Default Comparison", action: nil, keyEquivalent: "")
		let pop = ComponentPopUpButton(title: "", selectAction: {
			if $0.selectedItem?.title == defaultCompItem.title {
				self.run.setColumnComparison(nil, for: index)
			}
			for v in TimeComparison.allCases {
				if v.menuItemTitle == $0.selectedItem?.title {
					self.run.setColumnComparison(v, for: index)
				}
			}
		})
		let menu = NSMenu()
		for i in TimeComparison.allCases {
			menu.addItem(.init(title: i.menuItemTitle, action: nil, keyEquivalent: ""))
		}
		menu.addItem(defaultCompItem)
		pop.menu = menu
		if let comp = run.getColumnComparison(for: index) {
			pop.selectItem(withTitle: comp.menuItemTitle)
		} else {
			pop.selectItem(withTitle: defaultCompItem.title)
		}
		return pop
		
	}
}

extension TimeComparison {
	var menuItemTitle: String {
		switch self {
		case .averageSegments:
			return "Average Segments"
		case .latest:
			return "Latest"
		case .personalBest:
			return "Personal Best"
		case .balancedPB:
			return "Balanced PB"
		case .bestSegments:
			return "Best Segments"
		case .bestSplitTimes:
			return "Best Split Times"
		case .medianSegments:
			return "Median Segments"
		case .worstSegments:
			return "Worst Segments"
		}
	}
}
extension ColumnStartWith {
	var menuItemTitle: String {
		switch self {
		case .empty:
			return "Empty"
		case .comparisonTime:
			return "Comparison Time"
		case .comparsionSegmentTime:
			return "Comparison Segment Time"
		case .possibleTimeSave:
			return "Possible Time Save"
		}
	}
}

extension ColumnUpdateWith {
	var menuItemTitle: String {
		switch self {
		case .dontUpdate:
			return "Don't Update"
		case .splitTime:
			return "Split Time"
		case .delta:
			return "Delta"
		case .deltaWithFallback:
			return "Delta with Fallback"
		case .segmentTime:
			return "Segment Time"
		case .segmentDelta:
			return "Segment Delta"
		case .segmentDeltaWithFallback:
			return "Segment Delta with Fallback"
		}
	}
}

extension ColumnUpdateTrigger {
	var menuItemTitle: String {
		switch self {
		case .onStartingSegment:
			return "On Starting Segment"
		case .contextual:
			return "Contextual"
		case .onEndingSegment:
			return "On Ending Segment"
		}
	}
}
/*
 "Simple" setup for segment/split time ("Column value"):
 Value: Segment Time
	if time column:
	- Update With: segment time
	- Start with: Comparision segment time
	if diff:
	- update with: segment delta
	else
	- start with: comparison segment time
 Value: Split Time
	if time column:
	- start with: split time
	- update with: comparison time
	if diff column:
	- update with: delta
	else:
	- Start with: comparison time
 
 */
