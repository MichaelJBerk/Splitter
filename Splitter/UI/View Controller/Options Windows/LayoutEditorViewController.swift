//
//  LayoutEditorViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class LayoutEditorViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
	
	@IBOutlet var stack: NSStackView!
	var tableView: NSTableView! {
		let scroll = (stack.views[0].subviews[0] as! NSScrollView)
		let table = scroll.documentView as! NSTableView
		return table
	}
	var scrollView: NSScrollView! {
		return (stack.views[1].subviews[0] as! NSScrollView)
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		var indexToSelect = tableView.selectedRow
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
		tableView.delegate = self
		tableView.dataSource = self
		tableView.registerForDraggedTypes([dropType])
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
			tableView.reloadData()
		}
	}
	
	@IBAction func minusButtonClick(sender: Any?) {
		let sr = tableView.selectedRow
		if sr >= 0 {
			let viewToRemove = runController.mainStackView.views[sr]
			runController.removeView(view: viewToRemove as! SplitterComponent)
		}
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return runController.mainStackView.views.count
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
		if let component = runController.mainStackView.views[row] as? SplitterComponent, let type = SplitterComponentType.FromType(component) {
			cell.textField?.stringValue = type.displayTitle
		}
		return cell
	}
	func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
		let pastboard = info.draggingPasteboard
		if let data = pastboard.string(forType: dropType), let oldRow = Int(data) {
			var views = runController.mainStackView.views
			views.move(fromOffsets: IndexSet([oldRow]), toOffset: row)
			runController.mainStackView.update(runController.mainStackView, views)
			tableView.reloadData()
			return true
		}
		return false
		// Dont' forget to update model
		
	}
	
	func highlightAndShowOptions() {
		let selected = tableView.selectedRow
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
	func tableViewSelectionDidChange(_ notification: Notification) {
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
	func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
		
		let pasteBoard = NSPasteboardItem()
			
		pasteBoard.setString(String(row), forType: dropType)
		return pasteBoard
	}
	func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
		if dropOperation == .above {
			return .move
		}
		return []
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
