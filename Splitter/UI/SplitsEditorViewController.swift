//
//  SplitsEditorViewController.swift
//  Splitter
//
//  Created by Michael Berk on 6/25/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class SplitsEditorViewController: NSViewController, NibLoadable {
	
	var run: SplitterRun!
	var editor: RunEditor!
	var editorState: RunEditorState {
		editor.getState()
	}
	
	
	var segmentIcons: [NSImage?] = []
	
	var editorSelected: Int? = nil
	@IBOutlet weak var outlineView: LayoutEditorOutlineView!
	@IBOutlet weak var addButton: NSButton!
	@IBOutlet weak var removeButton: NSButton!
	@IBOutlet weak var cancelButton: NSButton!
	@IBOutlet weak var okButton: NSButton!
	@IBOutlet var moveUpButton: NSButton!
	@IBOutlet var moveDownButton: NSButton!
	
	@IBAction func moveUpButtonAction(_ sender: NSButton?) {
		editor.moveSegmentsUp()
		processIconChanges()
		outlineView.reloadData()
	}
	@IBAction func moveDownButtonAction(_ sender: NSButton?) {
		editor.moveSegmentsDown()
		processIconChanges()
		outlineView.reloadData()
	}
	
	@IBAction func cancelButtonAction(_ sender: NSButton?) {
		editor.dispose()
		self.dismiss(nil)
	}
	@IBAction func okButtonAction(_ sender: NSButton?) {
		let newRun = editor.close()
		run.setRun(newRun)
		run.updateLayoutState()
		NotificationCenter.default.post(.init(name: .splitsEdited))
		self.dismiss(nil)
	}
	
	@IBAction func removeButtonAction(_ sender: NSButton?) {
		removeSegments()
	}
	
	
	@IBAction func addButtonAction(_ sender: NSButton?) {
		addSegmentBelow()
	}
	
	static func instantiateView(with run: SplitterRun) -> SplitsEditorViewController {
		let vc: SplitsEditorViewController = SplitsEditorViewController(nibName: self.nibName, bundle: nil)
		vc.run = run
		let editor = RunEditor(run.timer.lsTimer.getRun().clone())
		vc.editor = editor
		vc.processIconChanges()
		return vc
	}
	
	var imageColumnIdentifier = NSUserInterfaceItemIdentifier("imageColumn")
	var nameColumnIdentifier = NSUserInterfaceItemIdentifier("nameColumn")
	var splitTimeColumnIdentifier = NSUserInterfaceItemIdentifier("splitTimeColumn")
	var segmentTimeColumnIdentifier = NSUserInterfaceItemIdentifier("segmentTimeColumn")
	var bestSegmentTimeColumnIdentifier = NSUserInterfaceItemIdentifier("bestSegmentTimeColumn")
	
	func columnIdentifierFor(comparison: String) -> NSUserInterfaceItemIdentifier {
		return NSUserInterfaceItemIdentifier(comparison + "Column")
	}
	
	func getSegment(_ index: Int) -> RunEditorSegmentState {
		let segments = editorState.segments!
		return segments[index]
	}
	
	@objc func addSegmentBelow() {
		editor.insertSegmentBelow()
		didAddSegment()
	}
	@objc func addSegmentAbove() {
		editor.insertSegmentAbove()
		didAddSegment()
	}
	func removeSegments() {
		editor.removeSegments()
		didAddSegment()
	}
	func didAddSegment() {
		processIconChanges()
			outlineView.reloadData()
	}
	#if DEBUG
	func addDebugMenu() {
		let debugMenu = NSMenu(title: "Debug")
		debugMenu.addItem(withTitle: "Copy Editor State", action: #selector(copyEditorState), keyEquivalent: "")
		debugMenu.addItem(withTitle: "Icon Set", action: #selector(debugIconSet), keyEquivalent: "")
		view.menu = debugMenu
	}
	
	@objc func copyEditorState() {
		let pasteboard = NSPasteboard.general
		pasteboard.declareTypes([.string], owner: nil)
		pasteboard.setString(editor.stateAsJson(), forType: .string)
		let alert = QuickAlert(message: "Copied Editor State", image: nil)
		alert.show()
	}
	
	@objc func debugIconSet() {
		editor.selectOnly(0)
		outlineView.reloadData()
		let image = NSImage(named: NSImage.bluetoothTemplateName)!
		image.toLSImage({ pointer, len in
			editor.setGameIcon(pointer, len)
			
		})
		if let data = editorState.iconChange?.rawValue {
			let image = NSImage(data: data)
			QuickAlert(message: "Set Icon", image: image).show()
		}
		
	}
	#endif
	

    override func viewDidLoad() {
		#if DEBUG
		addDebugMenu()
		#endif
		outlineView.editor = editor
		NotificationCenter.default.addObserver(forName: .splitsEdited, object: self.outlineView, queue: nil, using: { notification in
			self.outlineView.reloadData()
		})
		var plusMenu = NSMenu(title: "")
		plusMenu.addItem(withTitle: "Add Segment Below", action: #selector(addSegmentBelow), keyEquivalent: "")
		plusMenu.addItem(withTitle: "Add Segment Above", action: #selector(addSegmentAbove), keyEquivalent: "")
		addButton.menu = plusMenu
		
        super.viewDidLoad()
		var tableColumnsToAdd = [
			(column: NSTableColumn(identifier: self.splitTimeColumnIdentifier), name: "Split Time"),
			(column: NSTableColumn(identifier: segmentTimeColumnIdentifier), name: "Segment Time"),
			(column: NSTableColumn(identifier: bestSegmentTimeColumnIdentifier), name: "Best Segment Time")
		]
		editorState.comparisonNames?.forEach({ name in
			tableColumnsToAdd.append((column: NSTableColumn(identifier: columnIdentifierFor(comparison: name)), name: name))
		})
		for column in tableColumnsToAdd {
			column.column.title = column.name
			outlineView.addTableColumn(column.column)
		}
		let bestIndex = outlineView.column(withIdentifier: bestSegmentTimeColumnIdentifier)
		outlineView.tableColumns[bestIndex].width = 110
		
        // Do view setup here.
    }
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
	}
	
	let dataValues = [
		["V1", "V2"],
		["V1", "V2"],
		["V1", "V2"]
	]
	let dataKeys = [
		"Key1",
		"Key2",
		"Key3",
	]
}

extension NSTableColumn {
	convenience init(rawIdentifier: String) {
		self.init(identifier: NSUserInterfaceItemIdentifier(rawIdentifier))
	}
}

extension SplitsEditorViewController: NSOutlineViewDataSource {
	
	
	// You must give each row a unique identifier, referred to as `item` by the outline view
	// item == nil means it's the "root" row of the outline view, which is not visible
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			let segment = getSegment(index)
			return segment
		} else {
			return -1
		}
	}
	// Tell how many children each row has
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return editorState.segments?.count ?? 0
		} else {
			return 0
		}
	}
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return false
	}
}
extension SplitsEditorViewController: NSOutlineViewDelegate {
	
	func processIconChanges(completion: () -> () = {}) {
		let state = editorState
		let segments = state.segments!
		for i in 0..<segments.count {
			while i >= segmentIcons.count {
				segmentIcons.append(nil)
			}
			if let iconChange = segments[i].iconChange {
				let newImage = NSImage(data: iconChange.rawValue)
				segmentIcons[i] = newImage
			}
		}
		completion()
		//gameicon change...
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		if let item = item as? RunEditorSegmentState {
			if tableColumn?.identifier == self.imageColumnIdentifier {
				let cellIdentifier = NSUserInterfaceItemIdentifier("outlineViewImageCell")
				let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
				let index = editorState.segments!.firstIndex(of: item)!
				var image: NSImage = .gameControllerIcon
				let segments = editorState.segments!
				if index < segmentIcons.count {
					if let change = segments[index].iconChange {
						image = NSImage(data: change.rawValue)!
					} else {
						if let segImage = segmentIcons[index] {
							image = segImage
						}
					}
				}
				cell.imageView?.image = image
				/* TODO: Implement temporary icon storage
					- Currently, we access the run's icon
					- However, if a segment is added, or the icon changed, it won't be in the run!
				*/

//				if let segIcon = run.icon(for: index) {
//					cell.imageView?.image = segIcon
//				} else {
//					cell.imageView?.image = .gameControllerIcon
//				}
				return cell
			}
			
			let cellIdentifier = NSUserInterfaceItemIdentifier("outlineViewTextCell")
			let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
			var cellText: String
			switch tableColumn?.identifier {
			case self.nameColumnIdentifier:
				cellText = item.name
			case self.splitTimeColumnIdentifier:
				cellText = item.splitTime
			case self.segmentTimeColumnIdentifier:
				cellText = item.segmentTime
			case self.bestSegmentTimeColumnIdentifier:
				cellText = item.bestSegmentTime
			default:
				return nil
			}
			let tf = cell.textField as! LayoutEditorTextField
			tf.column = tableColumn!.identifier
			tf.delegate = self
			tf.stringValue = cellText
			return cell
		} else {
			return nil
		}
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		let selection = outlineView.selectedRow
		if selection >= 0 {
			editor.selectOnly(selection)
			editorSelected = selection
		}
	}
//	func outlineViewSelectionIsChanging(_ notification: Notification) {
//		let selection = outlineView.selectedRow
//		if selection < 0 {
//			editor.unselect(selection)
//		}
//	}
	
}

extension SplitsEditorViewController: NSTextFieldDelegate {
	public func controlTextDidEndEditing(_ obj: Notification) {
		if let textfield = obj.object as? LayoutEditorTextField {
			let row = outlineView.row(for: textfield)
			
			let id = textfield.column!
			set(textfield.stringValue, for: id, row: row)
		}
	}
	func set(_ string: String, for column: NSUserInterfaceItemIdentifier, row: Int) {
		let colIndex = outlineView.column(withIdentifier: column)
		var setFunc: (SplitterRun, String) -> () = {_, _ in}
		var oldString: String = ""
		let segments = editorState.segments!
		let segmentRow = segments[row]
		var actionTitle: String = ""
		switch column {
		case self.nameColumnIdentifier:
			oldString = segmentRow.name
			setFunc = {self.editor.activeSetName($1)}
			actionTitle = "Set Segment Name"
		case self.splitTimeColumnIdentifier:
			oldString = segmentRow.splitTime
			setFunc = {_ = self.editor.activeParseAndSetSplitTime($1)}
			actionTitle = "Set Split Time"
		case self.segmentTimeColumnIdentifier:
			oldString = segmentRow.segmentTime
			setFunc = {_ = self.editor.activeParseAndSetSegmentTime($1)}
			actionTitle = "Set Segment Time"
		case self.bestSegmentTimeColumnIdentifier:
			oldString = segmentRow.bestSegmentTime
			setFunc = {_ = self.editor.activeParseAndSetBestSegmentTime($1)}
			actionTitle = "Set Best Segment Time"
		default:
			break
		}
		setFunc(run, string)
		NotificationCenter.default.post(name: .splitsEdited, object: outlineView)
	}
}

class LayoutEditorTextField: NSTextField {
	var column: NSUserInterfaceItemIdentifier!
}

class LayoutEditorOutlineView: NSOutlineView {
	var editor: RunEditor!
	var editorState: RunEditorState {
		editor.getState()
	}
	
	override func selectRowIndexes(_ indexes: IndexSet, byExtendingSelection extend: Bool) {
		for row in 0..<numberOfRows {
			let rowView = rowView(atRow: row, makeIfNecessary: false)
			if indexes.contains(row) {
				if extend {
					editor.selectAdditionally(row)
				} else {
					editor.selectOnly(row)
				}
				rowView?.isSelected = true
			} else {
				editor.unselect(row)
				rowView?.isSelected = false
			}
		}
	}
	override var selectedRowIndexes: IndexSet {
		var indices = IndexSet()
		if let segments = editorState.segments {
			for i in 0..<segments.count {
				if segments[i].selected.bool() {
					indices.insert(i)
				}
			}
		}
		return indices
	}
	override var numberOfSelectedRows: Int {
		return selectedRowIndexes.count
	}
	
	override func deselectRow(_ row: Int) {
		editor.unselect(row)
	}
	var fullIndexSet: IndexSet {
		let array = Array(0...numberOfRows-1)
		let iSet = IndexSet(array)
		return iSet
	}
	
	override func selectAll(_ sender: Any?) {
		selectRowIndexes(fullIndexSet, byExtendingSelection: false)
	}
	override func deselectAll(_ sender: Any?) {
		selectRowIndexes(IndexSet(), byExtendingSelection: false)
	}
	
	override var selectedRow: Int {
		editorState.segments?.firstIndex(where:{$0.selected.bool()}) ?? -1
	}
	override func isRowSelected(_ row: Int) -> Bool {
		editorState.segments?[row].selected.bool() ?? false
	}
}
