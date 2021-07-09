//
//  LayoutEditorViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class LayoutEditorViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
	
	@IBOutlet var stack: NSStackView!
	var outlineView: NSOutlineView! {
		let scroll = (stack.views[0].subviews[0] as! NSScrollView)
		let table = scroll.documentView as! NSOutlineView
		return table
	}
	var scrollView: NSScrollView! {
		return (stack.views[1].subviews[0] as! NSScrollView)
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		outlineView.selectRowIndexes(IndexSet([0]), byExtendingSelection: false)
		highlightAndShowOptions()
	}
	
	var optionsView: NSView! {
		return scrollView.documentView!
	}
	var rows = ["Row 1", "Row 2", "Row 3"]
	var dropType: NSPasteboard.PasteboardType = .init("public.data")
	var runController: ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
		self.preferredContentSize = view.frame.size
		outlineView.delegate = self
		outlineView.dataSource = self
		outlineView.registerForDraggedTypes([dropType])
    }
	
	
	var componentsPopUpMenu: NSMenu {
		var items = [NSMenuItem]()
		let existingTypes = runController.mainStackView.views.map({ SplitterComponentType.FromType(($0 as! SplitterComponent))})
		for type in SplitterComponentType.allCases {
			if !existingTypes.contains(type) {
				items.append(.init(title: type.displayTitle, action: #selector(addComponent(sender:)), keyEquivalent: "", representedObject: type))
			}
		}
		let menu = NSMenu(title: "")
		for item in items {
			menu.addItem(item)
		}
		return menu
	}
	@objc func addComponent(sender: Any?) {
		if let sender = sender as? NSMenuItem,
		   let type = sender.representedObject as? SplitterComponentType {
			runController.addComponent(type)
			runController.setColorForControls()
			outlineView.reloadData()
		}
	}
	
	@IBAction func minusButtonClick(sender: Any?) {
		let sr = outlineView.selectedRow
		if sr >= 0 {
			let viewToRemove = runController.mainStackView.views[sr]
			runController.removeView(view: viewToRemove as! SplitterComponent)
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return runController.mainStackView.views.count
		}
		return 0
	}
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			return runController.mainStackView.views[index]
		}
		return ""
	}
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		if let cell = outlineView.makeView(withIdentifier: .init("textCell"), owner: self) as? NSTableCellView,
		   let component = item as? SplitterComponent,
		   let type = SplitterComponentType.FromType(component){
			cell.textField?.stringValue = type.displayTitle
			return cell
		}
		return nil
	}
	
	func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
		let pasteboard = info.draggingPasteboard
		if let data = pasteboard.string(forType: dropType),
		   let oldRow = Int(data),
		   let itemToMove = outlineView.item(atRow: oldRow) {
			var views = runController.mainStackView.views
			views.move(fromOffsets: IndexSet([oldRow]), toOffset: index)
			runController.mainStackView.update(runController.mainStackView, views)
			outlineView.reloadData()
			let indexToSelect = outlineView.childIndex(forItem: itemToMove)
			outlineView.selectRowIndexes(IndexSet([indexToSelect]), byExtendingSelection: false)
			return true
		}
		return false
	}
	
	func highlightAndShowOptions() {
		let selected = outlineView.selectedRow
		for i in 0..<runController.mainStackView.views.count {
			if let selectedComponent = runController.mainStackView.views[i] as? SplitterComponent {
				if i == selected {
					selectedComponent.isSelected = true
					let ov = selectedComponent.optionsView!
					scrollView.documentView = ov
					ov.translatesAutoresizingMaskIntoConstraints = false
					NSLayoutConstraint.activate([
						ov.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
						ov.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -5),
						ov.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -5)
					])
				} else {
					selectedComponent.isSelected = false
				}
			}
		}
	}
	func outlineViewSelectionDidChange(_ notification: Notification) {
		highlightAndShowOptions()
	}
	
	override func viewWillDisappear() {
		for v in runController.mainStackView.views {
			if let comp = v as? SplitterComponent {
				comp.isSelected = false
			}
		}
		
		super.viewWillDisappear()
	}
	
	func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		let row = outlineView.row(forItem: item)
		let pbItem = NSPasteboardItem()
		pbItem.setString(String(row), forType: dropType)
		return pbItem
	}
	
	func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
		if index < 0 {
			return .init()
		}
		outlineView.setDropItem(nil, dropChildIndex: index)
		return .generic
	}
	
}

extension Array {
	func rearrange(fromIndex: Int, toIndex: Int) -> Array{
		var arr = self
		let element = arr.remove(at: fromIndex)
		arr.insert(element, at: toIndex)

		return arr
	}
}
