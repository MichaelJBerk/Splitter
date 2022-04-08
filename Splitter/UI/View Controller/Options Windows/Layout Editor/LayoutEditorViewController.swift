//
//  LayoutEditorViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class LayoutEditorViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
	
	override func loadView() {
		
		outlineView = NSOutlineView()
		outlineView.dataSource = self
		outlineView.delegate = self
		let column = NSTableColumn()
		column.isEditable = false
		outlineView.addTableColumn(column)
		outlineView.columnAutoresizingStyle = .noColumnAutoresizing
		outlineView.headerView = nil
		outlineView.backgroundColor = .clear
		column.width = 150
		outlineView.frame = .init(x: 0, y: 0, width: 170, height: 200)
		if #available(macOS 11.0, *) {
			outlineView.style = .inset
		}
		
		let sidebarVE = NSVisualEffectView()
		sidebarVE.material = .sidebar
		sidebarVE.blendingMode = .behindWindow
		
		let outlineScroll = NSScrollView()
		outlineScroll.drawsBackground = false
		outlineScroll.documentView = outlineView
		sidebarVE.addSubview(outlineScroll)
		
		let popVE = NSVisualEffectView()
		popVE.material = .popover
		popVE.blendingMode = .behindWindow
		
		self.scrollView = NSScrollView()
		scrollView.drawsBackground = false
		popVE.addSubview(scrollView)
		
		
		let view = NSView(frame: .init(x: 0, y: 0, width: 577, height: 400))
		self.view = view
		self.view.addSubview(sidebarVE)
		self.view.addSubview(popVE)
		sidebarVE.frame = .init(x: 0, y: 0, width: 225, height: 400)
		popVE.frame = .init(x: 225, y: 0, width: 377, height: 400)
		outlineScroll.frame = .init(x: 0, y: 10, width: 225, height: 390)
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.red.cgColor
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: popVE.leadingAnchor, constant: 20),
			scrollView.topAnchor.constraint(equalTo: popVE.topAnchor, constant: 20),
			scrollView.bottomAnchor.constraint(equalTo: popVE.bottomAnchor),
			scrollView.trailingAnchor.constraint(equalTo: popVE.trailingAnchor, constant: -20),
		])
		outlineScroll.hasVerticalScroller = true
		scrollView.hasVerticalScroller = true
	}
	
	@IBOutlet var stack: NSStackView!
	var outlineView: NSOutlineView!
	var scrollView: NSScrollView!
	var currentOptions: NSView?
	
	
	override func viewWillAppear() {
		super.viewWillAppear()
		outlineView.expandItem(nil, expandChildren: true)
		let firstComponent = outlineView.child(0, ofItem: componentsHeaderObject)
		outlineView.selectRowIndexes(IndexSet([outlineView.row(forItem: firstComponent)]), byExtendingSelection: false)
		highlightAndShowOptions()
	}
	
	var optionsView: NSView! {
		return scrollView.documentView!
	}
	var rows = ["Row 1", "Row 2", "Row 3"]
	var dropType: NSPasteboard.PasteboardType = .init("public.data")
	var runController: ViewController!
	var draggingItem: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
//		self.preferredContentSize = view.frame.size
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
	
	
	func highlightAndShowOptions() {
		for view in runController.mainStackView.views {
			let component = view as! SplitterComponent
			let outlineRow = outlineView.row(forItem: component)
			if outlineRow == outlineView.selectedRow {
				component.isSelected = true
				let optionsView = component.optionsView!
				setOptionsView(optionsView)
				setConstraints(for: optionsView)
			} else {
				component.isSelected = false
			}
		}
		
		//Only "General" and "Window" are represented by row objects, so selecting the components doesn't change this code path.
		if let selectedItem = outlineView.item(atRow: outlineView.selectedRow) as? RowObject {
			if selectedItem == generalRowObject {
				
				let gsVC = GeneralLayoutSettingsViewController()
				gsVC.run = runController.run
				
				setOptionsView(gsVC.view)
				setConstraints(for: gsVC.view)
			} else {
				let appVC = WindowSettingViewController(nibName: "WindowSettingViewController", bundle: nil)
				appVC.runViewController = runController
				setOptionsView(appVC.view)
				appVC.view.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
				appVC.view.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor).isActive = true
				appVC.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
				scrollView.contentInsets.bottom = -20
			}
		}
		NSColorPanel.shared.close()
	}
	
	func setConstraints(for optionsView: NSView) {
		optionsView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.contentInsets.bottom = 20
		var constraintsToAdd = [
			optionsView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
			optionsView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor),
		]
		constraintsToAdd.append(optionsView.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor))
		NSLayoutConstraint.activate(constraintsToAdd)
	}
	
	func setOptionsView(_ optionsView: NSView) {
		if let oldOptions = currentOptions as? SplitsComponent.SplitsOptionsView {
			oldOptions.removeFromSuperview()
		}
		if let optionsView = optionsView as? SplitsComponent.SplitsOptionsView {
			scrollView.documentView = nil
			scrollView.superview!.addSubview(optionsView)
			currentOptions = optionsView
			let sv = scrollView.contentView
			optionsView.translatesAutoresizingMaskIntoConstraints = false
			
			NSLayoutConstraint.activate([
				optionsView.topAnchor.constraint(equalTo: sv.topAnchor),
				optionsView.leadingAnchor.constraint(equalTo: sv.leadingAnchor),
				optionsView.trailingAnchor.constraint(equalTo: sv.trailingAnchor),
				optionsView.bottomAnchor.constraint(equalTo: sv.bottomAnchor)
			])
			return
		}
		scrollView.documentView = optionsView
		currentOptions = optionsView
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
	let generalHeaderObject = HeaderObject("General")
	let componentsHeaderObject = HeaderObject("Components")
	let generalRowObject = RowObject("General")
	let windowRowObject = RowObject("Window")
}

///Object used to represent the "General" and "Window" items in the Layout Editor's outline view
class RowObject: NSObject {
	var string: String
	
	init(_ string: String) {
		self.string = string
	}
	
	override func isEqual(_ object: Any?) -> Bool {
		if let object = object as? Self,
		   object.string == self.string {
			return true
		}
		return false
	}
}

class HeaderObject: RowObject {}

//MARK: - Outline View Delegate/Data Source
extension LayoutEditorViewController {
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return 2
		}
		if let item = item as? HeaderObject {
			if item == componentsHeaderObject {
				return runController.mainStackView.views.count
			}
			if item == generalHeaderObject {
				return 2
			}
		}
		return 0
	}
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if item is HeaderObject {
			return true
		}
		return false
	}
	
	/**
	 Returns the child item at the specified index of a given item.

	 The General and Window options are each represented with a ``RowObject``.
	 The headings are represented by ``HeaderObject``s.
	 The options for each component are represented by the components themselves
	 */
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			if index == 0 {
				return generalHeaderObject
			} else {
				return componentsHeaderObject
			}
		}
		if let item = item as? HeaderObject {
			if item == componentsHeaderObject {
				return runController.mainStackView.views[index]
				
			}
			if item == generalHeaderObject {
				if index == 0 {
					return generalRowObject
				}
				return windowRowObject
			}
		}
		return ""
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		if let item = item as? HeaderObject {
			if item == componentsHeaderObject {
				let cell = makeHeaderCell()
				cell.textField?.stringValue = "Components"
				return cell
			}
			if item == generalHeaderObject {
				let cell = makeHeaderCell()
				cell.textField?.stringValue = "General"
				return cell
			}
		}
		if let item = item as? RowObject, !(item is HeaderObject) {
			let cell = makeTextCell()
			cell.textField?.stringValue = item.string
			return cell
		}
		if let component = item as? SplitterComponent,
		   let type = SplitterComponentType.FromType(component){
			let cell = makeTextCell()
			cell.textField?.stringValue = type.displayTitle
			return cell
		}
		return nil
	}
	
	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		if item is HeaderObject {
			return false
		}
		return true
	}
	func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
		if item is RowObject {
			return false
		}
		return true
	}
	func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
		if let dragItem = draggingItem {
			if let component = dragItem as? SplitterComponent {
				let oldIndex = runController.mainStackView.views.firstIndex(of: component)!
				var views = runController.mainStackView.views
				views.move(fromOffsets: IndexSet([oldIndex]), toOffset: index)
				runController.mainStackView.update(runController.mainStackView, views)
				outlineView.reloadData()
				let indexToSelect = outlineView.row(forItem: component)
				outlineView.selectRowIndexes(IndexSet([indexToSelect]), byExtendingSelection: false)
				return true
			}
		}
		return false
	}
	func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
		draggingItem = draggedItems[0] as Any?
		session.draggingPasteboard.setData(Data(), forType: dropType)
	}
	
	func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		if item is RowObject {
			return nil
		}
		let pbItem = NSPasteboardItem()
		pbItem.setDataProvider(self, forTypes: [dropType])
		return pbItem
	}
	
	func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
		self.draggingItem = nil
	}
	
	func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
		guard let ds = info.draggingSource as? NSOutlineView, ds == outlineView else {return []}
		if index < 0 {
			return .init()
		}
		if let item = item as? RowObject {
			outlineView.setDropItem(item, dropChildIndex: index)
		}
		return .generic
	}
}
extension LayoutEditorViewController: NSPasteboardItemDataProvider {
	func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: NSPasteboard.PasteboardType) {
		
		item.setString("Layout Editor Item", forType: type)
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
//MARK: - Creating Cells
extension LayoutEditorViewController {
	func addTFToCell(cell: NSTableCellView) {
		let tf = NSTextField(labelWithString: "")
		cell.textField = tf
		cell.addSubview(tf)
		tf.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			tf.widthAnchor.constraint(equalTo: cell.widthAnchor),
			tf.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
		])
	}
	
	func makeTextCell() -> NSTableCellView {
		let cell = NSTableCellView()
		addTFToCell(cell: cell)
		return cell
	}
	
	func makeHeaderCell() -> NSTableCellView {
		let cell = NSTableCellView()
		addTFToCell(cell: cell)
		
		let boldFont: NSFont
		if #available(macOS 11.0, *) {
			boldFont = NSFont.preferredFont(forTextStyle: .headline, options: [:])
		} else {
			boldFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
		}
		cell.textField?.font = boldFont
		return cell
	}
}
